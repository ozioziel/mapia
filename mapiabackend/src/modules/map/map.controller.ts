import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '@common/decorators/public.decorator';
import { MapService } from './map.service';
import { MapBboxQueryDto, MapMarkerDto, MapNearbyQueryDto } from './dto/map-query.dto';

@ApiTags('map')
@Controller('map')
export class MapController {
  constructor(private readonly mapService: MapService) {}

  @Public()
  @Get('posts')
  @ApiOperation({ summary: 'Marcadores dentro de un bounding box (viewport)' })
  byBbox(@Query() query: MapBboxQueryDto): Promise<MapMarkerDto[]> {
    return this.mapService.byBbox(query);
  }

  @Public()
  @Get('posts/nearby')
  @ApiOperation({ summary: 'Marcadores cercanos a un punto por radio (PostGIS)' })
  nearby(@Query() query: MapNearbyQueryDto): Promise<MapMarkerDto[]> {
    return this.mapService.nearby(query);
  }
}
