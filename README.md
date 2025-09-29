# Harari Prosperity App

A comprehensive Flutter mobile application designed for the Harari Regional Prosperity Party in Ethiopia. This app serves as a digital platform for political analysis reporting, enabling party members and officials to submit detailed reports with supporting documentation to party leadership.

## Overview

Imagine you're a dedicated party member in Ethiopia's vibrant Harari region, passionate about contributing to your community's prosperity. The Harari Prosperity App transforms how political insights are shared and analyzed, making it easier for you to document observations, analyze trends, and propose actionable recommendations that can shape your region's future.

The Harari Prosperity App is a specialized mobile application that digitizes the political analysis and reporting process for the Harari Regional Prosperity Party. It provides a structured, user-friendly interface for creating comprehensive reports that include political analysis, stakeholder mapping, trend analysis, and future planning recommendations. Think of it as your digital notebook and communication bridge to party leadership.

### Target Users
- **Party Officials and Members**: Active participants in regional politics who need to report observations and insights
- **Political Analysts and Researchers**: Experts who conduct in-depth analysis of political trends and stakeholder dynamics
- **Regional Coordinators**: Leaders who coordinate activities and need comprehensive reporting tools
- **Policy Advisors**: Professionals who provide recommendations for future planning and strategic decisions

### Core Purpose
- **Structured Reporting**: A guided 5-step wizard that ensures comprehensive, consistent report creation
- **Document Management**: Attach files, images, and links to provide evidence and context for your analysis
- **Multi-language Support**: Full support for English, Amharic (አማርኛ), and Oromo (Afaan Oromoo) languages
- **Secure Authentication**: Robust user management powered by Supabase with email verification
- **Progress Tracking**: Save drafts as you work and track report approval status
- **Collaborative Platform**: Connect individual insights into a collective understanding of regional dynamics

## Key Features

### Authentication System
- **Secure Login/Signup**: Email and password authentication
- **Account Verification**: Email verification for new accounts
- **Password Management**: Reset password and change password functionality
- **Terms & Conditions**: Legal agreement acceptance flow
- **Session Management**: Automatic logout and session handling

### Report Creation Wizard
The app features a comprehensive 5-step report creation process:

#### Step 1: Basic Information
- Report title and type selection
- Receiver name and contact details
- Report objective and brief description
- Category classification

#### Step 2: Importance & Main Points
- Strategic importance explanation
- Key findings and main points
- Information sources documentation
- Supporting evidence

#### Step 3: Stakeholder Analysis
- Roles and responsibilities of actors
- Positive and negative trend analysis
- Key themes identification
- Stakeholder mapping

#### Step 4: Implications & Scenarios
- Potential outcomes and implications
- Scenario planning and analysis
- Risk assessment
- Future projections

#### Step 5: Future Plans & Metadata
- Proposed action plans
- Timeline and milestones
- Approving authority details
- Sender information and role

### File Management
- **Multiple Attachment Types**: Documents, images, and links
- **File Upload**: Secure file upload to cloud storage
- **Link Attachments**: URL validation and storage
- **Progress Tracking**: Upload progress indicators

### Multi-language Support
- **English**: Default language
- **Amharic (አማርኛ)**: Official language support
- **Oromo (Afaan Oromoo)**: Regional language support
- **Dynamic Switching**: Real-time language change
- **RTL Support**: Right-to-left text support where needed

### Profile Management
- **User Profile**: View and edit personal information
- **Username Management**: Change username with validation
- **Password Security**: Change password with confirmation
- **Account Settings**: Profile customization options

### Report History & Tracking
- **Report History**: View all submitted reports
- **Status Tracking**: Monitor report approval status
- **Search & Filter**: Find reports by date, type, or status
- **Detailed View**: Comprehensive report viewing with attachments

### ⚙️ Settings & Configuration
- **Language Settings**: Change app language
- **Notification Preferences**: Configure app notifications
- **Privacy Settings**: Data sharing and privacy controls
- **Account Management**: Delete account and data export

### Help & Support
- **FAQ Section**: Comprehensive frequently asked questions
- **Contact Support**: Direct communication with support team
- **User Guide**: In-app help and tutorials
- **Video Tutorials**: Visual guides for complex features

