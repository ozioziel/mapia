import { Body, Controller, Get, HttpCode, HttpStatus, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { Roles } from '@common/decorators/roles.decorator';
import { Role } from '@common/enums/role.enum';
import { PaginatedResult, PaginationQueryDto } from '@common/dtos/pagination.dto';
import { ContentReport } from './entities/content-report.entity';
import { ReportsService } from './reports.service';
import { CreateReportDto } from './dto/create-report.dto';

@ApiTags('reports')
@ApiBearerAuth()
@Controller()
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post('posts/:postId/report')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Reportar una publicación' })
  create(
    @Param('postId', ParseUUIDPipe) postId: string,
    @CurrentUser('userId') userId: string,
    @Body() dto: CreateReportDto,
  ): Promise<ContentReport> {
    return this.reportsService.create(postId, userId, dto);
  }

  @Get('reports')
  @Roles(Role.MODERATOR, Role.ADMIN)
  @ApiOperation({ summary: 'Listar reportes (solo moderación)' })
  findAll(@Query() query: PaginationQueryDto): Promise<PaginatedResult<ContentReport>> {
    return this.reportsService.findAll(query);
  }
}
