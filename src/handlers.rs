use actix_web::{web, HttpResponse, Responder};
use log::{error, info};
use crate::models::{LoginRequest, AuthResponse, ErrorResponse, UserResponse, EntryResponse, DoorRequest, DoorResponse};
use crate::repository::UserAndRoomRepository;
use crate::jwt::{JwtService, Claims};
use std::env;

#[derive(Debug, Clone, Copy)]
pub enum DoorOperation {
    Open,
    Close,
}


pub async fn login(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    request: web::Json<LoginRequest>,
) -> impl Responder {
    info!("Login attempt for name: {}", request.name);

    // Find user by name
    match user_repo.find_by_username_or_email(&request.name).await {
        Ok(Some(user)) => {
            // Verify password
            match bcrypt::verify(&request.password, &user.password_hash.as_str()) {
                Ok(true) => {
                    // Generate JWT token
                    match jwt_service.generate_token(&user.id, &user.name) {
                        Ok(token) => {
                            info!("User logged in successfully: {}", user.name);
                            HttpResponse::Ok().json(AuthResponse {
                                token,
                                user: UserResponse::from(user),
                            })
                        }
                        Err(e) => {
                            error!("Token generation error: {}", e);
                            HttpResponse::InternalServerError().json(ErrorResponse {
                                error: "Internal server error".to_string(),
                            })
                        }
                    }
                }
                Ok(false) => {
                    info!("Invalid password for name: {}", request.name);
                    HttpResponse::Unauthorized().json(ErrorResponse {
                        error: "Invalid credentials".to_string(),
                    })
                }
                Err(e) => {
                    error!("Password verification error: {}", e);
                    HttpResponse::InternalServerError().json(ErrorResponse {
                        error: "Internal server error".to_string(),
                    })
                }
            }
        }
        Ok(None) => {
            info!("User not found: {}", request.name);
            HttpResponse::Unauthorized().json(ErrorResponse {
                error: "Invalid credentials".to_string(),
            })
        }
        Err(e) => {
            error!("Database error during login: {}", e);
            HttpResponse::InternalServerError().json(ErrorResponse {
                error: "Internal server error".to_string(),
            })
        }
    }
}

pub async fn protected_route(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    req: actix_web::HttpRequest,
) -> impl Responder {
    // Extract and validate JWT token
    let claims = match extract_and_validate_token(&req, &jwt_service).await {
        Ok(claims) => claims,
        Err(response) => return response,
    };

    // Optionally verify user still exists
    match user_repo.find_by_id(&claims.sub).await {
        Ok(Some(user)) => {
            HttpResponse::Ok().json(UserResponse::from(user))
        }
        Ok(None) => {
            HttpResponse::Unauthorized().json(ErrorResponse {
                error: "User not found".to_string(),
            })
        }
        Err(e) => {
            error!("Database error during token verification: {}", e);
            HttpResponse::InternalServerError().json(ErrorResponse {
                error: "Internal server error".to_string(),
            })
        }
    }
}

pub async fn get_user_entries(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    req: actix_web::HttpRequest,
    path: web::Path<String>,
) -> impl Responder {
    // Extract and validate JWT token
    let _claims = match extract_and_validate_token(&req, &jwt_service).await {
        Ok(claims) => claims,
        Err(response) => return response,
    };

    let username = path.into_inner();
    
    // Fetch entries for the user
    match user_repo.find_entries_by_username(&username).await {
        Ok(entries) => {
            let entry_responses: Vec<EntryResponse> = entries.into_iter()
                .map(EntryResponse::from)
                .collect();
            
            info!("Found {} entries for user: {}", entry_responses.len(), username);
            HttpResponse::Ok().json(entry_responses)
        }
        Err(e) => {
            error!("Database error while fetching entries for user {}: {}", username, e);
            HttpResponse::InternalServerError().json(ErrorResponse {
                error: "Internal server error".to_string(),
            })
        }
    }
}

pub async fn open_door(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    req: actix_web::HttpRequest,
    request: web::Json<DoorRequest>,
) -> impl Responder {
    toggle_door(user_repo, jwt_service, req, request, DoorOperation::Open).await
}

pub async fn close_door(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    req: actix_web::HttpRequest,
    request: web::Json<DoorRequest>,
) -> impl Responder {
    toggle_door(user_repo, jwt_service, req, request, DoorOperation::Close).await
}

