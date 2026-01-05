mod models;
mod repository;
mod handlers;
mod jwt;

use actix_cors::Cors;
use actix_web::{web, App, HttpServer, middleware::Logger};
use sqlx::mysql::MySqlPool;
use std::env;
use log::info;

use crate::repository::UserAndRoomRepository;
use crate::jwt::JwtService;


#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Load environment variables
    dotenv::dotenv().ok();
    
    // Initialize logger
    env_logger::init();

    // Get configuration from environment
    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");
    let jwt_secret = env::var("JWT_SECRET")
        .expect("JWT_SECRET must be set");
    let host = env::var("SERVER_HOST")
        .unwrap_or_else(|_| "127.0.0.1".to_string());
    let port = env::var("SERVER_PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse::<u16>()
        .expect("SERVER_PORT must be a valid port number");

    info!("Starting server on {}:{}", host, port);

    // Create database connection pool
    let pool = MySqlPool::connect(&database_url)
        .await
        .expect("Failed to create database pool");


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
