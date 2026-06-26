-- ============================================================
-- Mapia: citizen reports tables + user_id FK (run after initial schema)
-- Safe to run multiple times (idempotent).
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS "reports" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid,
  "title" text NOT NULL,
  "description" text,
  "product" text,
  "alert_type" text NOT NULL,
  "severity" text NOT NULL,
  "latitude" double precision NOT NULL,
  "longitude" double precision NOT NULL,
  "department" text,
  "municipality" text,
  "zone" text,
  "price" numeric,
  "source_text" text,
  "confidence" numeric,
  "status" text NOT NULL DEFAULT 'active',
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_reports" PRIMARY KEY ("id"),
  CONSTRAINT "chk_reports_severity" CHECK ("severity" IN ('normal', 'low', 'medium', 'high')),
  CONSTRAINT "chk_reports_bolivia_bounds" CHECK (
    "latitude" >= -22.9 AND "latitude" <= -9.6 AND
    "longitude" >= -69.7 AND "longitude" <= -57.4
  )
);

ALTER TABLE "reports" ADD COLUMN IF NOT EXISTS "user_id" uuid;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_reports_user') THEN
    ALTER TABLE "reports"
    ADD CONSTRAINT "fk_reports_user"
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS "report_images" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "report_id" uuid NOT NULL,
  "url" text NOT NULL,
  "path" text,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT "pk_report_images" PRIMARY KEY ("id"),
  CONSTRAINT "fk_report_images_report" FOREIGN KEY ("report_id") REFERENCES "reports"("id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "idx_reports_location" ON "reports" ("latitude", "longitude");
CREATE INDEX IF NOT EXISTS "idx_reports_department" ON "reports" ("department");
CREATE INDEX IF NOT EXISTS "idx_reports_product" ON "reports" ("product");
CREATE INDEX IF NOT EXISTS "idx_reports_alert_type" ON "reports" ("alert_type");
CREATE INDEX IF NOT EXISTS "idx_reports_severity" ON "reports" ("severity");
CREATE INDEX IF NOT EXISTS "idx_reports_created_at" ON "reports" ("created_at");
CREATE INDEX IF NOT EXISTS "idx_reports_user_id" ON "reports" ("user_id");
CREATE INDEX IF NOT EXISTS "idx_report_images_report" ON "report_images" ("report_id");

INSERT INTO "mapia_migrations" ("timestamp", "name")
VALUES (1710000000000, 'AlertReports1710000000000')
ON CONFLICT DO NOTHING;

INSERT INTO "mapia_migrations" ("timestamp", "name")
VALUES (1720000000000, 'AddUserIdToReports1720000000000')
ON CONFLICT DO NOTHING;
