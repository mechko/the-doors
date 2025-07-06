use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub display_name: String, 
    pub email: String,
    pub password_hash: String, 
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Entry {
    pub id: i32,
    pub start_time: i64,
    pub end_time: i64,
    pub room_id: i32,
    pub room_name: String,
    pub name: String,
    pub create_by: String, // The user who created the entry
    pub lock_id: String,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub name: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub token: String,
    pub user: UserResponse,
}

#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub id: i32,
    pub name: String,
    pub email: String,
    pub display_name: String,
}

#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub error: String,
}

#[derive(Debug, Serialize)]
pub struct EntryResponse {
    pub id: i32,
    pub start_time: i64,
    pub end_time: i64,
    pub room_id: i32,
    pub name: String,
    pub create_by: String,
    pub room_name: String,
    pub lock_id: String,
}

#[derive(Debug, Deserialize)]
pub struct DoorRequest {
    pub entry_id: i32,
}

#[derive(Debug, Serialize)]
pub struct DoorResponse {
    pub success: bool,
    pub message: String,
}

impl From<User> for UserResponse {
    fn from(user: User) -> Self {
        UserResponse {
            id: user.id,
            name: user.name,
            email: user.email,
            display_name: user.display_name,
        }
    }
}

impl From<Entry> for EntryResponse {
    fn from(entry: Entry) -> Self {
        EntryResponse {
            id: entry.id,
            start_time: entry.start_time,
            end_time: entry.end_time,
            room_id: entry.room_id,
            name: entry.name,
            create_by: entry.create_by,
            room_name: entry.room_name,
            lock_id: entry.lock_id,
        }
    }
}
