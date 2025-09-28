# Build stage
FROM golang:1.24-alpine AS builder

# Set working directory
WORKDIR /app

# Copy everything including vendor directory for offline builds
COPY . .

# Build the application using vendored dependencies
# This approach works even without internet access during build
RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor -ldflags="-w -s" -o anyflip-downloader .

# Runtime stage - using minimal scratch image
FROM scratch

# Copy ca-certificates from builder stage for HTTPS requests
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary from builder stage
COPY --from=builder /app/anyflip-downloader /anyflip-downloader

# Set entrypoint
ENTRYPOINT ["/anyflip-downloader"]