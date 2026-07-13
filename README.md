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
docker compose run --rm web bundle exec rspec
```

## Notes
- The Compose setup starts a PostgreSQL container automatically.
- The app uses the development environment by default.
