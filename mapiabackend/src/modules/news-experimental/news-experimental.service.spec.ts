import { NewsExperimentalService } from './news-experimental.service';

describe('NewsExperimentalService', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('filtra noticias que no son relevantes para Bolivia', async () => {
    const fetchMock = jest.fn().mockResolvedValue({
      ok: true,
      text: async () => `
        <rss>
          <channel>
            <item>
              <title>Tormenta en Madrid</title>
              <link>https://example.com/madrid</link>
              <description>Un evento internacional sin relación con Bolivia.</description>
            </item>
            <item>
              <title>Protesta en La Paz</title>
              <link>https://example.com/lapaz</link>
              <description>Vecinos de La Paz exigen mejoras en el transporte.</description>
            </item>
          </channel>
        </rss>
      `,
    });

    global.fetch = fetchMock as unknown as typeof fetch;

    const service = new NewsExperimentalService();
    const result = await service.getElDeberNews();

    expect(result).toHaveLength(1);
    expect(result[0].title).toContain('La Paz');
  });
});
