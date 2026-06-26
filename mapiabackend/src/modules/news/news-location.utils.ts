export const BOLIVIA_BOUNDS = {
  minLat: -22.9,
  maxLat: -9.6,
  minLng: -69.7,
  maxLng: -57.4,
};

export function isInsideBolivia(lat: number, lng: number): boolean {
  return (
    Number.isFinite(lat) &&
    Number.isFinite(lng) &&
    lat >= BOLIVIA_BOUNDS.minLat &&
    lat <= BOLIVIA_BOUNDS.maxLat &&
    lng >= BOLIVIA_BOUNDS.minLng &&
    lng <= BOLIVIA_BOUNDS.maxLng
  );
}

export function getBoliviaDayRange(now = new Date()): { start: Date; end: Date } {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/La_Paz',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(now);
  const get = (type: string) => parts.find((part) => part.type === type)?.value;
  const year = get('year');
  const month = get('month');
  const day = get('day');

  const start = new Date(`${year}-${month}-${day}T00:00:00-04:00`);
  const end = new Date(start.getTime() + 24 * 60 * 60 * 1000);
  return { start, end };
}

const knownLocations: Array<{ pattern: RegExp; location: string }> = [
  { pattern: /\bel alto\b/i, location: 'El Alto, La Paz, Bolivia' },
  { pattern: /\bla paz\b/i, location: 'La Paz, Bolivia' },
  { pattern: /\bcochabamba\b/i, location: 'Cochabamba, Bolivia' },
  { pattern: /\bsanta cruz\b/i, location: 'Santa Cruz de la Sierra, Bolivia' },
  { pattern: /\bsucre\b/i, location: 'Sucre, Bolivia' },
  { pattern: /\boruro\b/i, location: 'Oruro, Bolivia' },
  { pattern: /\bpotosi|\bpotosí\b/i, location: 'Potosi, Bolivia' },
  { pattern: /\btarija\b/i, location: 'Tarija, Bolivia' },
  { pattern: /\btrinidad\b/i, location: 'Trinidad, Beni, Bolivia' },
  { pattern: /\bcobija\b/i, location: 'Cobija, Pando, Bolivia' },
];

export function inferLocationText(title: string, description?: string | null): string | null {
  const text = `${title} ${description ?? ''}`;
  return knownLocations.find((item) => item.pattern.test(text))?.location ?? null;
}

export function normalizeNewsCategory(category?: string | null): string {
  const value = (category ?? '').trim().toLowerCase();
  if (['evento', 'bloqueo', 'corte_servicio', 'venta', 'noticia'].includes(value)) {
    return value;
  }
  if (value.includes('bloque')) return 'bloqueo';
  if (value.includes('evento') || value.includes('cultural')) return 'evento';
  if (value.includes('venta') || value.includes('feria')) return 'venta';
  if (value.includes('corte') || value.includes('servicio') || value.includes('agua')) {
    return 'corte_servicio';
  }
  return 'noticia';
}
