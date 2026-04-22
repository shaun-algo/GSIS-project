-- Migration: Add enhancements to announcements table
-- Date: 2025-01-XX
-- Description: Adds support for pinned announcements and attachments

-- Add is_pinned column if it doesn't exist
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS is_pinned TINYINT(1) DEFAULT 0 COMMENT 'Whether announcement is pinned to top';

-- Add attachment_url column if it doesn't exist
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS attachment_url VARCHAR(500) DEFAULT NULL COMMENT 'URL to attached file or image';

-- Add index for better performance on pinned queries
CREATE INDEX IF NOT EXISTS idx_is_pinned ON announcements(is_pinned);

-- Add index for faster sorting by published date
CREATE INDEX IF NOT EXISTS idx_published_at ON announcements(published_at);
