import { Controller, Get, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { OptionalAuth } from '@common/decorators/optional-auth.decorator';
import { Public } from '@common/decorators/public.decorator';
import { MapService } from './map.service';
import { MapAlertsQueryDto } from './dto/map-alerts-query.dto';
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

  @OptionalAuth()
  @ApiBearerAuth()
  @Get('alerts')
  @ApiOperation({ summary: 'Alertas ciudadanas para el mapa de Bolivia' })
  alerts(
    @Query() query: MapAlertsQueryDto,
    @CurrentUser('userId') userId?: string,
  ) {
    return this.mapService.alerts(query, userId);
  }

  @Public()
  @Get('summary')
  @ApiOperation({ summary: 'Resumen de alertas ciudadanas' })
  summary(@Query() query: MapAlertsQueryDto) {
    return this.mapService.summary(query);
  }

  @Public()
  @Get('filters')
  @ApiOperation({ summary: 'Valores disponibles para filtros de alertas' })
  filters() {
    return this.mapService.filters();
  }
}
