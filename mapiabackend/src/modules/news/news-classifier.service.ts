import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MapsConfig } from '@core/config/configuration';

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
  private readonly mapsConfig: MapsConfig;

  constructor(private readonly configService: ConfigService) {
    this.mapsConfig = this.configService.get<MapsConfig>('maps') ?? { apiKey: '', geocodingEnabled: false, placesEnabled: false } as MapsConfig;
  }

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
    const locationMatches = this.extractBoliviaLocations(text);
    const boliviaSignals = [
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
      'municipio',
      'prefectura',
      'campesino',
      'bolivia',
    ];

    const negativePhrases = [
      'sin relación con bolivia',
      'no es de bolivia',
      'fuera de bolivia',
      'en madrid',
      'en europa',
      'en eeuu',
      'en chile',
      'en argentina',
      'internacional',
    ];

    const hasNegativePhrase = negativePhrases.some((phrase) => text.includes(phrase));
    const hasBoliviaSignal = boliviaSignals.some((signal) => text.includes(signal));
    const hasGoogleMapsLocation = locationMatches.length > 0;
    const isBoliviaRelevant = (hasBoliviaSignal || hasGoogleMapsLocation) && !hasNegativePhrase;
    return {
      title: item.title ?? '',
      url: item.url,
      description: item.description,
      source: item.source,
      isBoliviaRelevant,
      reason: isBoliviaRelevant
        ? hasGoogleMapsLocation
          ? `Se validó una ubicación concreta en Bolivia: ${locationMatches.join(', ')}.`
          : 'Se detectaron señales de contexto en Bolivia.'
        : 'No se encontraron señales claras de Bolivia.',
    };
  }

  private extractBoliviaLocations(text: string): string[] {
    if (!this.mapsConfig?.apiKey) {
      return [];
    }

    const candidates = [
      'la paz bolivia',
      'el alto bolivia',
      'cochabamba bolivia',
      'santa cruz bolivia',
      'sucre bolivia',
      'tarija bolivia',
      'potosi bolivia',
      'trinidad bolivia',
      'oruro bolivia',
      'pando bolivia',
      'chuquisaca bolivia',
      'beni bolivia',
    ];

    return candidates.filter((candidate) => text.includes(candidate));
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
