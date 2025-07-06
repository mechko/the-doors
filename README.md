# The Doors: Operating Doors of Booked Rooms in MRBS using Homematic / CCU-JACK 

_This is a prototype currently under development._ 

- Backend: A REST API backend built with Rust, Actix Web, and MySQL for user authentication and operating doors. We're operating on the MRBS database or a clone of that DB (more on that below).
- Frontend: A Vue.js application that interacts with the backend. 

We're using a Homematic infrastructure through CCU JACK.

User story: As a MRBS User I want to unlock and lock the door for my booked room.

Links: 
- FOSS Room Booking System MRBS: https://mrbs.sourceforge.io/
- REST API for Homematic Devices: https://github.com/mdzio/ccu-jack
- Homematic lock we're using: https://homematic-ip.com/en/product/door-lock-drive (HmIP-DLD)

Screenshot: 

![alt text](screenshot.png)

## Architecture

The system consists of several interconnected components that work together to provide secure door access control:

```mermaid
graph TD
    A[The Doors Frontend<br/>Vue.js] --> B[The Doors Backend<br/>Rust/Actix Web]
    B --> C[MRBS Database<br/>MySQL]
    B --> D[CCU-JACK<br/>Homematic Bridge]
    D --> E[Homematic Door Lock 1]
    D --> F[Homematic Door Lock 2]
    D --> G[Homematic Door Lock 3]
    D --> H[...]
    I[MRBS] --> C

    
    style A fill:#41b883,stroke:#333,stroke-width:2px,color:#fff
    style B fill:#ce422b,stroke:#333,stroke-width:2px,color:#fff
    style C fill:#4479a1,stroke:#333,stroke-width:2px,color:#fff
    style D fill:#ff6b35,stroke:#333,stroke-width:2px,color:#fff
    style E fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
    style F fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
    style G fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
    style H fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
```

I decided to use the MRBS Database as the integration layer with MRBS. The alternative would have been to customize the MRBS PHP application (prototype successful), but this will make updates of MRBS more difficult.

### Component Description

- **The Doors Frontend (Vue.js)**: User interface for authentication, viewing room bookings, and controlling door access
- **The Doors Backend (Rust)**: REST API server handling authentication, booking queries, and door control requests
- **MRBS Database (MySQL)**: Meeting Room Booking System database containing user accounts and room reservations
- **CCU-JACK (Homematic Bridge)**: HTTP bridge that translates REST API calls to Homematic protocol commands
- **Homematic Door Locks**: Physical smart locks that secure the meeting room doors

### Data Flow

1. Users authenticate through the frontend application
2. The backend validates credentials against the MRBS database
3. Authenticated users can view their room bookings and request door access
4. Door control requests are sent from the backend to CCU-JACK via HTTPS
5. CCU-JACK communicates with the appropriate Homematic door lock to open/close doors

## Features

- User login with JWT token generation
- Password hashing with bcrypt
- Protected routes with JWT authentication
- MySQL database integration
- Comprehensive error handling
- Logging

## API Endpoints

### POST /api/login
Login with existing credentials.

**Request Body:**
```json
{
    "username": "john_doe",
    "password": "secure_password"
}
```

**Response:**
```json
{
    "token": "jwt_token_here",
    "user": {
        "id": "user_id",
        "username": "john_doe",
        "email": "john@example.com",
        "created_at": "2025-07-05T12:00:00Z"
    }
}
```

### GET /api/protected
Access protected resource (requires JWT token).

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
    "id": "user_id",
    "username": "john_doe",
    "email": "john@example.com",
    "created_at": "2025-07-05T12:00:00Z"
}
```

### GET /api/entries/{username}
Get all room booking entries for a specific user (requires JWT token).

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
    {
        "id": 1,
        "start_time": 1720177200,
        "end_time": 1720180800,
        "room_id": 101,
        "name": "john_doe"
    },
    {
        "id": 2,
        "start_time": 1720263600,
        "end_time": 1720267200,
        "room_id": 102,
        "name": "john_doe"
    }
]
```

### GET /api/health
Health check endpoint.

**Response:**
```
OK
```

### POST /api/open_door
Open door for a specific entry (requires JWT token).

**Note**: This endpoint makes an HTTPS request to an external service that uses self-signed certificates. The client is configured to accept invalid certificates for this purpose.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
    "entry_id": 1
}
```

**Response:**
```json
{
    "success": true,
    "message": "Door opened successfully"
}
```

**Error Response:**
```json
{
    "success": false,
    "message": "Failed to open door - service unavailable"
}
```

### POST /api/close_door
Close door for a specific entry (requires JWT token).

**Note**: This endpoint makes an HTTPS request to an external service that uses self-signed certificates. The client is configured to accept invalid certificates for this purpose.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Request Body:**
```json
{
    "entry_id": 1
}
```

**Response:**
```json
{
    "success": true,
    "message": "Door closed successfully"
}
```

**Error Response:**
```json
{
    "success": false,
    "message": "Failed to close door - service unavailable"
}
```

## Setup

1. **Install Rust** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Configure environment variables**:
   Copy the `.env` file and update the values:
   ```bash
   cp .env.example .env
   ```

4. **Run the application**:
   ```bash
   cargo run
   ```

## Database Schema

The application relies on the MRBS database schema. 

## Testing

You can test the API using curl:

### Login:
```bash
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

### Access protected route:
```bash
curl -X GET http://localhost:8080/api/protected \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Get user entries:
```bash
curl -X GET http://localhost:8080/api/entries/testuser \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Open door for an entry:
```bash
curl -X POST http://localhost:8080/api/open_door \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "entry_id": 1
  }'
```

**Close Door:**
```bash
curl -X POST http://localhost:8080/api/close_door \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "entry_id": 1
  }'
```

## Project Structure

```
src/
├── main.rs          # Application entry point
├── models.rs        # Data models and request/response structures
├── repository.rs    # Database operations
├── handlers.rs      # HTTP request handlers
└── jwt.rs          # JWT token utilities
```

## Dependencies

- **actix-web**: Web framework
- **sqlx**: Async SQL toolkit
- **bcrypt**: Password hashing
- **jsonwebtoken**: JWT token handling
- **serde**: Serialization/deserialization
- **uuid**: UUID generation
- **chrono**: Date/time handling
- **dotenv**: Environment variable loading
- **anyhow**: Error handling

## Security Features

- Passwords are hashed using bcrypt
- JWT tokens expire after 24 hours
- SQL injection prevention through parameterized queries
- Input validation and sanitization
- Secure error handling (no sensitive data in error messages)
