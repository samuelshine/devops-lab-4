-- runs once, only when the pgdata volume is empty
CREATE TABLE IF NOT EXISTS notes (
  id         SERIAL PRIMARY KEY,
  text       TEXT NOT NULL,
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO notes (text, created_by) VALUES ('Seed note from db/init.sql', 'init.sql');
