-- Finite App Database Schema
-- Run this in your Supabase SQL Editor

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  apple_id TEXT UNIQUE NOT NULL,
  productive_years_remaining INTEGER NOT NULL DEFAULT 30,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- GOALS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  why_it_matters TEXT,
  what_youll_regret TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries by user
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_deadline ON goals(deadline);

-- ============================================
-- BLOCKED APPS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS blocked_apps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  app_bundle_id TEXT NOT NULL,
  app_name TEXT,
  is_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_blocked_apps_user_id ON blocked_apps(user_id);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_apps ENABLE ROW LEVEL SECURITY;

-- Users policies (allowing all operations for now - can be tightened later)
CREATE POLICY "Allow all operations on users" ON users
  FOR ALL USING (true) WITH CHECK (true);

-- Goals policies
CREATE POLICY "Allow all operations on goals" ON goals
  FOR ALL USING (true) WITH CHECK (true);

-- Blocked apps policies
CREATE POLICY "Allow all operations on blocked_apps" ON blocked_apps
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- OPTIONAL: Sample notification messages table
-- (For future use if you want to store messages in DB)
-- ============================================
-- CREATE TABLE IF NOT EXISTS notification_messages (
--   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   category TEXT NOT NULL, -- 'time_decay', 'year_progress', 'sunk_cost', 'life_context'
--   template TEXT NOT NULL,
--   is_active BOOLEAN DEFAULT TRUE,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );

-- ============================================
-- VERIFY TABLES
-- ============================================
-- Run these to verify setup:
-- SELECT * FROM users LIMIT 1;
-- SELECT * FROM goals LIMIT 1;
-- SELECT * FROM blocked_apps LIMIT 1;
