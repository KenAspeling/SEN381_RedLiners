# Campus Learn Backend API

ASP.NET Core Web API backend for the Campus Learn application.

## Features

- **User Authentication** - JWT-based authentication with registration and login
- **Topics Management** - Create, read, update, delete topics with like functionality
- **Comments System** - Comment on topics with like functionality
- **User Roles** - Support for students and tutors with different permissions
- **PostgreSQL Database** - Entity Framework Core with PostgreSQL
- **Swagger Documentation** - Interactive API documentation

## Prerequisites

- .NET 8.0 SDK
- PostgreSQL database
- Visual Studio 2022 or VS Code

## Setup Instructions

### 1. Database Setup

1. Install PostgreSQL and create a database:
   ```sql
   CREATE DATABASE campuslearn_db;
   ```

2. Update the connection string in `appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost;Database=campuslearn_db;Port=5432;User Id=your_username;Password=your_password;"
     }
   }
   ```

### 2. JWT Configuration

Update the JWT settings in `appsettings.json`:
```json
{
  "JwtSettings": {
    "SecretKey": "your-super-secret-jwt-key-that-should-be-at-least-32-characters-long",
    "Issuer": "CampusLearnAPI",
    "Audience": "CampusLearnUsers",
    "ExpirationInMinutes": 1440
  }
}
```

### 3. Running the Application

1. Restore packages:
   ```bash
   dotnet restore
   ```

2. Run the application:
   ```bash
   dotnet run
   ```

3. Access Swagger UI at: `https://localhost:7000` (or the port shown in console)

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user info
- `GET /api/auth/check-tutor` - Check if user is tutor

### Topics
- `GET /api/topics` - Get all topics
- `GET /api/topics/{id}` - Get topic by ID
- `GET /api/topics/user/{userId}` - Get topics by user
- `POST /api/topics` - Create new topic (auth required)
- `PUT /api/topics/{id}` - Update topic (auth required)
- `DELETE /api/topics/{id}` - Delete topic (auth required)
- `POST /api/topics/{id}/like` - Toggle like on topic (auth required)
- `GET /api/topics/search?query={query}` - Search topics
- `GET /api/topics/trending` - Get trending topics

### Comments
- `GET /api/comments/topic/{topicId}` - Get comments for topic
- `GET /api/comments/user/{userId}` - Get comments by user
- `POST /api/comments` - Create new comment (auth required)
- `PUT /api/comments/{id}` - Update comment (auth required)
- `DELETE /api/comments/{id}` - Delete comment (auth required)
- `POST /api/comments/{id}/like` - Toggle like on comment (auth required)

## Database Schema

The API uses the following main entities:

- **Users** - Application users
- **Tutors** - Extended user information for tutors
- **Topics** - Discussion topics/posts
- **Comments** - Comments on topics
- **TopicLikes** - User likes on topics
- **CommentLikes** - User likes on comments

## Authentication

The API uses JWT Bearer tokens for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Development

### Entity Framework Migrations

When modifying models, create and apply migrations:

```bash
# Add migration
dotnet ef migrations add MigrationName

# Update database
dotnet ef database update
```

### Testing with Swagger

1. Start the application
2. Go to Swagger UI (root URL)
3. Use the "Authorize" button to add your JWT token
4. Test API endpoints interactively

## Project Structure

```
CampusLearnBackend/
├── Controllers/          # API controllers
├── Models/              # Entity models
├── DTOs/                # Data transfer objects
├── Data/                # Database context
├── Services/            # Business logic services
├── Program.cs           # Application startup
└── appsettings.json     # Configuration
```

## CORS Configuration

The API is configured to allow requests from Flutter web development servers. Update the CORS policy in `Program.cs` for production deployment.