# SQLite Express CRUD

Small Node.js + Express app using SQLite with register/login and simple frontend.

Requirements
- Node.js 14+

Quick start (PowerShell)

```powershell
cd C:\Users\Admin\Desktop\NewProject
npm install
npm start
```

Then open http://localhost:3000/register.html to create an account, login, and you'll be redirected to /hello which shows "Hello world".

API endpoints
- POST /api/register { username, password }
- POST /api/login { username, password }
- POST /api/logout
- POST /api/notes { content } (requires login)
- GET /api/notes (requires login)

Goals / Goal logs
-----------------
This project now includes a simple goal-tracking schema and helper functions.

Tables added:
- `goals` — stores each user goal and progress (columns: goal_id, user_id, title, description, duration, category, type, friend_id, status, start_date, progress_days, last_completed_at, created_at)
- `goal_logs` — stores progress entries for goals (columns: goal_log_id, goal_id, user_id, description, date, created_at)

Useful helper functions exposed from `db.js`:
- `createGoal(userId, title, description, duration, category, type, friendId, startDate)` — create a new goal
- `getGoalsByUser(userId)` — list goals for a user
- `getGoalById(goalId)` — fetch a single goal
- `logGoalProgress(goalId, userId, description, date)` — create a progress log and increment `progress_days`
- `getLogsForGoal(goalId, limit)` — fetch logs for a goal
- `setGoalStatus(goalId, status)` — update a goal's status (e.g., 'completed')

The DB schema is created at app startup (see `scripts/schema.js`).
