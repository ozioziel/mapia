import { Module } from '@nestjs/common';
import { ReportCandidatesModule } from '@modules/report-candidates/report-candidates.module';
import { CitizenReportsController } from './citizen-reports.controller';
import { CitizenReportsService } from './citizen-reports.service';

@Module({
  imports: [ReportCandidatesModule],
  controllers: [CitizenReportsController],
  providers: [CitizenReportsService],
})
export class CitizenReportsModule {}
