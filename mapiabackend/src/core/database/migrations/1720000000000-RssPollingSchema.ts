import type { MigrationInterface, QueryRunner } from 'typeorm';

export class RssPollingSchema1720000000000 implements MigrationInterface {
  name = 'RssPollingSchema1720000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "rss_news_items" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        "title" text NOT NULL,
        "url" text NOT NULL,
        "source" text NOT NULL,
        "description" text,
        "published_at" timestamptz,
        "detected_at" timestamptz NOT NULL DEFAULT now(),
        "hash" text,
        CONSTRAINT "pk_rss_news_items" PRIMARY KEY ("id"),
        CONSTRAINT "uq_rss_news_items_url" UNIQUE ("url"),
        CONSTRAINT "uq_rss_news_items_hash" UNIQUE ("hash")
      );
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "generated_news_posts" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "created_at" timestamptz NOT NULL DEFAULT now(),
        "updated_at" timestamptz NOT NULL DEFAULT now(),
        "news_item_id" uuid,
        "title" text NOT NULL,
        "content" text NOT NULL,
        "source" text NOT NULL,
        "original_url" text NOT NULL,
        "category" text NOT NULL DEFAULT 'novedad',
        "status" text NOT NULL DEFAULT 'published',
        "generated_by" text NOT NULL DEFAULT 'rss_polling',
        "is_ai_generated" boolean NOT NULL DEFAULT false,
        CONSTRAINT "pk_generated_news_posts" PRIMARY KEY ("id"),
        CONSTRAINT "fk_generated_news_posts_news_item" FOREIGN KEY ("news_item_id") REFERENCES "rss_news_items"("id") ON DELETE SET NULL
      );
    `);

    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_rss_news_items_url" ON "rss_news_items" ("url");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_rss_news_items_hash" ON "rss_news_items" ("hash");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_generated_news_posts_news_item" ON "generated_news_posts" ("news_item_id");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_generated_news_posts_category" ON "generated_news_posts" ("category");`,
    );
    await queryRunner.query(
      `CREATE INDEX IF NOT EXISTS "idx_generated_news_posts_status" ON "generated_news_posts" ("status");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "generated_news_posts";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "rss_news_items";`);
  }
}
