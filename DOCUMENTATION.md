# Job Tracker Application - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Technology Stack](#technology-stack)
4. [Database Schema](#database-schema)
5. [Application Features](#application-features)
6. [Models](#models)
7. [Controllers](#controllers)
8. [Routes](#routes)
9. [Key Features Implementation](#key-features-implementation)
10. [Setup Instructions](#setup-instructions)
11. [Development Workflow](#development-workflow)
12. [Known Issues](#known-issues)

---

## Project Overview

**Job Tracker** is a Ruby on Rails web application designed to help job seekers organize and manage their job applications. The application provides a centralized platform to track job opportunities, monitor application statuses, upload and manage resumes, and visualize job search progress through an interactive dashboard.

### Purpose
- Track job applications in one place
- Monitor application statuses (pending, interview, rejected)
- Manage multiple resumes with text extraction capabilities
- Visualize job search analytics and trends
- Maintain user profiles with location information

---

## System Architecture

### Application Type
- **Framework**: Ruby on Rails 8.0.2
- **Pattern**: MVC (Model-View-Controller)
- **Architecture**: Monolithic web application
- **Database**: PostgreSQL
- **Authentication**: Devise gem

### Key Components
1. **User Management**: Authentication and profile management
2. **Job Tracking**: CRUD operations for job applications
3. **Resume Management**: File upload and text extraction
4. **Dashboard**: Analytics and visualization
5. **Active Storage**: File attachment handling

---

## Technology Stack

### Backend
- **Ruby Version**: 3.4.4
- **Rails Version**: 8.0.2
- **Database**: PostgreSQL (pg gem ~> 1.1)
- **Web Server**: Puma (>= 5.0)

### Frontend
- **CSS Framework**: Tailwind CSS (tailwindcss-rails)
- **JavaScript**: 
  - Hotwire (Turbo Rails & Stimulus)
  - Import maps for ESM
- **Charts**: Chartkick (~> 5.2) with Groupdate (~> 6.7)

### Authentication & Authorization
- **Devise**: User authentication (registration, login, password recovery)

### File Processing
- **Active Storage**: File attachments
- **PDF Reader**: Extract text from PDF resumes
- **Docx**: Extract text from Word documents

### Additional Gems
- **Propshaft**: Modern asset pipeline
- **Jbuilder**: JSON API building
- **Solid Cache/Queue/Cable**: Database-backed adapters
- **Bootsnap**: Boot time optimization

### Development Tools
- **Brakeman**: Security vulnerability scanning
- **Rubocop Rails Omakase**: Code styling
- **Web Console**: Exception debugging
- **Debug**: Debugging support

### Testing
- **Capybara**: Integration testing
- **Selenium WebDriver**: Browser automation

### Deployment
- **Kamal**: Docker container deployment
- **Thruster**: HTTP caching/compression for Puma
- **Docker**: Containerization support

---

## Database Schema

### Tables Overview

#### 1. **users**
User authentication and profile information.

| Column                  | Type     | Description                    |
|------------------------|----------|--------------------------------|
| id                     | bigint   | Primary key                    |
| email                  | string   | Unique email (required)        |
| encrypted_password     | string   | Hashed password                |
| reset_password_token   | string   | Password reset token           |
| reset_password_sent_at | datetime | Token sent timestamp           |
| remember_created_at    | datetime | Remember me timestamp          |
| city                   | string   | User's city                    |
| address                | string   | User's address                 |
| created_at             | datetime | Record creation time           |
| updated_at             | datetime | Record update time             |

**Indexes**: email (unique), reset_password_token (unique)

#### 2. **jobs**
Job applications tracked by users.

| Column      | Type     | Description                          |
|-------------|----------|--------------------------------------|
| id          | bigint   | Primary key                          |
| title       | string   | Job title (required)                 |
| company     | string   | Company name (required)              |
| location    | string   | Job location (required)              |
| description | text     | Job description                      |
| status      | string   | Application status                   |
| applied_on  | date     | Date applied                         |
| notes       | text     | Additional notes                     |
| user_id     | bigint   | Foreign key to users                 |
| created_at  | datetime | Record creation time                 |
| updated_at  | datetime | Record update time                   |

**Foreign Keys**: user_id → users.id  
**Status Values**: "pending", "interview", "rejected"

#### 3. **resumes**
Resume files uploaded by users.

| Column         | Type     | Description                    |
|----------------|----------|--------------------------------|
| id             | bigint   | Primary key                    |
| title          | string   | Resume title                   |
| file_url       | string   | Legacy file URL field          |
| extracted_text | text     | Extracted text from resume     |
| user_id        | bigint   | Foreign key to users           |
| created_at     | datetime | Record creation time           |
| updated_at     | datetime | Record update time             |

**Foreign Keys**: user_id → users.id  
**Note**: Uses Active Storage for file attachments (not file_url)

#### 4. **applications**
Links jobs, resumes, and users (currently not actively used in controllers).

| Column       | Type     | Description              |
|--------------|----------|--------------------------|
| id           | bigint   | Primary key              |
| status       | string   | Application status       |
| applied_date | date     | Date applied             |
| user_id      | bigint   | Foreign key to users     |
| job_id       | bigint   | Foreign key to jobs      |
| resume_id    | bigint   | Foreign key to resumes   |
| created_at   | datetime | Record creation time     |
| updated_at   | datetime | Record update time       |

**Foreign Keys**: user_id → users.id, job_id → jobs.id, resume_id → resumes.id

#### 5. **Active Storage Tables**
Rails Active Storage for file uploads:
- `active_storage_attachments`: Links files to records
- `active_storage_blobs`: Stores file metadata
- `active_storage_variant_records`: Image variant tracking

---

## Application Features

### 1. **User Authentication**
- User registration with email/password
- Login/logout functionality
- Password recovery
- Remember me functionality
- Authenticated routes protection

### 2. **Job Management**
- Create new job applications
- View all jobs (sorted by creation date, descending)
- Edit job details
- Delete job applications
- Track job status (pending, interview, rejected)
- Record application date
- Add notes to jobs
- View jobs by status distribution

### 3. **Resume Management**
- Upload resume files (PDF, DOCX)
- Automatic text extraction from uploaded resumes
- View extracted resume text
- Multiple resume support per user

### 4. **Dashboard Analytics**
- Total jobs count
- Jobs by status breakdown
  - Interview count
  - Pending count
  - Rejected count
- Jobs grouped by status visualization
- Jobs over time tracking (grouped by date)

### 5. **User Profile**
- Edit profile information
- Update city and address
- Profile management

---

## Models

### User Model
**File**: `app/models/user.rb`

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :jobs, dependent: :destroy
  has_many :resumes, dependent: :destroy
end
```

**Associations**:
- Has many jobs (cascade delete)
- Has many resumes (cascade delete)

**Devise Modules**:
- `:database_authenticatable` - Login with email/password
- `:registerable` - User signup
- `:recoverable` - Password reset
- `:rememberable` - Remember me cookie
- `:validatable` - Email/password validation

---

### Job Model
**File**: `app/models/job.rb`

```ruby
class Job < ApplicationRecord
  belongs_to :user
  validates :title, :company, :location, presence: true
end
```

**Associations**:
- Belongs to user

**Validations**:
- Title, company, and location must be present

---

### Resume Model
**File**: `app/models/resume.rb`

```ruby
class Resume < ApplicationRecord
  belongs_to :user
  has_one_attached :file
end
```

**Associations**:
- Belongs to user
- Has one attached file (via Active Storage)

**Storage**: Uses Active Storage for file management

---

### Application Model
**File**: `app/models/application.rb`

```ruby
class Application < ApplicationRecord
  belongs_to :user
  belongs_to :job
  belongs_to :resume
end
```

**Associations**:
- Belongs to user
- Belongs to job
- Belongs to resume

**Note**: This model is defined but not currently utilized in the application controllers.

---

## Controllers

### ApplicationController
**File**: `app/controllers/application_controller.rb`

Base controller for all application controllers. Inherits from `ActionController::Base`.

---

### JobsController
**File**: `app/controllers/jobs_controller.rb`

Manages job application CRUD operations.

**Before Actions**:
- `authenticate_user!` - Requires login for all actions
- `set_job` - Loads job for show, edit, update, destroy

**Actions**:

#### `index`
- Lists all jobs for current user (newest first)
- Counts jobs grouped by status
- **Instance Variables**: `@jobs`, `@jobs_by_status`

#### `show`
- Displays single job details
- **Instance Variables**: `@job`

#### `new`
- Renders form for new job
- **Instance Variables**: `@job`

#### `create`
- Creates new job for current user
- **Success**: Redirects to jobs index with success notice
- **Failure**: Re-renders form with error message
- **Permitted Params**: title, company, location, description, status, applied_on

#### `edit`
- Renders form to edit existing job
- **Instance Variables**: `@job`

#### `update`
- Updates existing job
- **Success**: Redirects to jobs index with success notice
- **Failure**: Re-renders edit form with error alert
- **Permitted Params**: title, company, location, description, status, applied_on

#### `destroy`
- Deletes job
- **Success**: Redirects to jobs index with success notice

**Private Methods**:
- `set_job` - Finds job by ID scoped to current user
- `job_params` - Strong parameters for job attributes

---

### DashboardController
**File**: `app/controllers/dashboard_controller.rb`

Displays analytics and statistics for job applications.

**Before Actions**:
- `authenticate_user!` - Requires login

**Actions**:

#### `index`
- Calculates job statistics
- Groups jobs by status
- Groups jobs by creation date
- **Instance Variables**:
  - `@jobs_by_status` - Hash of status counts
  - `@jobs_by_time` - Hash of jobs grouped by date
  - `@total_jobs` - Total count
  - `@interview_jobs` - Interview status count
  - `@pending_jobs` - Pending status count
  - `@rejected_jobs` - Rejected status count

---

### ResumesController
**File**: `app/controllers/resumes_controller.rb`

Manages resume uploads and text extraction.

**Before Actions**:
- `authenticate_user!` - Requires login
- `set_resume` - Loads resume for show, edit, update, destroy
- `autorize_user!` - Authorization check (method defined but not shown)

**Actions**:

#### `new`
- Renders form for new resume upload
- **Instance Variables**: `@resume`

#### `create`
- Creates new resume for current user
- Uploads file via Active Storage
- Extracts text from uploaded file
- **Success**: Redirects to resume show page with success notice
- **Failure**: Re-renders new form
- **Permitted Params**: file

#### `show`
- Displays resume details and extracted text
- **Instance Variables**: `@resume`

**Private Methods**:

#### `resume_params`
- Strong parameters for resume file

#### `extract_text(file)`
- Extracts text from uploaded resume
- **Supported Formats**: PDF, DOCX
- **PDF Extraction**: Uses PDF::Reader gem
- **DOCX Extraction**: Uses Docx gem
- **Returns**: Extracted text or "Unsupported file type"
- **Implementation**: Accesses file from Active Storage blob service

---

### ProfilesController
**File**: `app/controllers/profiles_controller.rb`

Manages user profile updates.

**Before Actions**:
- `authenticate_user!` - Requires login

**Actions**:

#### `edit`
- Renders profile edit form
- **Instance Variables**: `@user` (current_user)

#### `update`
- Updates user profile
- **Success**: Redirects to root path with success notice
- **Failure**: Re-renders edit form
- **Permitted Params**: city, address

**Known Issues**:
- Line 11: `rooth_path` should be `root_path` (typo)
- Line 19: `params.require(:uder)` should be `:user` (typo)

---

## Routes

**File**: `config/routes.rb`

```ruby
Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index"
  resources :jobs
  devise_for :users
  resource :profile, only: [:edit, :update]
  root "jobs#index"
  resources :resumes
  get "up" => "rails/health#show", as: :rails_health_check  
end
```

### Route Breakdown

| HTTP Method | Path                     | Controller#Action      | Purpose                        |
|-------------|--------------------------|------------------------|--------------------------------|
| GET         | /                        | jobs#index             | Root - Jobs listing            |
| GET         | /dashboard               | dashboard#index        | Analytics dashboard            |
| GET         | /jobs                    | jobs#index             | List all jobs                  |
| GET         | /jobs/new                | jobs#new               | New job form                   |
| POST        | /jobs                    | jobs#create            | Create job                     |
| GET         | /jobs/:id                | jobs#show              | Show job details               |
| GET         | /jobs/:id/edit           | jobs#edit              | Edit job form                  |
| PATCH/PUT   | /jobs/:id                | jobs#update            | Update job                     |
| DELETE      | /jobs/:id                | jobs#destroy           | Delete job                     |
| GET         | /resumes                 | resumes#index          | List resumes                   |
| GET         | /resumes/new             | resumes#new            | New resume form                |
| POST        | /resumes                 | resumes#create         | Upload resume                  |
| GET         | /resumes/:id             | resumes#show           | Show resume                    |
| GET         | /resumes/:id/edit        | resumes#edit           | Edit resume                    |
| PATCH/PUT   | /resumes/:id             | resumes#update         | Update resume                  |
| DELETE      | /resumes/:id             | resumes#destroy        | Delete resume                  |
| GET         | /profile/edit            | profiles#edit          | Edit profile form              |
| PATCH/PUT   | /profile                 | profiles#update        | Update profile                 |
| GET         | /users/sign_up           | devise/registrations   | User registration              |
| POST        | /users                   | devise/registrations   | Create user account            |
| GET         | /users/sign_in           | devise/sessions        | Login page                     |
| POST        | /users/sign_in           | devise/sessions        | Login action                   |
| DELETE      | /users/sign_out          | devise/sessions        | Logout                         |
| GET         | /users/password/new      | devise/passwords       | Forgot password                |
| POST        | /users/password          | devise/passwords       | Send reset instructions        |
| GET         | /users/password/edit     | devise/passwords       | Reset password form            |
| PATCH/PUT   | /users/password          | devise/passwords       | Update password                |
| GET         | /up                      | rails/health#show      | Health check endpoint          |

---

## Key Features Implementation

### 1. Resume Text Extraction

The application extracts text from uploaded resumes to enable searchability and analysis.

**Workflow**:
1. User uploads resume file (PDF or DOCX)
2. File is saved via Active Storage
3. `extract_text` method is called
4. Text is extracted based on file type
5. Extracted text is saved to `resumes.extracted_text`

**Code** (`ResumesController#extract_text`):
```ruby
def extract_text(file)
  return unless file.attached?
  
  path = ActiveStorage::Blob.service.send(:path_for, file.key)
  ext = File.extname(file.filename.to_s).downcase
  
  case ext
  when ".pdf"
    reader = PDF::Reader.new(path)
    reader.pages.map(&:text).join("\n")
  when ".docx"
    doc = Docx::Document.open(path)
    doc.paragraphs.map(&:text).join("\n")
  else
    "Unsupported file type"
  end
end
```

### 2. Dashboard Analytics

Provides visual insights into job application progress.

**Metrics Calculated**:
- Total jobs applied
- Jobs by status (pending, interview, rejected)
- Jobs over time (grouped by creation date)

**Implementation** (`DashboardController#index`):
```ruby
@jobs_by_status = current_user.jobs.group(:status).count
@jobs_by_time = current_user.jobs
                  .group_by { |job| job.created_at.to_date }
                  .transform_values(&:count)
@total_jobs = current_user.jobs.count
@interview_jobs = current_user.jobs.where(status: "interview").count
@pending_jobs = current_user.jobs.where(status: "pending").count
@rejected_jobs = current_user.jobs.where(status: "rejected").count
```

### 3. User-Scoped Data

All data is scoped to the authenticated user ensuring data privacy.

**Example** (Jobs):
```ruby
@jobs = current_user.jobs.order(created_at: :desc)
@job = current_user.jobs.find(params[:id])
@job = current_user.jobs.build(job_params)
```

### 4. Active Storage Integration

Uses Rails Active Storage for file handling:
- Database-backed file metadata
- Local disk storage (configurable)
- Direct file uploads
- Automatic file serving

---

## Setup Instructions

### Prerequisites
- Ruby 3.4.4
- PostgreSQL
- Node.js (for JavaScript dependencies)
- Bundler gem

### Installation Steps

1. **Clone the repository**
   ```bash
   cd /mnt/d/JobSeeker/job_tracker
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Install JavaScript dependencies** (if applicable)
   ```bash
   npm install
   # or
   yarn install
   ```

4. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

5. **Configure environment variables**
   Create `.env` file or configure environment:
   - Database credentials
   - Secret key base
   - Any API keys

6. **Precompile assets** (production)
   ```bash
   rails assets:precompile
   ```

7. **Start the server**
   ```bash
   rails server
   # or for development with Procfile
   bin/dev
   ```

8. **Access the application**
   - Open browser: `http://localhost:3000`
   - Create an account
   - Start tracking jobs!

### Database Configuration
Edit `config/database.yml` with your PostgreSQL credentials:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: job_tracker_development
  username: your_username
  password: your_password
```

---

## Development Workflow

### Running Tests
```bash
rails test
rails test:system
```

### Console Access
```bash
rails console
```

### Database Operations
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Reset database
rails db:reset

# Seed data
rails db:seed
```

### Code Quality
```bash
# Run Rubocop
rubocop

# Security scan
brakeman
```

### Docker Deployment (Kamal)
```bash
kamal setup
kamal deploy
```

---

## Known Issues

### 1. ProfilesController Typos
**File**: `app/controllers/profiles_controller.rb`

- **Line 11**: `rooth_path` should be `root_path`
- **Line 19**: `params.require(:uder)` should be `:user`

**Fix**:
```ruby
# Line 11
redirect_to root_path, notice: "Profile updated successfully"

# Line 19
params.require(:user).permit(:city, :address)
```

### 2. Missing Authorization Method
**File**: `app/controllers/resumes_controller.rb`
- **Line 4**: `autorize_user!` is called but not defined
- Should either be implemented or removed

### 3. Application Model Not Used
The `Application` model exists but is not used in any controller logic. Consider:
- Implementing proper application tracking using this model
- Removing if not needed

### 4. Job Status Validation
Job status field accepts any string value. Consider:
- Adding enum or validation for allowed status values
- Ensuring consistency ("pending", "interview", "rejected")

### 5. Missing Error Handling
Resume upload doesn't handle:
- File size limits
- Invalid file types
- Extraction errors gracefully

### 6. Incomplete Resume CRUD
ResumesController only implements `new`, `create`, and `show`:
- Missing `index` to list all resumes
- Missing `edit` and `update` actions
- Missing `destroy` action

---

## Future Enhancements

### Suggested Features
1. **Email Notifications**: Remind users about follow-ups
2. **Resume Comparison**: Compare resume text against job descriptions
3. **Application Timeline**: Visual timeline of application progress
4. **Notes & Attachments**: Add cover letters, communications
5. **Search & Filter**: Search jobs by company, title, status
6. **Export Data**: Export to CSV/PDF for reporting
7. **Analytics Charts**: Visual charts using Chartkick
8. **Application Tracking**: Full implementation of Application model
9. **Deadlines**: Track application deadlines and interview dates
10. **Tags/Categories**: Organize jobs by industry, type, etc.

---

## Database Migrations History

| Date       | Migration                                    | Purpose                              |
|------------|----------------------------------------------|--------------------------------------|
| 2025-09-22 | 20250922203956_create_jobs                   | Create jobs table                    |
| 2025-09-22 | 20250922204942_create_applications           | Create applications table            |
| 2025-09-22 | 20250922205414_create_resumes                | Create resumes table                 |
| 2025-09-22 | 20250922210414_devise_create_users           | Add Devise authentication            |
| 2025-10-02 | 20251002163305_rename_applied_data...        | Fix column name typo                 |
| 2025-10-04 | 20251004210955_fix_applied_on_column...      | Fix applied_on column                |
| 2025-10-13 | 20251013141139_add_city_and_address...       | Add location fields to users         |
| 2025-10-17 | 20251017184346_create_active_storage_tables  | Add Active Storage support           |
| 2025-10-20 | 20251020110013_add_extracted_text...         | Add text extraction field to resumes |
| 2025-11-15 | 20251115190102_add_notes_to_jobs             | Add notes field to jobs              |

---

## Contact & Support

For questions or issues with this application, contact the development team or refer to the project repository.

---

## License

[Specify your license here]

---

**Last Updated**: November 24, 2025  
**Version**: 1.0  
**Ruby Version**: 3.4.4  
**Rails Version**: 8.0.2
