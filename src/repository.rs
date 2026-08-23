use anyhow::Result;
use crate::models::{Entry, User};
use sqlx::{MySql, Pool};
use std::env;

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
        let time_window_before = read_i64_env("TIME_WINDOW_BEFORE_BOOKING")?;
        let time_window_after = read_i64_env("TIME_WINDOW_AFTER_BOOKING")?;

        let entries = sqlx::query_as::<_, Entry>(
            r#"
            SELECT
                e.id,
                e.start_time,
                e.end_time,
                e.room_id,
                r.room_name,
                e.name,
                e.create_by,
                CASE
                    WHEN LOCATE('-', r.sort_key) > 0 THEN SUBSTRING_INDEX(r.sort_key, '-', -1)
                    ELSE ''
                END AS lock_id
            FROM mrbs_entry e
            LEFT JOIN mrbs_room r ON e.room_id = r.id
            WHERE e.create_by = ?
                AND (? > e.start_time - ? AND ? < e.end_time + ?)
            "#,
        )
        .bind(username)
        .bind(now)
        .bind(time_window_before)
        .bind(now)
        .bind(time_window_after)
        .fetch_all(&self.pool)
        .await?;

        Ok(entries)
    }

    pub async fn find_entry_by_id(&self, entry_id: i32) -> Result<Option<Entry>> {
        let entry = sqlx::query_as::<_, Entry>(
            r#"
            SELECT
                e.id,
                e.start_time,
                e.end_time,
                e.room_id,
                r.room_name,
                e.name,
                e.create_by,
                CASE
                    WHEN LOCATE('-', r.sort_key) > 0 THEN SUBSTRING_INDEX(r.sort_key, '-', -1)
                    ELSE ''
                END AS lock_id
            FROM mrbs_entry e
            LEFT JOIN mrbs_room r ON e.room_id = r.id
            WHERE e.id = ?
            "#,
        )
        .bind(entry_id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(entry)
    }
}

fn read_i64_env(name: &str) -> Result<i64> {
    Ok(env::var(name)?.parse::<i64>()?)
}
