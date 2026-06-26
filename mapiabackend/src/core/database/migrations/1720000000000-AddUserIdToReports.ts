import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserIdToReports1720000000000 implements MigrationInterface {
  name = 'AddUserIdToReports1720000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "reports"
      ADD COLUMN IF NOT EXISTS "user_id" uuid;
    `);

    await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'fk_reports_user'
        ) THEN
          ALTER TABLE "reports"
          ADD CONSTRAINT "fk_reports_user"
          FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL;
        END IF;
      END $$;
    `);

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_reports_user_id" ON "reports" ("user_id");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "idx_reports_user_id";`);
    await queryRunner.query(
      `ALTER TABLE "reports" DROP CONSTRAINT IF EXISTS "fk_reports_user";`,
    );
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN IF EXISTS "user_id";`);
  }
}
