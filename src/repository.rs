use std::env;

use sqlx::{MySql, Pool};
use anyhow::Result;
use crate::models::{User, Entry};

#[derive(Clone)]
pub struct UserAndRoomRepository {
    pool: Pool<MySql>,
}

impl UserAndRoomRepository {
    pub fn new(pool: Pool<MySql>) -> Self {
        Self { pool }
    }

    pub async fn find_by_username_or_email(&self, username: &str) -> Result<Option<User>> {
        let user = sqlx::query_as!(
            User,
            r#"SELECT id, name as "name!", display_name as "display_name!", email as "email!", password_hash as "password_hash!" FROM mrbs_users WHERE name = ? OR email = ?"#,
            username, username
        )
        .fetch_optional(&self.pool)
        .await?;

        Ok(user)
    }

    pub async fn find_by_id(&self, id: &i32) -> Result<Option<User>> {
        let user = sqlx::query_as!(
            User,
            r#"SELECT id, name as "name!", display_name as "display_name!", email as "email!", password_hash as "password_hash!" FROM mrbs_users WHERE id = ?"#,
            id
        )
        .fetch_optional(&self.pool)
        .await?;

        Ok(user)
    }

    pub async fn find_entries_by_username(&self, username: &str) -> Result<Vec<Entry>> {
        let now = chrono::Utc::now().timestamp();

        // assumtion: start_time and end_time in DB are in UTC
        let time_window_before = env::var("TIME_WINDOW_BEFORE_BOOKING")
            .expect("TIME_WINDOW_BEFORE_BOOKING must be set");
        let time_window_after = env::var("TIME_WINDOW_AFTER_BOOKING")
            .expect("TIME_WINDOW_AFTER_BOOKING must be set");

        let entries = sqlx::query_as!(
            Entry,
            r#"SELECT e.id as id, e.start_time as start_time, e.end_time as end_time, e.room_id as room_id, e.name as name, e.create_by as create_by, r.room_name as "room_name!", r.sort_key as "lock_id!" FROM mrbs_entry e LEFT JOIN mrbs_room r ON e.room_id=r.id WHERE e.create_by = ? AND (? > e.start_time - ? AND ? < e.end_time + ?)"#,
            username, now, time_window_before, now, time_window_after
        )
        .fetch_all(&self.pool)
        .await?;

        Ok(entries)
    }

    pub async fn find_entry_by_id(&self, entry_id: i32) -> Result<Option<Entry>> {
        let entry = sqlx::query_as!(
            Entry,
            r#"SELECT e.id as id, e.start_time as start_time, e.end_time as end_time, e.room_id as room_id, e.name as name, e.create_by as create_by, r.room_name as "room_name!", r.sort_key as "lock_id!" FROM mrbs_entry e LEFT JOIN mrbs_room r ON e.room_id=r.id WHERE e.id = ?"#,
            entry_id
        )
        .fetch_optional(&self.pool)
        .await?;

        Ok(entry)
    }
}
