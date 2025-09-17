-- Create reports table for Harari Prosperity App
-- This table stores all report data including form fields and metadata

CREATE TABLE IF NOT EXISTS reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Basic report information
    name TEXT NOT NULL DEFAULT '',
    report_type TEXT NOT NULL DEFAULT '',
    type TEXT NOT NULL DEFAULT '',
    receiver_name TEXT NOT NULL DEFAULT '',
    objective TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    
    -- Report content fields
    importance TEXT NOT NULL DEFAULT '',
    main_points TEXT NOT NULL DEFAULT '',
    sources TEXT NOT NULL DEFAULT '',
    roles TEXT NOT NULL DEFAULT '',
    trends TEXT NOT NULL DEFAULT '',
    themes TEXT NOT NULL DEFAULT '',
    implications TEXT NOT NULL DEFAULT '',
    scenarios TEXT NOT NULL DEFAULT '',
    future_plans TEXT NOT NULL DEFAULT '',
    
    -- Report metadata
    approving_body TEXT NOT NULL DEFAULT '',
    sender_name TEXT NOT NULL DEFAULT '',
    role TEXT NOT NULL DEFAULT '',
    date TEXT NOT NULL DEFAULT '',
    
    -- Attachments
    attachments TEXT[] DEFAULT '{}',
    link_attachment TEXT,
    
    -- Status and timestamps
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'completed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_user_status ON reports(user_id, status);

-- Enable Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own reports
CREATE POLICY "Users can view their own reports" ON reports
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own reports
CREATE POLICY "Users can insert their own reports" ON reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reports
CREATE POLICY "Users can update their own reports" ON reports
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own reports
CREATE POLICY "Users can delete their own reports" ON reports
    FOR DELETE USING (auth.uid() = user_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_reports_updated_at 
    BEFORE UPDATE ON reports 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for report attachments (if not exists)
INSERT INTO storage.buckets (id, name, public)
VALUES ('report-attachments', 'report-attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies for report attachments
CREATE POLICY "Users can upload their own report attachments" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'report-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view their own report attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'report-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update their own report attachments" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'report-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete their own report attachments" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'report-attachments' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
