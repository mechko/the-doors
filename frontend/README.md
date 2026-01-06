# The Doors: Vue.js Frontend for MRBS Door Locker

A frontend for user authentication and operating doors. 

## Project Structure

```
frontend/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   ├── views/
│   │   ├── Bookings.vue
│   │   └── Login.vue
│   ├── stores/
│   │   └── auth.js
│   ├── services/
│   │   └── api.js
│   ├── router/
│   │   └── index.js
│   ├── App.vue
│   └── main.js
├── package.json
└── README.md
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Configure API Endpoint

The frontend is configured to connect to the Rust backend at `http://localhost:8080/api`. 

If your backend runs on a different port, update the `baseURL` in `src/services/api.js`:

```javascript
export const apiClient = axios.create({
  baseURL: 'http://localhost:YOUR_PORT/api',
  // ...
})
```

### 3. Start the Development Server

```bash
npm run serve
```

The application will be available at `http://localhost:8081` (or the next available port).

## Usage

### 1. Start the Backend
Make sure your Rust backend is running:
```bash
cd ../
cargo run
```

### 2. Access the Frontend
Open your browser and go to `http://localhost:8081`

### 3. Login
- Navigate to the login page
- Enter your credentials (username and password)
- You'll be redirected to the Bookings View upon successful login

## Pages

### Login (`/login`)
- User authentication form
- Error handling for invalid credentials
- Automatic redirect to Bookings on success

### Bookings (`/`)
- Landing page with Booking entries overview

## State Management

The app uses Pinia for state management with the following features:

- **Authentication State**: Login status, user data, JWT token
- **Persistent Storage**: Token and user data stored in localStorage
- **Automatic Token Management**: Sets/removes Authorization headers
- **Token Validation**: Checks token validity with backend

## API Integration

The frontend communicates with the Rust backend through:

- **POST `/api/login`** - User authentication
- **GET `/api/protected`** - Verify token and get user data
- **GET `/api/health`** - Backend health check

## Security Features

- ✅ JWT token storage in localStorage
- ✅ Automatic token validation
- ✅ Protected routes with navigation guards
- ✅ Automatic logout on token expiration

## Development

### Available Scripts

```bash
# Start development server
npm run serve

# Build for production
npm run build

# Lint and fix files
npm run lint
```

### Environment Variables

You can create a `.env` file in the frontend directory to override default settings:

```env
VUE_APP_API_BASE_URL=http://localhost:8080/api
```

## Production Build

To build for production:

```bash
npm run build
```

This creates a `dist/` folder with optimized files ready for deployment.

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- ES6+ features required
- No Internet Explorer support

## Dependencies

- **Vue 3** - Progressive JavaScript framework
- **Vue Router 4** - Official router for Vue.js
- **Pinia** - State management library
- **Axios** - HTTP client for API calls

