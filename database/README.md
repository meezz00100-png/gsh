# Database Setup for Harari Prosperity App

This directory contains the database schema and setup instructions for the Harari Prosperity App report functionality.

## Prerequisites

- Supabase project set up and configured
- Supabase CLI installed (optional, for local development)
- Database access through Supabase Dashboard

## Setup Instructions

### 1. Create Reports Table

Execute the SQL script in `reports_table.sql` in your Supabase SQL Editor:

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of `reports_table.sql`
4. Click "Run" to execute the script

This will create:
- `reports` table with all necessary columns
- Indexes for optimal query performance
- Row Level Security (RLS) policies
- Storage bucket for file attachments
- Storage policies for secure file access
- Automatic timestamp updates

### 2. Verify Setup

After running the script, verify the setup:

1. Check that the `reports` table exists in the Table Editor
2. Verify that RLS is enabled on the table
3. Confirm that the `report-attachments` storage bucket exists
4. Test that policies are working by creating a test report

### 3. Environment Configuration

Make sure your Supabase configuration is properly set in:
- `lib/shared/config/supabase_config.dart`

### Table Schema

The `reports` table includes the following main sections:

#### Basic Information
- `name`: Report title/name
- `report_type`: Type of report
- `type`: Additional type classification
- `receiver_name`: Report recipient
- `objective`: Report objective
- `description`: Report description

#### Content Fields
- `importance`: Importance explanation
- `main_points`: Main points
- `sources`: Information sources
- `roles`: Roles of actors and stakeholders
- `trends`: Positive and negative trends
- `themes`: Taken themes
- `implications`: Implications and conclusions
- `scenarios`: Scenarios
- `future_plans`: Future plans and activities

#### Metadata
- `approving_body`: Report approving body
- `sender_name`: Sender name
- `role`: Sender role
- `date`: Report date
- `attachments`: Array of file URLs
- `link_attachment`: Link attachment
- `status`: Report status (draft/completed)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

### Security

The database implements Row Level Security (RLS) to ensure:
- Users can only access their own reports
- File attachments are private to each user
- All operations are properly authenticated

### File Storage

File attachments are stored in the `report-attachments` bucket with the following structure:
```
report-attachments/
├── {user_id}/
│   ├── {report_id}/
│   │   ├── file1.pdf
│   │   ├── file2.docx
│   │   └── ...
```

This ensures proper organization and security of uploaded files.
