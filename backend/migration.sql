-- migration.sql
-- This script sets up the initial database schema.

-- Drop tables if they exist (useful for re-running during development)
DROP TABLE IF EXISTS communities CASCADE;

-- Create communities table
CREATE TABLE communities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Add more tables below if needed (users, products, etc.)
