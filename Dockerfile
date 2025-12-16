# Build stage
FROM rust:1.90 AS builder

# Create app directory
WORKDIR /usr/src/app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy prepared sqlx data
COPY .sqlx/ ./.sqlx/

# Copy source code
COPY src ./src

# Build without sqlx compile-time verification
ENV SQLX_OFFLINE=true
RUN cargo build --release --bin the-doors-backend

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -u 1001 appuser

# Create app directory
WORKDIR /app

# COPY .env
COPY .env ./

# Copy the binary from builder stage
COPY --from=builder /usr/src/app/target/release/the-doors-backend /app/the-doors-backend

# Change ownership to app user
RUN chown -R appuser:appuser /app
USER appuser

# Environment variables with defaults
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=8080
ENV RUST_LOG=info

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# Run the binary
CMD ["./the-doors-backend"]
