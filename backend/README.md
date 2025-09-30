# Harari Prosperity Backend API

A complete Express.js backend for the Harari Prosperity mobile application, featuring user authentication, report management, file uploads, and email services.

## Features

- 🔐 **JWT Authentication** - Secure login/signup with access and refresh tokens
- 📝 **Report Management** - Full CRUD operations for prosperity reports
- 📎 **File Uploads** - Support for images, PDFs, and documents
- 📧 **Email Services** - Password reset, welcome emails, and verification
- 🛡️ **Security** - Rate limiting, CORS, helmet, input validation
- 📊 **Pagination & Search** - Efficient data retrieval
- 🔒 **Authorization** - User-specific data access

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Validation**: express-validator
- **Security**: Helmet, CORS, Rate Limiting
- **File Handling**: Multer
- **Email**: Nodemailer

## Quick Start

### Prerequisites

- Node.js (v18 or higher)
- MongoDB (local installation or MongoDB Atlas)
- npm or yarn

### Installation

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Environment Setup:**
   ```bash
   cp .env.example .env
   ```

4. **Configure your `.env` file:**
   ```env
   # Server Configuration
   PORT=3000
   NODE_ENV=development

   # Database
   MONGODB_URI=mongodb://localhost:27017/harari_prosperity

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-min-32-characters
   JWT_EXPIRES_IN=7d
   JWT_REFRESH_SECRET=your-refresh-token-secret-key-min-32-char
   JWT_REFRESH_EXPIRES_IN=30d

   # Email Configuration (Gmail example)
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_SECURE=false
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-gmail-app-password

   # Frontend URL
   FRONTEND_URL=http://localhost:8080

   # Rate Limiting
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100

   # File Upload
   MAX_FILE_SIZE=10485760
   UPLOAD_PATH=uploads/
   ```

5. **Start MongoDB:**
   ```bash
   # If using local MongoDB
   mongod

   # Or start MongoDB service
   sudo systemctl start mongod
   ```

6. **Run the server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

| Method | Endpoint | Description | Access |
|--------|----------|-------------|---------|
| POST | `/api/auth/signup` | Register new user | Public |
| POST | `/api/auth/signin` | Login user | Public |
| POST | `/api/auth/signout` | Logout user | Private |
| POST | `/api/auth/refresh` | Refresh access token | Public |
| POST | `/api/auth/reset-password` | Request password reset | Public |
| PUT | `/api/auth/reset-password/:token` | Reset password | Public |
| PUT | `/api/auth/update-user` | Update user profile | Private |

### Users

| Method | Endpoint | Description | Access |
|--------|----------|-------------|---------|
| GET | `/api/users/me` | Get current user | Private |
| PUT | `/api/users/me` | Update user profile | Private |
| DELETE | `/api/users/me` | Delete account | Private |

### Reports

| Method | Endpoint | Description | Access |
|--------|----------|-------------|---------|
| GET | `/api/reports` | Get user reports (paginated) | Private |
| GET | `/api/reports/:id` | Get single report | Private |
| POST | `/api/reports` | Create new report | Private |
| PUT | `/api/reports/:id` | Update report | Private |
| DELETE | `/api/reports/:id` | Delete report | Private |
| POST | `/api/reports/:id/attachments` | Upload attachments | Private |
| DELETE | `/api/reports/:id/attachments/:filename` | Delete attachment | Private |

### Utility

| Method | Endpoint | Description | Access |
|--------|----------|-------------|---------|
| GET | `/api/health` | Health check | Public |
| GET | `/uploads/:filename` | Serve uploaded files | Public |

## API Examples

### Register a new user
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "mypassword123",
    "userMetadata": {
      "name": "John Doe",
      "phone": "+1234567890"
    }
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "mypassword123"
  }'
```

### Create a report (requires authentication)
```bash
curl -X POST http://localhost:3000/api/reports \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Monthly Progress Report",
    "reportType": "Progress Report",
    "receiverName": "Project Manager",
    "objective": "Report on monthly achievements",
    "description": "Detailed description of progress",
    "importance": "High priority report",
    "mainPoints": "Key achievements and metrics",
    "status": "draft"
  }'
```

### Get user reports (with pagination and search)
```bash
curl "http://localhost:3000/api/reports?page=1&limit=10&search=progress&status=draft" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Database Schema

### User Model
```javascript
{
  email: String,           // Unique, required
  password: String,        // Hashed, required
  userMetadata: Object,    // Flexible user data
  isActive: Boolean,       // Account status
  isEmailVerified: Boolean,// Email verification
  refreshTokens: Array,    // Stored refresh tokens
  timestamps: true         // createdAt, updatedAt
}
```

### Report Model
```javascript
{
  userId: ObjectId,        // Reference to User
  name: String,
  reportType: String,
  receiverName: String,
  objective: String,
  description: String,
  importance: String,
  mainPoints: String,
  sources: String,
  roles: String,
  trends: String,
  themes: String,
  implications: String,
  scenarios: String,
  futurePlans: String,
  approvingBody: String,
  senderName: String,
  role: String,
  date: String,
  attachments: Array,      // File URLs
  linkAttachment: String,
  status: String,          // 'draft' or 'completed'
  timestamps: true         // createdAt, updatedAt
}
```

## File Upload Configuration

- **Supported formats**: JPEG, JPG, PNG, GIF, PDF, DOC, DOCX, TXT
- **Max file size**: 10MB per file (configurable)
- **Max files per report**: 10 files
- **Storage**: Local filesystem in `/backend/uploads/`

## Email Setup

### Gmail Configuration
1. Enable 2-factor authentication on your Google account
2. Generate an App Password: [Google Account Settings](https://myaccount.google.com/apppasswords)
3. Use the App Password as `EMAIL_PASS` in your `.env` file

### Other Email Providers
Configure SMTP settings in `.env`:
```env
EMAIL_HOST=smtp.your-provider.com
EMAIL_PORT=587
EMAIL_SECURE=false
```

## Testing

### Run tests
```bash
npm test
```

### API Testing with Postman/Insomnia
1. Import the collection from `docs/postman_collection.json`
2. Set up environment variables for `base_url` and `access_token`

## Deployment

### Environment Setup
```env
NODE_ENV=production
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/harari_prosperity
JWT_SECRET=your-long-random-production-jwt-secret
JWT_REFRESH_SECRET=your-long-random-production-refresh-secret
```

### PM2 Configuration
```bash
npm install -g pm2
pm2 start ecosystem.config.js
```

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## Security Features

- **Rate Limiting**: 100 requests per 15-minute window per IP
- **CORS**: Configured for frontend origin only
- **Helmet**: Various security headers
- **Input Validation**: Comprehensive validation with express-validator
- **JWT**: Secure token-based authentication
- **Password Hashing**: bcrypt with 12 salt rounds
- **File Type Validation**: Restricted upload types

## Error Handling

The API uses consistent error response format:
```json
{
  "message": "Human-readable error message",
  "error": "Technical error details (dev mode only)",
  "errors": ["Validation error array (when applicable)"]
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
