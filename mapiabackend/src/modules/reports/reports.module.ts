import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostsModule } from '@modules/posts/posts.module';
import { ContentReport } from './entities/content-report.entity';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

@Module({
  imports: [TypeOrmModule.forFeature([ContentReport]), PostsModule],
  controllers: [ReportsController],
  providers: [ReportsService],
})
export class ReportsModule {}
