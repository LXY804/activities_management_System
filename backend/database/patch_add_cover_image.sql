-- Patch: ensure activities table has cover_image column for cover URLs
ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS cover_image VARCHAR(255) NULL AFTER organizer_id;

-- Optional: initialize existing rows with NULL so API fallback logic works
UPDATE activities SET cover_image = NULL WHERE cover_image IS NULL;
