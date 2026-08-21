mod models;
mod repository;
mod handlers;
mod jwt;

use actix_web::{middleware::Logger, web, App, HttpServer};
use log::{error, info, warn};
use sqlx::mysql::{MySqlPool, MySqlPoolOptions};
use std::env;
use std::time::Duration;

use crate::jwt::JwtService;
use crate::repository::UserAndRoomRepository;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Load environment variables
    dotenv::dotenv().ok();

    // Initialize logger
    env_logger::init();

    // Get configuration from environment
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let jwt_secret = read_jwt_secret()?;
    let host = env::var("SERVER_HOST")
        .unwrap_or_else(|_| "127.0.0.1".to_string());
    let port = env::var("SERVER_PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .expect("SERVER_PORT must be a valid port number");

    info!("Starting server on {}:{}", host, port);

    // Create database connection pool
    let pool = create_database_pool(&database_url).await?;

    // Create services
    let user_repo = UserAndRoomRepository::new(pool);
    let jwt_service = JwtService::new(jwt_secret);

    // Start HTTP server
    HttpServer::new(move || {
        App::new()
            .wrap(Logger::default())
            .app_data(web::Data::new(user_repo.clone()))
            .app_data(web::Data::new(jwt_service.clone()))
            .route("/api/login", web::post().to(handlers::login))
            .route("/api/protected", web::get().to(handlers::protected_route))
            .route("/api/entries/{username}", web::get().to(handlers::get_user_entries))
            .route("/api/open_door", web::post().to(handlers::open_door))
            .route("/api/close_door", web::post().to(handlers::close_door))
            .route("/api/health", web::get().to(health_check))
    })
    .bind((host, port))?
    .run()
    .await
}

async fn health_check() -> &'static str {
    "OK"
}

async fn create_database_pool(database_url: &str) -> std::io::Result<MySqlPool> {
    let retries = read_env_u64("DATABASE_CONNECT_RETRIES", 60).max(1);
    let retry_delay = Duration::from_secs(read_env_u64("DATABASE_CONNECT_RETRY_DELAY_SECONDS", 2));
    let acquire_timeout =
        Duration::from_secs(read_env_u64("DATABASE_CONNECT_TIMEOUT_SECONDS", 10).max(1));

    for attempt in 1..=retries {
        match MySqlPoolOptions::new()
            .max_connections(5)
            .acquire_timeout(acquire_timeout)
            .connect(database_url)
            .await
        {
            Ok(pool) => {
                info!("Connected to database");
                return Ok(pool);
            }
            Err(err) if attempt < retries => {
                warn!(
                    "Database connection attempt {}/{} failed: {}; retrying in {}s",
                    attempt,
                    retries,
                    err,
                    retry_delay.as_secs()
                );
                tokio::time::sleep(retry_delay).await;
            }
            Err(err) => {
                error!(
                    "Failed to connect to database after {} attempts: {}",
                    retries, err
                );
                return Err(std::io::Error::new(
                    std::io::ErrorKind::Other,
                    format!("Failed to create database pool after {retries} attempts: {err}"),
                ));
            }
        }
    }

    unreachable!("database connection retry loop always returns")
}

fn read_env_u64(name: &str, default: u64) -> u64 {
    env::var(name)
        .ok()
        .and_then(|value| value.parse::<u64>().ok())
        .unwrap_or(default)
}

fn read_jwt_secret() -> std::io::Result<String> {
    let secret = env::var("JWT_SECRET").map_err(|_| {
        std::io::Error::new(std::io::ErrorKind::InvalidInput, "JWT_SECRET must be set")
    })?;
    let trimmed_secret = secret.trim();
    let known_insecure_secrets = [
        "your-super-secret-jwt-key-change-in-production",
        "your-super-secret-jwt-key-here",
        "your-secret-key",
    ];

    if trimmed_secret.len() < 32 || known_insecure_secrets.contains(&trimmed_secret) {
        return Err(std::io::Error::new(
            std::io::ErrorKind::InvalidInput,
            "JWT_SECRET must be a non-default random value with at least 32 characters",
        ));
    }

    Ok(secret)
}
