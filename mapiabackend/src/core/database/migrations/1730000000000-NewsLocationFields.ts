import type { MigrationInterface, QueryRunner } from 'typeorm';

export class NewsLocationFields1730000000000 implements MigrationInterface {
  name = 'NewsLocationFields1730000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "location_text" text;`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "lat" double precision;`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "lng" double precision;`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "category" text;`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "created_by" text;`);
    await queryRunner.query(
      `ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "location_status" text NOT NULL DEFAULT 'pending';`,
    );
    await queryRunner.query(`ALTER TABLE "rss_news_items" ADD COLUMN IF NOT EXISTS "geocoding_error" text;`);
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_rss_news_items_today" ON "rss_news_items" ("published_at", "created_at");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_rss_news_items_location" ON "rss_news_items" ("lat", "lng");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS "idx_rss_news_items_location";`);
    await queryRunner.query(`DROP INDEX IF EXISTS "idx_rss_news_items_today";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "geocoding_error";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "location_status";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "created_by";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "category";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "lng";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "lat";`);
    await queryRunner.query(`ALTER TABLE "rss_news_items" DROP COLUMN IF EXISTS "location_text";`);
  }
}