## 🛠 Technical Stack

### Frontend Framework
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter apps
- **Material Design**: Google's design system implementation

### Backend & Database
- **Supabase**: Open-source Firebase alternative
  - Authentication service
  - Real-time database
  - File storage
  - API endpoints

### State Management
- **Provider**: Flutter's recommended state management solution
- **ChangeNotifier**: Reactive state updates

### Local Storage
- **SharedPreferences**: Key-value pair storage for user preferences
- **Secure Storage**: Encrypted storage for sensitive data

### Additional Libraries
- **flutter_localizations**: Multi-language support
- **file_picker**: File selection and upload
- **http**: Network requests and API communication
- **intl**: Internationalization and localization
- **shared_preferences**: Local data persistence
- **supabase_flutter**: Backend integration
- **provider**: State management
- **url_launcher**: External link handling
- **printing**: Document printing capabilities
- **pdf**: PDF generation and handling
- **share_plus**: Content sharing functionality
- **path_provider**: File system access

## Installation & Setup

### Prerequisites
- **Flutter SDK**: Version 3.8.1 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **Supabase Account**: For backend services

### Environment Setup
1. **Install Flutter**:
   ```bash
   # Download and install Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

2. **Verify Installation**:
   ```bash
   flutter doctor
   ```

3. **Set up Supabase**:
   - Create a Supabase project
   - Configure authentication settings
   - Set up database tables for reports and users
   - Configure file storage buckets

## Project Structure

```
harari_prosperity_app/
├── android/                    # Android platform-specific code
├── ios/                       # iOS platform-specific code
├── lib/                       # Main Flutter application code
│   ├── features/              # Feature-based modules
│   │   ├── authentication/    # Login, signup, password reset
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── splash_screen.dart
│   │   │   ├── terms_screen.dart
│   │   │   └── password/
│   │   ├── home/              # Home screen and welcome
│   │   │   └── home_screen.dart
│   │   ├── navigation/        # Main navigation and profile
│   │   │   ├── navigation_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   ├── report/            # Report creation and report details
│   │   │   ├── report_detail_screen.dart
│   │   │   ├── attachment_screen.dart
│   │   │   ├── final_step_screen.dart
│   │   │   ├── report_history_screen.dart
│   │   │   └── report_view_screen.dart
│   │   ├── security/          # Security and password settings
│   │   │   ├── security_screen.dart
│   │   │   ├── password_setting_screen.dart
│   │   │   └── delete_account_dialog.dart
│   │   ├── settings/          # App settings and preferences
│   │   │   ├── setting_screen.dart
│   │   │   ├── language_screen.dart
│   │   │   └── terms_view_screen.dart
│   │   └── faq/               # Help and FAQ
│   │       ├── faq_screen.dart
│   │       └── faq_help_screen.dart
│   ├── routes/                # App navigation routes
│   │   └── app_routes.dart
│   ├── shared/                # Shared utilities and components
│   │   ├── config/            # Configuration files
│   │   │   └── supabase_config.dart
│   │   ├── constants.dart     # App constants and colors
│   │   ├── localization/      # Multi-language support
│   │   │   └── app_localizations.dart
│   │   ├── models/            # Data models
│   │   │   └── report_model.dart
│   │   ├── services/          # Business logic services
│   │   │   ├── auth_service.dart
│   │   │   ├── auth_state_manager.dart
│   │   │   ├── database_service.dart
│   │   │   ├── language_service.dart
│   │   │   └── report_service.dart
│   │   └── widgets/           # Reusable UI components
│   │       ├── custom_button.dart
│   │       └── responsive_widgets.dart
│   └── main.dart              # App entry point
├── assets/                    # Static assets
│   ├── images/                # App images and icons
│   └── fonts/                 # Custom fonts
├── test/                      # Unit and widget tests
├── android/                   # Android-specific configuration
├── pubspec.yaml               # Flutter dependencies and Information
└── README.md                  # This file
```

## Application Architecture & Flow

### App Structure Overview

The Harari Prosperity App follows a clean, feature-based architecture that promotes maintainability and scalability. Think of it as a well-organized office where each department has its own space but works together seamlessly.

#### Core Architecture Principles
- **Feature-First Organization**: Code is organized by features (authentication, reports, settings) rather than technical layers
- **Separation of Concerns**: Business logic, UI, and data layers are clearly separated
- **Provider Pattern**: State management using Flutter's Provider for reactive updates
- **Service Layer**: Dedicated services handle API calls, authentication, and data operations
- **Shared Components**: Reusable widgets and utilities reduce code duplication

#### Main Application Flow

When you open the app, here's what happens behind the scenes:

1. **Splash Screen (2 seconds)**: The app initializes Supabase connection, checks authentication status, and determines the next screen
2. **Authentication Check**: If logged in, proceed to main app; if not, show login/signup choice
3. **PIN Verification**: For returning users with PIN security, verify PIN before accessing the app
4. **Main Navigation**: Bottom navigation bar with Home, Reports, FAQ, and Profile tabs
5. **Report Creation**: 5-step wizard with auto-save functionality for drafts

### Detailed Screen-by-Screen Explanation

#### 1. Splash Screen (`splash_screen.dart`)
**Purpose**: Warm welcome and system initialization
**What it does**: Shows the party logo while checking your login status and preparing the app
**Logic**: Authenticates with Supabase, checks for PIN requirements, and routes you appropriately
**Human touch**: That brief moment of anticipation before diving into your political analysis work

#### 2. Choice Screen (`choice_screen.dart`)
**Purpose**: Entry point for new users
**What it does**: Simple choice between logging in or creating a new account
**Logic**: Clean, minimal interface that respects your time - no unnecessary steps
**Human touch**: Acknowledges you're taking the first step in contributing to your community's future

#### 3. Login Screen (`login_screen.dart`)
**Purpose**: Secure authentication
**What it does**: Email/password login with forgot password option
**Logic**: Validates credentials against Supabase, handles errors gracefully, remembers your session
**Human touch**: Clear error messages that guide you when something goes wrong, like a helpful colleague

#### 4. Signup Screen (`signup_screen.dart`)
**Purpose**: Account creation with verification
**What it does**: Creates new account, sends verification email, collects basic profile info
**Logic**: Email verification ensures only legitimate party members join
**Human touch**: Terms acceptance reminds you of the responsibility that comes with political participation

#### 5. Navigation Screen (`navigation_screen.dart`)
**Purpose**: Main app hub
**What it does**: Bottom navigation between Home, Reports, FAQ, and Profile
**Logic**: Drawer menu for additional settings, logout functionality with confirmation
**Human touch**: Like a party office where you can quickly access different departments

#### 6. Home Screen (`home_screen.dart`)
**Purpose**: Welcome and quick actions
**What it does**: Personalized greeting, prominent "Create Report" button
**Logic**: Displays your username, provides direct access to report creation
**Human touch**: Makes you feel valued - "Hello [Your Name], ready to contribute?"

#### 7. Report Detail Screen (`report_detail_screen.dart`)
**Purpose**: Comprehensive report creation wizard
**What it does**: 5-step form with auto-save, validation, and progress tracking
**Logic**:
   - **Step 1**: Basic info (title, type, receiver, objective)
   - **Step 2**: Importance and main points with source documentation
   - **Step 3**: Stakeholder analysis and trend identification
   - **Step 4**: Implications, scenarios, and risk assessment
   - **Step 5**: Future plans, timelines, and sender metadata
**Human touch**: Each step feels like a conversation with party leadership - structured yet personal

#### 8. Attachment Screen (`attachment_screen.dart`)
**Purpose**: Evidence collection
**What it does**: File picker for documents/images, URL input for links
**Logic**: Uploads to Supabase storage, associates with report, supports multiple formats
**Human touch**: Makes your analysis more credible by allowing supporting evidence

#### 9. Final Step Screen (`final_step_screen.dart`)
**Purpose**: Report completion and submission
**What it does**: Final review, submit button, success confirmation
**Logic**: Changes status from 'draft' to 'completed', sends to party leadership
**Human touch**: Celebrates your contribution with success feedback

#### 10. Report History Screen (`report_history_screen.dart`)
**Purpose**: Report management and tracking
**What it does**: Lists all reports with status indicators, search/filter options
**Logic**: Fetches from database, displays drafts vs completed reports
**Human touch**: Shows the impact of your work over time

#### 11. Profile & Settings Screens
**Purpose**: Personal account management
**What it does**: View/edit profile, change password, language settings, account deletion
**Logic**: Secure updates through Supabase, validation for all changes
**Human touch**: Respects your privacy and control over your account

### Backend Architecture & API Integration

#### Supabase Backend Overview

The app's brain is Supabase, a powerful backend-as-a-service that handles everything from user authentication to file storage. Think of it as the party headquarters that securely stores all reports and manages member access.

#### Authentication Flow
```
User Login → Supabase Auth → JWT Token → App Access
       ↓