async fn toggle_door(
    user_repo: web::Data<UserAndRoomRepository>,
    jwt_service: web::Data<JwtService>,
    req: actix_web::HttpRequest,
    request: web::Json<DoorRequest>,
    operation: DoorOperation,
) -> impl Responder {
    // Extract and validate JWT token
    let claims = match extract_and_validate_token(&req, &jwt_service).await {
        Ok(claims) => claims,
        Err(response) => return response,
    };

    // Find the entry by ID
    let entry = match user_repo.find_entry_by_id(request.entry_id).await {
        Ok(Some(entry)) => entry,
        Ok(None) => {
            return HttpResponse::NotFound().json(ErrorResponse {
                error: "Entry not found".to_string(),
            });
        }
        Err(e) => {
            error!("Database error while fetching entry {}: {}", request.entry_id, e);
            return HttpResponse::InternalServerError().json(ErrorResponse {
                error: "Internal server error".to_string(),
            });
        }
    };

    // Verify that the user owns this entry (check if the user created it)
    if entry.create_by != claims.username {
        return HttpResponse::Forbidden().json(ErrorResponse {
            error: "You don't have permission to control this door".to_string(),
        });
    }

    // Verify that we have a lock ID for the entry (aka room)
    if entry.lock_id.is_empty() {
        return HttpResponse::NotFound().json(ErrorResponse {
            error: "No Lock ID found for this room.".to_string(),
        });
    }

    // Determine the operation value and messages based on the operation type
    let (operation_value, success_message, error_message, log_action) = match operation {
        DoorOperation::Open => (2, "Door opened successfully", "Failed to open door", "opened"),
        DoorOperation::Close => (1, "Door closed successfully", "Failed to close door", "closed"),
    };

    // Make HTTP request to the demo service (accepting self-signed certificates)
    let client = reqwest::Client::builder()
        .danger_accept_invalid_certs(true)
        .build()
        .unwrap();

    let ccu_jack_url = env::var("CCU_JACK_URL")
            .expect("CCU_JACK_URL must be set");

    let door_action_url = format!("{}/device/{}/1/LOCK_TARGET_LEVEL/~pv", ccu_jack_url, entry.lock_id);

    info!("Attempting to {} door for entry {} by user {}", log_action, request.entry_id, claims.username);
    info!("Door action URL: {}", door_action_url);

    match client.put(door_action_url)
        .json(&serde_json::json!({
            "v": operation_value,
        }))
        .send()
        .await
    {
        Ok(response) => {
            if response.status().is_success() {
                info!("Door {} successfully for entry {} by user {}", log_action, request.entry_id, claims.username);
                HttpResponse::Ok().json(DoorResponse {
                    success: true,
                    message: success_message.to_string(),
                })
            } else {
                error!("Door service returned error status: {}", response.status());
                HttpResponse::ServiceUnavailable().json(DoorResponse {
                    success: false,
                    message: format!("{} - service unavailable", error_message),
                })
            }
        }
        Err(e) => {
            error!("Failed to contact door service: {}", e);
            HttpResponse::ServiceUnavailable().json(DoorResponse {
                success: false,
                message: format!("{} - service unavailable", error_message),
            })
        }
    }
}

// Helper function to extract and validate JWT token from request
async fn extract_and_validate_token(
    req: &actix_web::HttpRequest,
    jwt_service: &JwtService,
) -> Result<Claims, HttpResponse> {
    // Extract token from Authorization header
    let auth_header = match req.headers().get("Authorization") {
        Some(header) => match header.to_str() {
            Ok(h) => h,
            Err(_) => {
                return Err(HttpResponse::Unauthorized().json(ErrorResponse {
                    error: "Invalid authorization header".to_string(),
                }));
            }
        },
        None => {
            return Err(HttpResponse::Unauthorized().json(ErrorResponse {
                error: "Missing authorization header".to_string(),
            }));
        }
    };

    let token = match crate::jwt::extract_token_from_header(auth_header) {
        Ok(token) => token,
        Err(_) => {
            return Err(HttpResponse::Unauthorized().json(ErrorResponse {
                error: "Invalid authorization header format".to_string(),
            }));
        }
    };

    // Verify token
    match jwt_service.verify_token(&token) {
        Ok(claims) => Ok(claims),
        Err(_) => {
            Err(HttpResponse::Unauthorized().json(ErrorResponse {
                error: "Invalid or expired token".to_string(),
            }))
        }
    }
}
