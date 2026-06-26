import { ConflictException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaginatedResult, PaginationQueryDto } from '@common/dtos/pagination.dto';
import { PostsService } from '@modules/posts/posts.service';
import { ContentReport } from './entities/content-report.entity';
import { CreateReportDto } from './dto/create-report.dto';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(ContentReport)
    private readonly reportRepo: Repository<ContentReport>,
    private readonly postsService: PostsService,
  ) {}

  async create(
    postId: string,
    reporterId: string,
    dto: CreateReportDto,
  ): Promise<ContentReport> {
    await this.postsService.getVisibleEntityOrFail(postId);

    // Un usuario no reporta dos veces la misma publicación.
    const existing = await this.reportRepo.findOne({ where: { postId, reporterId } });
    if (existing) {
      throw new ConflictException('Ya reportaste esta publicación');
    }

    const report = this.reportRepo.create({
      postId,
      reporterId,
      reason: dto.reason,
      description: dto.description ?? null,
    });
    const saved = await this.reportRepo.save(report);
    await this.postsService.incrementReports(postId, 1);
    return saved;
  }

  /** Listado para moderación (MODERATOR/ADMIN). */
  async findAll(query: PaginationQueryDto): Promise<PaginatedResult<ContentReport>> {
    const [items, total] = await this.reportRepo.findAndCount({
      relations: { reporter: true, post: true },
      order: { createdAt: 'DESC' },
      skip: query.skip,
      take: query.limit,
    });
    return new PaginatedResult(items, total, query.page, query.limit);
  }
}