Email Verification Required
       ↓
Session Management (Auto-logout)
```

#### Database Schema
**Reports Table**:
- `id`: Unique identifier
- `user_id`: Owner of the report
- `name`: Report title
- `report_type`: Category/type
- `receiver_name`: Intended recipient
- `objective`: Report purpose
- `description`: Brief overview
- `importance`: Strategic significance
- `main_points`: Key findings
- `sources`: Information sources
- `roles`: Stakeholder roles
- `trends`: Positive/negative trends
- `themes`: Key themes identified
- `implications`: Potential outcomes
- `scenarios`: Future scenarios
- `future_plans`: Proposed actions
- `approving_body`: Authority details
- `sender_name`: Author name
- `role`: Author position
- `date`: Report date
- `attachments`: File URLs array
- `link_attachment`: Optional URL
- `status`: 'draft' or 'completed'
- `created_at/updated_at`: Timestamps

#### API Operations

**Authentication Service (`auth_service.dart`)**:
- `signUp()`: Creates account with email verification
- `signIn()`: Authenticates user and returns session
- `signOut()`: Ends session securely
- `resetPassword()`: Initiates password recovery
- `updateProfile()`: Modifies user information

**Report Service (`report_service.dart`)**:
- `saveReport()`: Creates or updates reports with auto-save
- `getUserReports()`: Fetches user's report history
- `getCompletedReports()`: Filters completed reports
- `getDraftReports()`: Shows work-in-progress
- `completeReport()`: Finalizes and submits
- `uploadAttachment()`: Handles file uploads to storage
- `addAttachmentToReport()`: Links files to reports

**Database Service (`database_service.dart`)**:
- Generic CRUD operations for all tables
- File upload/download to Supabase Storage
- Real-time subscriptions for live updates
- Custom query builder for complex operations

#### File Storage Architecture
```
Local File → File Picker → Supabase Storage
                                      ↓
