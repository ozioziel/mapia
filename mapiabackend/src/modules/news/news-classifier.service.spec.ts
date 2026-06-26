import { NewsClassifierService } from './news-classifier.service';

describe('NewsClassifierService', () => {
  it('detecta noticias relacionadas con Bolivia usando heurística', async () => {
    const service = new NewsClassifierService({ get: () => undefined } as any);

    const results = await service.classifyItems([
      {
        title: 'Manifestación en La Paz',
        description: 'Vecinos protestan por mejoras de transporte en la ciudad.',
      },
    ]);

    expect(results[0].isBoliviaRelevant).toBe(true);
    expect(results[0].reason).toContain('Bolivia');
  });

  it('descarta noticias que no son de Bolivia', async () => {
    const service = new NewsClassifierService({ get: () => undefined } as any);

    const results = await service.classifyItems([
      {
        title: 'Tormenta en Europa',
        description: 'Se reporta una fuerte tormenta en Madrid.',
      },
      {
        title: 'Corte de ruta en Santa Cruz',
        description: 'Una protesta afecta el acceso a la zona norte.',
      },
    ]);

    expect(results[0].isBoliviaRelevant).toBe(false);
    expect(results[1].isBoliviaRelevant).toBe(true);
  });
});
