import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RssNewsItem } from './entities/rss-news-item.entity';
import { XMLParser } from 'fast-xml-parser';
import * as crypto from 'crypto';
import { NewsClassifierService } from './news-classifier.service';

interface MappedNewsItem {
  title: string;
  source: string;
  url: string;
  publishedAt?: string;
  description?: string;
  hash: string;
}

@Injectable()
export class RssPollingService {
  private readonly logger = new Logger(RssPollingService.name);

  // Fuentes RSS configuradas centralizadamente
  // NOTE: eldeber.com.bo/rss devuelve HTML — la URL correcta es /feed
  private readonly sources = [
    {
      name: 'El Deber',
      primaryUrl: 'https://eldeber.com.bo/feed',
      fallbackUrl: 'https://www.eldeber.com.bo/feed',
    },
  ];

  private readonly parser = new XMLParser({
    ignoreAttributes: false,
    trimValues: true,
    cdataPropName: '__cdata',     // preservar contenido CDATA
    allowBooleanAttributes: true,
  });

  constructor(
    @InjectRepository(RssNewsItem)
    private readonly newsItemRepository: Repository<RssNewsItem>,
    private readonly newsClassifierService: NewsClassifierService,
  ) {}

  async pollAllSources(): Promise<RssNewsItem[]> {
    const allNewItems: RssNewsItem[] = [];

    for (const source of this.sources) {
      try {
        const items = await this.pollSource(source);
        allNewItems.push(...items);
      } catch (error) {
        this.logger.error(`Error al revisar fuente ${source.name}: ${error.message}`);
      }
    }

    return allNewItems;
  }

  private async pollSource(source: { name: string; primaryUrl: string; fallbackUrl: string }): Promise<RssNewsItem[]> {
    let xml: string | null = null;
    let lastError: any = null;

    for (const url of [source.primaryUrl, source.fallbackUrl]) {
      try {
        xml = await this.fetchXml(url);
        if (xml) {
          this.logger.log(`XML obtenido exitosamente de ${url} (${xml.length} bytes)`);
          break;
        }
      } catch (error) {
        this.logger.warn(`Error al obtener de ${url}: ${error.message}`);
        lastError = error;
      }
    }

    if (!xml) {
      throw new Error(`No se pudo leer el RSS de ${source.name}. Detalle: ${lastError?.message || lastError}`);
    }

    const parsed = this.parser.parse(xml) as {
      rss?: { channel?: { item?: unknown } };
    };

    const rawItems = parsed.rss?.channel?.item;
    const items = Array.isArray(rawItems) ? rawItems : rawItems ? [rawItems] : [];
    this.logger.log(`Total de noticias parseadas de ${source.name}: ${items.length}`);

    const newItems: RssNewsItem[] = [];
    const mappedItems: MappedNewsItem[] = [];

    for (const item of items) {
      const mapped = this.mapToNewsItem(item, source.name);
      if (mapped) {
        mappedItems.push(mapped);
      }
    }

    const classifications = await this.newsClassifierService.classifyItems(
      mappedItems.map((item) => ({
        title: item.title,
        url: item.url,
        description: item.description,
        source: item.source,
      })),
    );

    for (const [index, mapped] of mappedItems.entries()) {
      const classification = classifications[index];
      if (!classification?.isBoliviaRelevant) {
        this.logger.log(`Se descarta noticia por no ser relevante para Bolivia: ${mapped.title}`);
        continue;
      }

      // Evitar duplicados por url o hash
      const exists = await this.newsItemRepository.findOne({
        where: [{ url: mapped.url }, { hash: mapped.hash }],
      });

      if (!exists) {
        const saved = await this.newsItemRepository.save(
          this.newsItemRepository.create({
            title: mapped.title,
            url: mapped.url,
            source: mapped.source,
            description: mapped.description || null,
            publishedAt: mapped.publishedAt ? new Date(mapped.publishedAt) : null,
            hash: mapped.hash,
          }),
        );
        newItems.push(saved);
      }
    }

    return newItems;
  }

  private async fetchXml(url: string): Promise<string> {
    const response = await fetch(url, {
      headers: {
        Accept: 'application/rss+xml, application/xml, text/xml;q=0.9',
        'User-Agent': 'MAPIA RSS Reader',
      },
    });

    if (!response.ok) {
      throw new Error(`Error HTTP ${response.status}`);
    }

    return response.text();
  }

  private mapToNewsItem(item: any, sourceName: string): MappedNewsItem | null {
    if (typeof item !== 'object' || item === null) return null;

    const title = this.asText(item.title);
    // El Deber feed has <link> as plain string; fall back to guid if absent
    const url = this.asText(item.link) ?? this.asText(item.guid);
    if (!title || !url) return null;

    const publishedAt = this.toIsoDate(this.asText(item.pubDate));
    const description = this.cleanDescription(this.asText(item.description));
    const hash = crypto.createHash('sha256').update(url).digest('hex');

    return {
      title,
      source: sourceName,
      url,
      publishedAt,
      description,
      hash,
    };
  }

  private asText(value: any): string | undefined {
    if (typeof value === 'string') return value.trim() || undefined;
    if (typeof value === 'number') return String(value);
    if (typeof value === 'object' && value !== null) {
      // CDATA sections are stored under __cdata
      if (typeof value['__cdata'] === 'string') return value['__cdata'].trim() || undefined;
      // guid and similar may have #text
      if (typeof value['#text'] === 'string') return value['#text'].trim() || undefined;
    }
    return undefined;
  }

  private toIsoDate(value: string | undefined): string | undefined {
    if (!value) return undefined;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? undefined : date.toISOString();
  }

  private cleanDescription(value: string | undefined): string | undefined {
    if (!value) return undefined;
    const text = value
      .replace(/<[^>]*>/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    return text || undefined;
  }

  getSources() {
    return this.sources;
  }
}
