import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MapsConfig } from '@core/config/configuration';
import { isInsideBolivia } from './news-location.utils';

export interface GeocodeResult {
  lat: number;
  lng: number;
  formattedAddress?: string;
}

@Injectable()
export class GeocodingService {
  private readonly logger = new Logger(GeocodingService.name);

  constructor(private readonly config: ConfigService) {}

  async geocodeBoliviaLocation(locationText: string): Promise<GeocodeResult | null> {
    const maps = this.config.get<MapsConfig>('maps')!;
    if (!maps.geocodingEnabled || !maps.apiKey) return null;

    const params = new URLSearchParams({
      address: locationText.includes('Bolivia') ? locationText : `${locationText}, Bolivia`,
      region: 'bo',
      components: 'country:BO',
      key: maps.apiKey,
    });

    try {
      const response = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?${params}`);
      if (!response.ok) {
        this.logger.warn(`Google Geocoding respondio ${response.status}`);
        return null;
      }

      const data = (await response.json()) as {
        status?: string;
        results?: Array<{
          formatted_address?: string;
          geometry?: { location?: { lat?: number; lng?: number } };
        }>;
      };
      const location = data.results?.[0]?.geometry?.location;
      if (data.status !== 'OK' || location?.lat == null || location?.lng == null) {
        return null;
      }
      if (!isInsideBolivia(location.lat, location.lng)) return null;

      return {
        lat: location.lat,
        lng: location.lng,
        formattedAddress: data.results?.[0]?.formatted_address,
      };
    } catch (error) {
      this.logger.warn(`No se pudo geocodificar "${locationText}": ${error.message}`);
      return null;
    }
  }
}
