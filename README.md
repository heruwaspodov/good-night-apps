# Good Night - Sleep Tracker Application

This is a sleep tracker application that allows users to track their sleeping hours, follow other users, and view sleep records of their followers. The application provides real-time sleep tracking features with the ability to follow other users and compare sleep patterns.

## Ruby Version
This application uses Ruby 3.2.2

## System Dependencies
- Ruby 3.2.2
- PostgreSQL
- Docker (optional, but recommended)
- Redis (for caching and background jobs)

## Configuration

### Environment Variables
Create a `.env` file in the root directory with the following content:

```
DATABASE_URL=postgresql://postgres:password@localhost:5432/good_night_development
REDIS_URL=redis://localhost:6379/0
```

### Database Creation
This application uses PostgreSQL. You can run it using Docker with the provided Dockerfile:

```bash
docker-compose up -d
```

Or you can set up PostgreSQL locally.

## How to Run the Application

### With Docker (Recommended)
Build and start the services:

```bash
docker-compose up -d
```

Run database migrations:

```bash
docker-compose exec web rails db:create db:migrate
```

Access the application at http://localhost:3000

### Without Docker
Install dependencies:

```bash
bundle install
```

Create and migrate the database:

```bash
rails db:create db:migrate
```

Start the server:

```bash
rails server
```

## Background Jobs
The application uses Ruby on Rails ActiveJob for background processing. The whenever gem is used to schedule cron jobs:

```bash
bundle exec whenever --update-crontab
```

## How to Run the Test Suite
```bash
# Run all tests
rspec

# Run tests with documentation format
rspec -f d
```

## Code Quality Checks

### RuboCop
To check for code style issues:

```bash
rubocop
```

To automatically fix issues:

```bash
rubocop -A
```

## API Endpoints

### Sleep Tracking

#### Clock In
Start tracking sleep session.

**POST** `/api/sleeps/clock_in`

**Headers:**
- `X-User-Id: [user_id]`

**Response:**
```json
{
  "data": {
    "id": "uuid",
    "type": "sleep",
    "attributes": {
      "id": "uuid",
      "user_id": "uuid",
      "clock_in_time": "2023-10-22T10:00:00.000Z",
      "clock_out_time": null,
      "duration_minutes": null,
      "created_at": "2023-10-22T10:00:00.000Z",
      "updated_at": "2023-10-22T10:00:00.000Z"
    }
  }
}
```

#### Clock Out
End tracking sleep session.

**POST** `/api/sleeps/clock_out`

**Headers:**
- `X-User-Id: [user_id]`

**Params:**
```json
{
  "sleep_id": "uuid"
}
```

**Response:**
```json
{
  "data": {
    "id": "uuid",
    "type": "sleep",
    "attributes": {
      "id": "uuid",
      "user_id": "uuid",
      "clock_in_time": "2023-10-21T22:00:00.000Z",
      "clock_out_time": "2023-10-22T06:00:00.000Z",
      "duration_minutes": 480,
      "created_at": "2023-10-21T22:00:00.000Z",
      "updated_at": "2023-10-22T06:00:00.000Z"
    }
  }
}
```

### Following Users

#### Follow a User
Start following another user.

**POST** `/api/follows/follow`

**Headers:**
- `X-User-Id: [user_id]`

**Params:**
```json
{
  "followed_id": "uuid"
}
```

**Response:**
```json
{
  "data": {
    "id": "uuid",
    "type": "follow",
    "attributes": {
      "follower_id": "uuid",
      "followed_id": "uuid",
      "created_at": "2023-10-22T10:00:00.000Z",
      "updated_at": "2023-10-22T10:00:00.000Z"
    }
  }
}
```

#### Unfollow a User
Stop following a user.

**POST** `/api/follows/unfollow`

**Headers:**
- `X-User-Id: [user_id]`

**Params:**
```json
{
  "followed_id": "uuid"
}
```

**Response:**
```json
{
  "data": {
    "message": "Successfully unfollowed user"
  }
}
```

### Get Following Users' Sleep Records

#### Get Sleep Records of All Following Users
Get sleep records of all users the current user is following, sorted by duration.

**GET** `/api/sleeps/following_users_sleep_records`

**Headers:**
- `X-User-Id: [user_id]`

**Query Parameters:**
- `page` (required): Page number (minimum: 1)
- `limit` (required): Number of records per page (1-100)
- `date_start` (required): Start date in YYYY-MM-DD format
- `date_end` (required): End date in YYYY-MM-DD format

**Example Request:**
```
GET /api/sleeps/following_users_sleep_records?page=1&limit=10&date_start=2023-10-15&date_end=2023-10-22
```

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "type": "following_users_sleep_record",
      "attributes": {
        "id": "uuid",
        "user_id": "uuid",
        "clock_in_time": "2023-10-21T22:30:00.000Z",
        "clock_out_time": "2023-10-22T07:30:00.000Z",
        "duration_minutes": 540,
        "created_at": "2023-10-22T07:30:00.000Z",
        "updated_at": "2023-10-22T07:30:00.000Z",
        "user": {
          "id": "uuid",
          "name": "John Doe"
        }
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "offset": 0,
    "has_next_page": true,
    "has_prev_page": false
  }
}
```

### Error Responses
For validation errors:
```json
{
  "error": {
    "messages": [
      "Page must be greater than 0"
    ],
    "status": 422
  }
}
```

For unauthorized access:
```json
{
  "error": {
    "messages": [
      "X-User-Id header is required"
    ],
    "status": 401
  }
}
```

## Scheduled Jobs

### Daily Sleep Summary Job
The application includes a scheduled job that generates daily sleep summaries for all users each night at 00:00.

**Job Name:** `DailySleepSummaryJob`

**Schedule:** Runs daily at 00:00 (midnight) via cron job scheduled with Whenever gem

**Functionality:** 
- Processes sleep records from the previous day
- Calculates total sleep duration and number of sleep sessions
- Saves summaries to the `daily_sleep_summaries` table
- Can be manually executed: `rake sleep:generate_daily_summaries`

This job provides valuable daily insights for users about their sleep patterns and enables efficient retrieval of historical sleep data.

## Models

### User
- `id`: UUID
- `name`: String
- Associations: has many sleeps, daily_sleep_summaries, active_follows (as follower), passive_follows (as followed)

### Sleep
- `id`: UUID
- `user_id`: UUID (foreign key to User)
- `clock_in_time`: DateTime
- `clock_out_time`: DateTime
- `duration_minutes`: Integer
- Associations: belongs to User

### Follow
- `id`: UUID
- `follower_id`: UUID (foreign key to User)
- `followed_id`: UUID (foreign key to User)
- Associations: belongs to follower (User), belongs to followed (User)

### DailySleepSummary
- `id`: UUID
- `user_id`: UUID (foreign key to User)
- `date`: Date
- `total_sleep_duration_minutes`: Integer
- `number_of_sleep_sessions`: Integer
- Associations: belongs to User

## CI/CD Workflow
The application includes continuous integration workflows configured with GitHub Actions in `.github/workflows/ci.yml`:
- Automated testing on pull requests and pushes to main branch
- Code quality checks with RuboCop
- Security scanning with Brakeman
- Database schema loading and testing with PostgreSQL service
- Runs on Ubuntu latest environment

## Additional Features
- Caching implemented with Redis for improved performance
- Pagination without COUNT queries for better performance
- Comprehensive validation for all API endpoints
- Request/response serialization with proper JSON:API format
- Automated code quality checks with RuboCop