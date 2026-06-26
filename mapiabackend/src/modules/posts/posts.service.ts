import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { FindOptionsWhere, Repository } from 'typeorm';
import { PaginatedResult } from '@common/dtos/pagination.dto';
import { PostStatus, PostVisibility } from '@common/enums/post.enums';
import { ProfilesService } from '@modules/profiles/profiles.service';
import { Post } from './entities/post.entity';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { QueryPostsDto } from './dto/query-posts.dto';
import { PostResponseDto } from './dto/post-response.dto';
import { toPostResponse } from './mappers/post.mapper';

const POST_RELATIONS = { author: { profile: true }, media: true } as const;

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private readonly postRepo: Repository<Post>,
    private readonly profilesService: ProfilesService,
  ) {}

  async create(authorId: string, dto: CreatePostDto): Promise<PostResponseDto> {
    const post = this.postRepo.create({
      authorId,
      title: dto.title,
      description: dto.description,
      type: dto.type,
      latitude: dto.latitude,
      longitude: dto.longitude,
      address: dto.address ?? null,
      // Decisión de proyecto: se publica directo; moderación es reactiva.
      status: PostStatus.PUBLISHED,
      visibility: PostVisibility.PUBLIC,
    });
    const saved = await this.postRepo.save(post);
    await this.profilesService.incrementPosts(authorId, 1);
    return this.findOne(saved.id);
  }

  async findAll(query: QueryPostsDto): Promise<PaginatedResult<PostResponseDto>> {
    const where: FindOptionsWhere<Post> = { visibility: PostVisibility.PUBLIC };
    if (query.type) {
      where.type = query.type;
    }
    const [items, total] = await this.postRepo.findAndCount({
      where,
      relations: POST_RELATIONS,
      order: { createdAt: 'DESC' },
      skip: query.skip,
      take: query.limit,
    });
    return new PaginatedResult(items.map(toPostResponse), total, query.page, query.limit);
  }

  async findByUser(
    userId: string,
    query: QueryPostsDto,
  ): Promise<PaginatedResult<PostResponseDto>> {
    const [items, total] = await this.postRepo.findAndCount({
      where: { authorId: userId, visibility: PostVisibility.PUBLIC },
      relations: POST_RELATIONS,
      order: { createdAt: 'DESC' },
      skip: query.skip,
      take: query.limit,
    });
    return new PaginatedResult(items.map(toPostResponse), total, query.page, query.limit);
  }

  async findOne(id: string): Promise<PostResponseDto> {
    const post = await this.postRepo.findOne({ where: { id }, relations: POST_RELATIONS });
    if (!post || post.visibility === PostVisibility.DELETED) {
      throw new NotFoundException('Publicación no encontrada');
    }
    return toPostResponse(post);
  }

  async update(id: string, userId: string, dto: UpdatePostDto): Promise<PostResponseDto> {
    const post = await this.getOwnedEntity(id, userId);
    Object.assign(post, {
      title: dto.title ?? post.title,
      description: dto.description ?? post.description,
      type: dto.type ?? post.type,
      latitude: dto.latitude ?? post.latitude,
      longitude: dto.longitude ?? post.longitude,
      address: dto.address ?? post.address,
    });
    await this.postRepo.save(post);
    return this.findOne(id);
  }

  async remove(id: string, userId: string): Promise<{ success: true }> {
    const post = await this.getOwnedEntity(id, userId);
    post.visibility = PostVisibility.DELETED;
    post.status = PostStatus.DELETED;
    await this.postRepo.save(post);
    await this.profilesService.incrementPosts(userId, -1);
    return { success: true };
  }

  /** Ajuste de contador de comentarios (usado por CommentsService). */
  incrementComments(postId: string, delta: number): Promise<unknown> {
    return this.postRepo.increment({ id: postId }, 'commentsCount', delta);
  }

  /** Ajuste de contador de likes (usado por ReactionsService). */
  incrementLikes(postId: string, delta: number): Promise<unknown> {
    return this.postRepo.increment({ id: postId }, 'likesCount', delta);
  }

  /** Ajuste de contador de reportes (usado por ReportsService en fase 2). */
  incrementReports(postId: string, delta: number): Promise<unknown> {
    return this.postRepo.increment({ id: postId }, 'reportsCount', delta);
  }

  /** Acceso interno para reactions/comments (verifica existencia y visibilidad). */
  async getVisibleEntityOrFail(id: string): Promise<Post> {
    const post = await this.postRepo.findOne({ where: { id } });
    if (!post || post.visibility === PostVisibility.DELETED) {
      throw new NotFoundException('Publicación no encontrada');
    }
    return post;
  }

  private async getOwnedEntity(id: string, userId: string): Promise<Post> {
    const post = await this.postRepo.findOne({ where: { id } });
    if (!post || post.visibility === PostVisibility.DELETED) {
      throw new NotFoundException('Publicación no encontrada');
    }
    if (post.authorId !== userId) {
      throw new ForbiddenException('No puedes modificar esta publicación');
    }
    return post;
  }
}
