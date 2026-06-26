import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostsModule } from '@modules/posts/posts.module';
import { StorageModule } from '@core/storage/storage.module';
import { ContentReport } from './entities/content-report.entity';
import { AlertReport } from './entities/alert-report.entity';
import { AlertReportImage } from './entities/alert-report-image.entity';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ContentReport, AlertReport, AlertReportImage]),
    PostsModule,
    StorageModule,
  ],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
