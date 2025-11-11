# API Documentation

REST API documentation for Challenge Goal App backend server.

## Base URL

```
http://localhost:3000/api
```

## Authentication

Most endpoints require authentication via session cookies. Login first to obtain a session.

### Headers

```
Content-Type: application/json
Cookie: connect.sid=<session-id>
```

---

## Authentication Endpoints

### Register User

Create a new user account.

**Endpoint:** `POST /api/register`

**Request Body:**
```json
{
  "username": "string (required)",
  "email": "string (required, valid email)",
  "password": "string (required, min 6 chars)",
  "gender": "string (optional)",
  "birthday": "string (optional, YYYY-MM-DD)"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com"
}
```

**Errors:**
- `400` - Username/email already exists
- `400` - Invalid email format
- `500` - Server error

---

### Login

Authenticate user and create session.

**Endpoint:** `POST /api/login`

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response:** `200 OK`
```json
{
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com"
  },
  "token": "session_abc123..."
}
```

**Errors:**
- `401` - Invalid credentials
- `500` - Server error

---

### Logout

End user session.

**Endpoint:** `POST /api/logout`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Logged out"
}
```

---

### Get Current User

Get authenticated user information.

**Endpoint:** `GET /api/user`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "profile_picture": "data:image/png;base64,...",
  "gender": "male",
  "birthday": "1990-01-01",
  "avatar_id": 1,
  "created_at": "2025-01-01 00:00:00"
}
```

**Errors:**
- `401` - Unauthorized

---

## User Profile Endpoints

### Update Profile

Update user profile information.

**Endpoint:** `PUT /api/user/profile`

**Authentication:** Required

**Request Body:**
```json
{
  "username": "string (optional)",
  "email": "string (optional)",
  "profile_picture": "string (optional, base64)",
  "gender": "string (optional)",
  "birthday": "string (optional)"
}
```

**Response:** `200 OK`
```json
{
  "message": "Profile updated",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com"
  }
}
```

---

## Goal Endpoints

### Create Goal

Create a new goal (personal or group).

**Endpoint:** `POST /api/goals`

**Authentication:** Required

**Request Body:**
```json
{
  "title": "string (required)",
  "description": "string (optional)",
  "duration": "string (optional, e.g., '30 days')",
  "duration_days": "number (optional)",
  "category": "string (optional)",
  "type": "string (single|group, default: single)",
  "friend_id": "number (optional, for group goals)",
  "start_date": "string (optional, YYYY-MM-DD)",
  "goal_picture": "string (optional)"
}
```

**Response:** `201 Created`
```json
{
  "goal_id": 1,
  "user_id": 1,
  "title": "Exercise daily",
  "type": "single",
  "status": "ongoing"
}
```

---

### Get User Goals

Get all goals for authenticated user.

**Endpoint:** `GET /api/goals`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "goals": [
    {
      "goal_id": 1,
      "title": "Exercise daily",
      "description": "30 minutes cardio",
      "duration": "30 days",
      "duration_days": 30,
      "category": "fitness",
      "type": "single",
      "status": "ongoing",
      "progress_days": 5,
      "start_date": "2025-01-01",
      "created_at": "2025-01-01 00:00:00"
    }
  ]
}
```

---

### Get Goal Details

Get specific goal information.

**Endpoint:** `GET /api/goals/:goalId`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "goal_id": 1,
  "user_id": 1,
  "title": "Exercise daily",
  "description": "30 minutes cardio",
  "participants": [
    {
      "user_id": 1,
      "username": "johndoe",
      "progress_days": 5,
      "completed": 0
    }
  ]
}
```

---

### Update Goal Progress

Mark goal as completed for the day.

**Endpoint:** `POST /api/goals/:goalId/progress`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Progress updated",
  "progress_days": 6,
  "completed": false
}
```

---

### Complete Goal

Mark goal as fully completed.

**Endpoint:** `POST /api/goals/:goalId/complete`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Goal completed!",
  "reward_item_id": 5
}
```

---

### Delete Goal

Delete a goal.

**Endpoint:** `DELETE /api/goals/:goalId`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Goal deleted"
}
```

---

## Friends Endpoints

### Get Friends List

Get all friends for authenticated user.

**Endpoint:** `GET /api/friends`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "friends": [
    {
      "user_id": 2,
      "username": "janedoe",
      "email": "jane@example.com",
      "profile_picture": "data:image/png;base64,...",
      "status": "accepted",
      "created_at": "2025-01-01 00:00:00"
    }
  ]
}
```

---

### Send Friend Request

Send a friend request to another user.

**Endpoint:** `POST /api/friends/request`

**Authentication:** Required

**Request Body:**
```json
{
  "friend_email": "string (required)"
}
```

**Response:** `201 Created`
```json
{
  "message": "Friend request sent",
  "friend_id": 2
}
```

**Errors:**
- `404` - User not found
- `400` - Already friends or request pending

---

### Accept Friend Request

Accept a pending friend request.

**Endpoint:** `POST /api/friends/:friendId/accept`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "message": "Friend request accepted"
}
```

---

### Get Mutual Goals

Get goals shared with a specific friend.

**Endpoint:** `GET /api/friends/:friendId/goals`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "goals": [
    {
      "goal_id": 3,
      "title": "Learn Flutter together",
      "type": "group",
      "participants": [
        {"user_id": 1, "username": "johndoe", "progress_days": 5},
        {"user_id": 2, "username": "janedoe", "progress_days": 4}
      ]
    }
  ]
}
```

---

## Avatar & Inventory Endpoints

### Get User Avatar

Get avatar information for user.

**Endpoint:** `GET /api/avatar`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "avatar_id": 1,
  "user_id": 1,
  "name": "My Avatar",
  "head": 1,
  "body": 2,
  "hand": 3,
  "accessory": 4
}
```

---

### Update Avatar

Update avatar equipped items.

**Endpoint:** `PUT /api/avatar`

**Authentication:** Required

**Request Body:**
```json
{
  "head": "number (optional)",
  "body": "number (optional)",
  "hand": "number (optional)",
  "accessory": "number (optional)"
}
```

**Response:** `200 OK`
```json
{
  "message": "Avatar updated",
  "avatar": {
    "avatar_id": 1,
    "head": 5,
    "body": 2,
    "hand": 3,
    "accessory": 4
  }
}
```

---

### Get User Inventory

Get all items owned by user.

**Endpoint:** `GET /api/inventory`

**Authentication:** Required

**Response:** `200 OK`
```json
{
  "items": [
    {
      "item_id": 1,
      "name": "Wooden Sword",
      "slot": "hand",
      "picture": "sword.png",
      "type": "weapon",
      "quantity": 1
    }
  ]
}
```

---

## Error Responses

All endpoints may return these standard errors:

### 400 Bad Request
```json
{
  "error": "Invalid input data",
  "details": "Email format is invalid"
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "message": "Please login first"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found",
  "message": "Goal with ID 123 not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error",
  "message": "Database error"
}
```

---

## Rate Limiting

Currently no rate limiting is implemented. This should be added before production deployment.

## CORS Policy

The backend allows requests from:
- `localhost` (all ports)
- `127.0.0.1` (all ports)

Credentials (cookies) are enabled for authentication.

## Database Schema

See [Server/db.js](Server/db.js) for complete database schema including:
- users
- goals
- goal_participants
- friends
- items
- inventory
- avatars

---

**Last Updated:** November 11, 2025  
**API Version:** 1.0.0
