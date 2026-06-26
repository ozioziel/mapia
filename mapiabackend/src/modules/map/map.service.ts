import { BadRequestException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GeoConfig } from '@core/config/configuration';
import { PostVisibility } from '@common/enums/post.enums';
import { clampRadiusToMeters, parseBbox } from '@common/utils/geo.utils';
import { Post } from '@modules/posts/entities/post.entity';
import { MapBboxQueryDto, MapMarkerDto, MapNearbyQueryDto } from './dto/map-query.dto';

interface MarkerRow {
  id: string;
  title: string;
  type: string;
  latitude: number;
  longitude: number;
  address: string | null;
  isVerified: boolean;
  authorId: string;
  authorName: string;
  authorAvatarUrl: string | null;
}

const MAX_MARKERS = 500;

@Injectable()
export class MapService {
  private readonly geo: GeoConfig;

  constructor(
    @InjectRepository(Post)
    private readonly postRepo: Repository<Post>,
    private readonly configService: ConfigService,
  ) {
    this.geo = this.configService.get<GeoConfig>('geo')!;
  }

  /** Publicaciones cercanas a un punto, ordenadas por distancia (PostGIS). */
  async nearby(query: MapNearbyQueryDto): Promise<MapMarkerDto[]> {
    const meters = clampRadiusToMeters(query.radiusKm, this.geo.defaultRadiusKm, this.geo.maxRadiusKm);

    const qb = this.baseMarkerQuery()
      .andWhere(
        `ST_DWithin(post.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, :meters)`,
        { lng: query.lng, lat: query.lat, meters },
      )
      .addSelect(
        `ST_Distance(post.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography)`,
        'distance',
      )
      .orderBy('distance', 'ASC')
      .limit(MAX_MARKERS);

    if (query.type) {
      qb.andWhere('post.type = :type', { type: query.type });
    }

    return this.mapRows(await qb.getRawMany<MarkerRow>());
  }

  /** Publicaciones dentro de un bounding box (viewport del mapa). */
  async byBbox(query: MapBboxQueryDto): Promise<MapMarkerDto[]> {
    let box: ReturnType<typeof parseBbox>;
    try {
      box = parseBbox(query.bbox);
    } catch (e) {
      throw new BadRequestException((e as Error).message);
    }

    const qb = this.baseMarkerQuery()
      .andWhere(
        `post.location && ST_MakeEnvelope(:minLng, :minLat, :maxLng, :maxLat, 4326)::geography`,
        box,
      )
      .orderBy('post.createdAt', 'DESC')
      .limit(MAX_MARKERS);

    if (query.type) {
      qb.andWhere('post.type = :type', { type: query.type });
    }

    return this.mapRows(await qb.getRawMany<MarkerRow>());
  }

  private baseMarkerQuery() {
    return this.postRepo
      .createQueryBuilder('post')
      .innerJoin('profiles', 'profile', 'profile.user_id = post.author_id')
      .select('post.id', 'id')
      .addSelect('post.title', 'title')
      .addSelect('post.type', 'type')
      .addSelect('post.latitude', 'latitude')
      .addSelect('post.longitude', 'longitude')
      .addSelect('post.address', 'address')
      .addSelect('post.isVerified', 'isVerified')
      .addSelect('profile.user_id', 'authorId')
      .addSelect('profile.name', 'authorName')
      .addSelect('profile.avatar_url', 'authorAvatarUrl')
      .where('post.visibility = :vis', { vis: PostVisibility.PUBLIC });
  }

  private mapRows(rows: MarkerRow[]): MapMarkerDto[] {
    return rows.map((r) => ({
      id: r.id,
      title: r.title,
      type: r.type as MapMarkerDto['type'],
      latitude: Number(r.latitude),
      longitude: Number(r.longitude),
      address: r.address,
      isVerified: Boolean(r.isVerified),
      author: {
        id: r.authorId,
        name: r.authorName,
        avatarUrl: r.authorAvatarUrl,
      },
    }));
  }
}