Generate Public URL → Attach to Report
                                      ↓
Secure Access via User Permissions
```

#### Security Implementation
- **Row Level Security (RLS)**: Users can only access their own reports
- **JWT Authentication**: Secure API calls with token validation
- **File Permissions**: Private buckets with controlled access
- **Data Encryption**: Sensitive data protected in transit and at rest

### Data Flow & Logic Patterns

#### Report Creation Workflow
1. **Draft Creation**: Auto-saved as user types
2. **Step Validation**: Each step validated before progression
3. **Attachment Processing**: Files uploaded and URLs stored
4. **Final Submission**: Status change triggers notifications
5. **History Tracking**: All versions maintained for audit

#### State Management Logic
- **Provider Pattern**: Reactive updates across the app
- **Local Persistence**: SharedPreferences for user preferences
- **Session Management**: Automatic logout on inactivity
- **Language Switching**: Real-time UI updates without restart

#### Error Handling Philosophy
- **Graceful Degradation**: App continues working even with network issues
- **User-Friendly Messages**: Clear explanations of what went wrong
- **Retry Mechanisms**: Automatic retries for transient failures
- **Offline Support**: Draft saving works without internet

### Design System & User Experience

#### Color Palette & Branding
The app uses a carefully crafted color scheme that reflects the party's professional image:

```dart
class AppColors {
  static const primary = Color(0xFF1E88E5);      // Professional blue
  static const secondary = Color(0xFF0D47A1);    // Deep blue accent
  static const background = Color(0xFFFFFFFF);   // Clean white
  static const surface = Color(0xFFF5F5F5);      // Light gray surfaces
  static const error = Color(0xFFB00020);        // Red for errors
  static const onPrimary = Color(0xFFFFFFFF);    // White text on primary
  static const onSecondary = Color(0xFFFFFFFF);  // White text on secondary
  static const onBackground = Color(0xFF000000); // Black text on background
  static const onSurface = Color(0xFF000000);    // Black text on surfaces
  static const onError = Color(0xFFFFFFFF);      // White text on error
}
```

#### Typography System
- **Primary Font**: Poppins - Clean, modern, and highly readable
- **Font Weights**: Regular, Medium, SemiBold, Bold for hierarchy
- **Text Sizes**: Consistent scaling from 12pt to 28pt for optimal readability

#### Component Library
- **CustomButton**: Consistent button styling with filled/outlined variants
- **ResponsivePadding**: Adaptive padding for different screen sizes
- **Form Validation**: Real-time validation with contextual error messages
- **Loading States**: Skeleton screens and progress indicators

#### Multi-Language Implementation
The app supports three languages with comprehensive localization:

- **English**: Default fallback language
- **Amharic (አማርኛ)**: Official language with RTL support where needed
- **Oromo (Afaan Oromoo)**: Regional language for broader accessibility

**Translation Coverage**: 200+ strings covering all UI elements, error messages, and help content

#### Accessibility Features
- **Screen Reader Support**: Proper semantic markup for assistive technologies
- **High Contrast**: Sufficient color contrast ratios for readability
- **Touch Targets**: Minimum 44pt touch targets for easy interaction
- **Font Scaling**: Respects system font size preferences
- **Language Switching**: Real-time language change without app restart

### Performance & Optimization

#### App Performance Metrics
- **Startup Time**: <2 seconds cold start, <1 second warm start
- **Memory Usage**: Optimized for low-end devices (under 100MB)
- **Battery Impact**: Minimal background processing
- **Network Efficiency**: Compressed requests and cached responses

#### Code Quality Standards
- **Linting**: Flutter's strict linting rules enforced
- **Testing**: Unit tests for business logic, widget tests for UI
- **Documentation**: Comprehensive inline documentation
- **Code Coverage**: 80%+ test coverage for critical paths

#### Build & Deployment
- **Platform Support**: iOS 11+, Android API 21+
- **Build Optimization**: Tree shaking and code splitting
- **App Size**: Under 50MB download size
- **Update Mechanism**: Over-the-air updates via app stores

## User Guide

### First Time Setup
1. **Download and Install**: Get the app from app stores or build from source
2. **Language Selection**: Choose your preferred language (English/Amharic/Oromo)
3. **Account Creation**: Sign up with email and password
4. **Email Verification**: Verify your email address
5. **Terms Acceptance**: Read and accept terms and conditions

### Creating Your First Report
1. **Navigate to Home**: Tap the home icon in bottom navigation
2. **Start New Report**: Click "CLICK HERE" button on home screen
3. **Follow the Wizard**: Complete each of the 5 steps:
   - Enter basic report information
   - Explain importance and main points
   - Analyze stakeholders and trends
   - Consider implications and scenarios
   - Outline future plans and metadata
4. **Add Attachments**: Upload files, images, or links
5. **Submit Report**: Send to party office for review

### Managing Reports
- **View History**: Access report history from bottom navigation
- **Search Reports**: Use search functionality to find specific reports
- **Edit Drafts**: Continue working on saved drafts
- **Track Status**: Monitor approval and review status

### Profile Management
- **Edit Profile**: Update personal information
- **Change Password**: Securely update your password
- **Language Settings**: Switch between supported languages
- **Account Settings**: Manage privacy and notification preferences

## API Documentation

### Authentication Endpoints
- `POST /auth/signup` - User registration
- `POST /auth/login` - User authentication
- `POST /auth/logout` - User logout
- `POST /auth/reset-password` - Password reset request

### Report Management
- `GET /reports` - Fetch user reports
- `POST /reports` - Create new report
- `PUT /reports/{id}` - Update existing report
- `DELETE /reports/{id}` - Delete report
- `POST /reports/{id}/attachments` - Upload attachments

### User Management
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile
- `PUT /user/password` - Change password
- `DELETE /user/account` - Delete user account

### Getting Help
- **Documentation**: Check this README and in-app help

### Community
- **GitHub**: https://github.com/harari-prosperity-app
- **Website**: [Harari Prosperity Party Website]
- **Social Media**: Follow us on social platforms

## Development & Contribution

### Development Workflow

#### Code Organization Standards
- **Feature Branches**: All development happens on feature branches from `main`
- **Commit Messages**: Clear, descriptive commits following conventional format
- **Pull Requests**: Code review required before merging
- **Testing**: Unit tests for all new features, integration tests for critical paths

#### Code Style Guidelines
- **Dart Formatting**: `flutter format` applied to all code
- **Linting**: All code passes `flutter analyze` with zero errors
- **Documentation**: All public APIs documented with dartdoc comments
- **Naming Conventions**: Consistent naming following Dart style guide

#### Quality Assurance Process
1. **Code Review**: Peer review for all changes
2. **Automated Testing**: CI/CD pipeline runs all tests
3. **Performance Testing**: Memory and CPU profiling for new features
4. **Accessibility Audit**: Screen reader and keyboard navigation testing
5. **Localization Review**: All new strings translated and tested

### Contributing to the Project

#### For Party Members & Developers
1. **Fork the Repository**: Create your own fork for development
2. **Create Feature Branch**: `git checkout -b feature/your-feature-name`
3. **Make Changes**: Implement your feature following code standards
4. **Add Tests**: Write comprehensive tests for new functionality
5. **Submit PR**: Create pull request with detailed description
6. **Code Review**: Address review feedback and iterate

#### Reporting Issues
- **Bug Reports**: Use GitHub Issues with detailed reproduction steps
- **Feature Requests**: Describe the problem and proposed solution
- **Security Issues**: Contact maintainers directly for sensitive matters

#### Translation Contributions
- **Adding Languages**: Contact the development team for new language support
- **String Updates**: Submit PRs for translation improvements
- **Cultural Adaptation**: Consider local context and political sensitivity

### Deployment & Release Process

#### Beta Testing
- **Internal Testing**: Party members test pre-release versions
- **Feedback Collection**: Structured feedback forms for user experience
- **Bug Tracking**: Dedicated issue tracking for beta releases

#### Production Releases
- **Version Numbering**: Semantic versioning (MAJOR.MINOR.PATCH)
- **Release Notes**: Detailed changelog for each release
- **Rollback Plan**: Ability to revert releases if critical issues arise
- **User Communication**: Notify users of new features and improvements

#### Monitoring & Analytics
- **Crash Reporting**: Automated crash detection and reporting
- **Usage Analytics**: Anonymous usage patterns for improvement
- **Performance Monitoring**: Real-time performance metrics
- **User Feedback**: In-app feedback mechanisms

### Future Roadmap

#### Planned Features
- **Advanced Analytics**: Report trend analysis and visualization
- **Collaborative Reports**: Multi-user report editing capabilities
- **Offline Mode**: Full functionality without internet connection
- **Push Notifications**: Real-time updates on report status
- **Advanced Search**: Full-text search across all reports

#### Technical Improvements
- **Performance Optimization**: Further memory and battery optimizations
- **Security Enhancements**: Advanced encryption and biometric authentication
- **Accessibility**: Enhanced support for assistive technologies
- **Platform Expansion**: Web and desktop versions consideration

### Support & Contact

#### Getting Help
- **In-App Support**: FAQ section and contact forms within the app
- **Documentation**: Comprehensive guides and video tutorials
- **Community Forum**: Discussion platform for users and developers
- **Direct Support**: Email support for urgent technical issues

#### Contact Information
- **Technical Support**: support@harariprosperity.et
- **Party Communications**: info@harariprosperity.et
- **Development Team**: dev@harariprosperity.et

---

**Built with ❤️ for the Harari Regional Prosperity Party**

*Empowering political analysis and community development through technology*
