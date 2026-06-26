import type { MigrationInterface, QueryRunner } from 'typeorm';

export class ReportCandidates1740000000000 implements MigrationInterface {
  name = 'ReportCandidates1740000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`);
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "report_candidates" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        "post_id" uuid NOT NULL,
        "title" text NOT NULL,
        "summary" text,
        "category" text NOT NULL,
        "status" text NOT NULL DEFAULT 'pendiente_revision',
        "priority" text NOT NULL DEFAULT 'media',
        "location_text" text,
        "lat" double precision,
        "lng" double precision,
        "evidence_urls" text[] NOT NULL DEFAULT '{}',
        "citizen_support_count" integer NOT NULL DEFAULT 0,
        "comments_count" integer NOT NULL DEFAULT 0,
        "ai_summary" text,
        "suggested_solution" text,
        "reviewed_by" uuid,
        "reviewed_at" timestamptz,
        "rejection_reason" text,
        CONSTRAINT "pk_report_candidates" PRIMARY KEY ("id"),
        CONSTRAINT "uq_report_candidates_post" UNIQUE ("post_id"),
        CONSTRAINT "fk_report_candidates_post" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
        CONSTRAINT "fk_report_candidates_reviewer" FOREIGN KEY ("reviewed_by") REFERENCES "users"("id") ON DELETE SET NULL,
        CONSTRAINT "chk_report_candidates_status" CHECK ("status" IN ('pendiente_revision','aprobado_para_informe','rechazado','incluido_en_informe','enviado','resuelto')),
        CONSTRAINT "chk_report_candidates_priority" CHECK ("priority" IN ('baja','media','alta','urgente')),
        CONSTRAINT "chk_report_candidates_category" CHECK ("category" IN ('bloqueo','corte_servicio','basura','bache','alumbrado','transporte','seguridad','evento','venta_irregular','otro_problema_urbano'))
      );
    `);
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_report_candidates_status" ON "report_candidates" ("status");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_report_candidates_category" ON "report_candidates" ("category");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_report_candidates_post" ON "report_candidates" ("post_id");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "report_candidates";`);
  }
}
