# Angelswing Test

A Rails API application with authentication, content management, and basic authorization.

## Demo

Deployed demo: https://angelswing-test.onrender.com/api/v1/

## Run locally

### Prerequisites
- Docker
- Docker Compose

### Start the app
```bash
docker compose up --build
```

The app will be available at:
- http://localhost:3000

### Stop the app
```bash
docker compose down
```

### Run tests
```bash
bundle exec rspec
```

## API documentation

Reference: https://documenter.getpostman.com/view/9635212/2s847EQDzo

### 1. Sign up
- Route: POST /api/v1/users/signup
- Request:
```json
{
  "user": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "password": "StrongPassword123!",
    "country": "USA"
  }
}
```
- Response:
```json
{
  "data": {
    "id": 1,
    "type": "users",
    "attributes": {
      "token": "<jwt>",
      "email": "john@example.com",
      "name": "John Doe",
      "country": "USA",
      "createdAt": "2026-07-13T00:00:00.000Z",
      "updatedAt": "2026-07-13T00:00:00.000Z"
    }
  }
}
```

### 2. Sign in
- Route: POST /api/v1/auth/signin
- Request:
```json
{
  "auth": {
    "email": "john@example.com",
    "password": "StrongPassword123!"
  }
}
```
- Response:
```json
{
  "data": {
    "id": 1,
    "type": "users",
    "attributes": {
      "token": "<jwt>",
      "email": "john@example.com",
      "name": "John Doe",
      "country": "USA",
      "createdAt": "2026-07-13T00:00:00.000Z",
      "updatedAt": "2026-07-13T00:00:00.000Z"
    }
  }
}
```

### 3. List contents
- Route: GET /api/v1/contents
- Request: No body
- Response:
```json
{
  "data": [
    {
      "id": "1",
      "type": "contents",
      "attributes": {
        "title": "Hello",
        "body": "World",
        "createdAt": "2026-07-13T00:00:00.000Z",
        "updatedAt": "2026-07-13T00:00:00.000Z"
      }
    }
  ]
}
```

### 4. Create content
- Route: POST /api/v1/contents
- Request:
```json
{
  "content": {
    "title": "Hello",
    "body": "World"
  }
}
```
- Response:
```json
{
  "data": {
    "id": "1",
    "type": "contents",
    "attributes": {
      "title": "Hello",
      "body": "World",
      "createdAt": "2026-07-13T00:00:00.000Z",
      "updatedAt": "2026-07-13T00:00:00.000Z"
    }
  }
}
```

### 5. Update content
- Route: PATCH /api/v1/contents/:id
- Request:
```json
{
  "content": {
    "title": "Updated title"
  }
}
```
- Response:
```json
{
  "data": {
    "id": "1",
    "type": "contents",
    "attributes": {
      "title": "Updated title",
      "body": "World",
      "createdAt": "2026-07-13T00:00:00.000Z",
      "updatedAt": "2026-07-13T00:00:00.000Z"
    }
  }
}
```

### 6. Delete content
- Route: DELETE /api/v1/contents/:id
- Request: No body
- Response:
```json
{
  "message": "Deleted"
}
```

## Notes
- The Compose setup starts a PostgreSQL container automatically.
- The app uses the development environment by default.
