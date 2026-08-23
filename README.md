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

We're using the table mrbs_room to store the ID of the Homematic lock for the room in the column "sort_key" (which is a string type). To preserve the normal MRBS room ordering, store the value as `<SORT-KEY>-<LOCK-ID>`, for example `001-002A20C9AEDCC9`. The backend uses the part after the last `-` as the Homematic lock ID. Rooms without this separator are treated as rooms without a configured lock.

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
Get room booking entries for the authenticated user (requires JWT token). The `{username}` path value must match the username in the JWT.

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

Door control is only allowed for the authenticated user's own entries during the configured booking time window.

**Note**: TLS certificate verification is enabled by default for CCU-JACK requests. Set `CCU_JACK_ACCEPT_INVALID_CERTS=true` only when using a self-signed certificate and accepting the network risk.

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

Door control is only allowed for the authenticated user's own entries during the configured booking time window.

**Note**: TLS certificate verification is enabled by default for CCU-JACK requests. Set `CCU_JACK_ACCEPT_INVALID_CERTS=true` only when using a self-signed certificate and accepting the network risk.

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

### Option 1: Docker (Recommended)

#### Environment Variables

The following environment variables can be configured in a `.env` file for docker-compose:

| Variable | Default | Description |
|----------|---------|-------------|
| `HTTP_PORT` | `3000` | HTTP port for the frontend |
| `HTTPS_PORT` | `3443` | HTTPS port for the frontend |
| `DOMAIN` | `localhost` | Domain name for the frontend. Set this to the public hostname when using Let's Encrypt. |
| `DATABASE_URL` | `mysql://mrbs_user:mrbs_password@mysql:3306/mrbs` | MySQL connection string for the backend |
| `JWT_SECRET` | Required | Random secret for JWT token generation. Must be at least 32 characters and must not use a public placeholder. |
| `SERVER_HOST` | `0.0.0.0` | Host address the backend server binds to (not so relevant, because Docker)|
| `SERVER_PORT` | `8080` | Port the backend server listens on (shouldn't be changed because the docker-compose would break) |
| `RUST_LOG` | `info` | Logging level (`error`, `warn`, `info`, `debug`, `trace`) |
| `CCU_JACK_URL` | `https://your-ccu-jack-host` | Base URL for the CCU-JACK API |
| `CCU_JACK_ACCEPT_INVALID_CERTS` | `false` | Set to `true` only to explicitly allow invalid/self-signed CCU-JACK TLS certificates |
| `TIME_WINDOW_BEFORE_BOOKING` | `600` | Time in seconds before a booking starts that the door can be opened (600 = 10 minutes) |
| `TIME_WINDOW_AFTER_BOOKING` | `600` | Time in seconds after a booking ends that the door can still be opened (600 = 10 minutes) |

#### Running with Docker Compose

1. **Build and run with Docker Compose**:
   ```bash
   # Copy and configure environment variables
   cp .env.example .env
   # Edit .env with your actual values
   # Generate JWT_SECRET with: openssl rand -base64 48
   
   # Start services (Docker images are going to be pulled from GHCR)
   docker-compose up
   ```

   For public HTTPS with Let's Encrypt, set `DOMAIN` to the public hostname and expose `HTTP_PORT=80` and `HTTPS_PORT=443`. The compose file persists Caddy's `/data` and `/config` directories in named Docker volumes so ACME accounts and certificates survive container recreates.

   To test local source changes on your Mac without waiting for GitHub Actions or making the Raspi build images, enable the local build override only in your Mac `.env`:

   ```bash
   COMPOSE_FILE=docker-compose.yml:docker-compose.local-build.yml
   ```

   Then run:

   ```bash
   docker-compose up --build
   ```

   Leave `COMPOSE_FILE` unset on the Raspi so it keeps pulling the GHCR images. Remove or comment out `COMPOSE_FILE` locally to return to the GHCR images.

2. **Or build and run manually**:
   ```bash
   # Build the Docker image
   docker build -t the-doors-backend .
   
   # Run with environment variables
   docker run -p 8080:8080 \
     -e DATABASE_URL="mysql://user:password@host:3306/mrbs_db" \
     -e JWT_SECRET="$(openssl rand -base64 48)" \
     -e CCU_JACK_URL="https://your-ccu-jack-host:2121" \
     the-doors-backend
   ```

### Option 2: Local Development

1. **Install Rust** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Configure environment variables**:
   Copy the `.env` file and update the values:
   ```bash
   cp .env.example .env
   ```

3. **Run the application**:
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
- JWT secrets must be configured explicitly and weak public placeholders are rejected at startup
- JWT tokens expire after 24 hours
- SQL injection prevention through parameterized queries
- Entry APIs only expose data for the authenticated user
- Door operations enforce booking ownership and the configured booking time window
- CCU-JACK TLS certificate verification is enabled by default
- Input validation and sanitization
- Secure error handling (no sensitive data in error messages)
