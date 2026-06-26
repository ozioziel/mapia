import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface ClassifiedNewsItem {
  title: string;
  url?: string;
  description?: string;
  source?: string;
  isBoliviaRelevant: boolean;
  reason: string;
}

@Injectable()
export class NewsClassifierService {
  private readonly logger = new Logger(NewsClassifierService.name);

  constructor(private readonly configService: ConfigService) {}

  async classifyItems(items: Array<Partial<ClassifiedNewsItem>>): Promise<ClassifiedNewsItem[]> {
    const apiKey = this.configService.get<string>('GROQ_API') || this.configService.get<string>('GEMINI_API') || '';

    const fallback = items.map((item) => this.classifyWithHeuristic(item));

    if (!apiKey) {
      return fallback;
    }

    try {
      const payload = {
        model: 'llama-3.1-8b-instant',
        messages: [
          {
            role: 'system',
            content:
              'Clasifica si cada noticia describe un evento o noticia relevante para Bolivia. Responde solo con un JSON array de objetos con este formato: [{"isBoliviaRelevant": true, "reason": "..."}, ...].',
          },
          {
            role: 'user',
            content: JSON.stringify(items),
          },
        ],
        temperature: 0,
      };

      const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error(`Groq error ${response.status}`);
      }

      const data = await response.json();
      const content = data?.choices?.[0]?.message?.content ?? '';
      const parsed = this.safeParseJson(content);
      const results = Array.isArray(parsed)
        ? parsed
        : Array.isArray(parsed?.items)
          ? parsed.items
          : [];

      if (!results.length) {
        return fallback;
      }

      return items.map((item, index) => ({
        title: item.title ?? '',
        url: item.url,
        description: item.description,
        source: item.source,
        isBoliviaRelevant: results[index]?.isBoliviaRelevant ?? this.classifyWithHeuristic(item).isBoliviaRelevant,
        reason: results[index]?.reason ?? this.classifyWithHeuristic(item).reason,
      }));
    } catch (error) {
      this.logger.warn(`No se pudo usar Groq, usando heurística: ${error instanceof Error ? error.message : String(error)}`);
      return fallback;
    }
  }

  private classifyWithHeuristic(item: Partial<ClassifiedNewsItem>): ClassifiedNewsItem {
    const text = `${item.title ?? ''} ${item.description ?? ''}`.toLowerCase();
    const boliviaSignals = [
      'bolivia',
      'la paz',
      'el alto',
      'cochabamba',
      'santa cruz',
      'oruro',
      'potosí',
      'tarija',
      'beni',
      'chuquisaca',
      'pando',
      'sucre',
      'trinidad',
      'barrio',
      'gobierno boliviano',
      'ministerio',
      'nacional',
      'municipio',
      'prefectura',
      'campesino',
    ];

    const isBoliviaRelevant = boliviaSignals.some((signal) => text.includes(signal));
    return {
      title: item.title ?? '',
      url: item.url,
      description: item.description,
      source: item.source,
      isBoliviaRelevant,
      reason: isBoliviaRelevant
        ? 'Se detectaron señales de contexto en Bolivia.'
        : 'No se encontraron señales claras de Bolivia.',
    };
  }

  private safeParseJson(content: string): any {
    try {
      return JSON.parse(content);
    } catch {
      const match = content.match(/\{[\s\S]*\}/);
      if (!match) {
        return null;
      }
      try {
        return JSON.parse(match[0]);
      } catch {
        return null;
      }
    }
  }
}
