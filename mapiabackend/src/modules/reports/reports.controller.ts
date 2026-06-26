import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { Public } from '@common/decorators/public.decorator';
import { Roles } from '@common/decorators/roles.decorator';
import { Role } from '@common/enums/role.enum';
import { PaginatedResult, PaginationQueryDto } from '@common/dtos/pagination.dto';
import { ContentReport } from './entities/content-report.entity';
import { ReportsService } from './reports.service';
import { CreateReportDto } from './dto/create-report.dto';
import { CreateCitizenReportDto } from './dto/create-citizen-report.dto';
import { ParseCitizenReportDto } from './dto/parse-citizen-report.dto';

const MAX_REPORT_IMAGE_BYTES = 5 * 1024 * 1024;

@ApiTags('reports')
@ApiBearerAuth()
@Controller()
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Public()
  @Post('reports/parse')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Estructurar texto libre de un reporte ciudadano' })
  parseCitizenReport(@Body() dto: ParseCitizenReportDto) {
    return this.reportsService.parseCitizenReport(dto);
  }

  @Public()
  @Post('reports')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Publicar reporte ciudadano para el mapa de alertas' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileFieldsInterceptor([{ name: 'images', maxCount: 3 }], {
      limits: { fileSize: MAX_REPORT_IMAGE_BYTES },
    }),
  )
  createCitizenReport(
    @Body() dto: CreateCitizenReportDto,
    @UploadedFiles() files?: { images?: Express.Multer.File[] },
  ) {
    return this.reportsService.createCitizenReport(dto, files?.images ?? []);
  }

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
