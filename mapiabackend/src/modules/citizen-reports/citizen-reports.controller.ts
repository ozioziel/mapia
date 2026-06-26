import { Body, Controller, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Roles } from '@common/decorators/roles.decorator';
import { Role } from '@common/enums/role.enum';
import { GenerateCitizenReportDto } from './dto/generate-citizen-report.dto';
import { CitizenReportsService } from './citizen-reports.service';

@ApiTags('citizen-reports')
@ApiBearerAuth()
@Controller('reports')
export class CitizenReportsController {
  constructor(private readonly reportsService: CitizenReportsService) {}

  @Post('generate')
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Generar borrador de informe formal para revision admin' })
  generate(@Body() dto: GenerateCitizenReportDto) {
    return this.reportsService.generate(dto);
  }
}
