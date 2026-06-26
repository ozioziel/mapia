import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { Roles } from '@common/decorators/roles.decorator';
import { Role } from '@common/enums/role.enum';
import { ReportCandidateStatus } from './entities/report-candidate.entity';
import {
  UpdateReportCandidatePriorityDto,
  UpdateReportCandidateStatusDto,
} from './dto/report-candidate.dto';
import { ReportCandidatesService } from './report-candidates.service';

@ApiTags('report-candidates')
@ApiBearerAuth()
@Controller('report-candidates')
export class ReportCandidatesController {
  constructor(private readonly candidatesService: ReportCandidatesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar candidatos para informe ciudadano' })
  findAll(@Query('status') status?: ReportCandidateStatus) {
    return this.candidatesService.findAll(status);
  }

  @Get('approved')
  @ApiOperation({ summary: 'Listar candidatos aprobados para informe' })
  approved() {
    return this.candidatesService.approved();
  }

  @Get('approved/map')
  @ApiOperation({ summary: 'Marcadores de candidatos aprobados para el mapa' })
  approvedMapMarkers() {
    return this.candidatesService.approvedMapMarkers();
  }

  @Post('from-post/:postId')
  @ApiOperation({ summary: 'Marcar una publicacion como candidata para Alcaldia' })
  createFromPost(@Param('postId', ParseUUIDPipe) postId: string) {
    return this.candidatesService.createFromPost(postId);
  }

  @Patch(':id/status')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Cambiar estado de candidato (solo admin)' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser('userId') reviewerId: string,
    @Body() dto: UpdateReportCandidateStatusDto,
  ) {
    return this.candidatesService.updateStatus(id, reviewerId, dto);
  }

  @Patch(':id/priority')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Cambiar prioridad de candidato (solo admin)' })
  updatePriority(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateReportCandidatePriorityDto,
  ) {
    return this.candidatesService.updatePriority(id, dto);
  }
}
