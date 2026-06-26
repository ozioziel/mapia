import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { STORAGE_SERVICE, IStorageService } from '@core/storage/storage.types';
import { Profile } from './entities/profile.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class ProfilesService {
  constructor(
    @InjectRepository(Profile)
    private readonly profileRepo: Repository<Profile>,
    @Inject(STORAGE_SERVICE)
    private readonly storage: IStorageService,
  ) {}

  /** Crea el perfil inicial al registrarse un usuario. */
  async createForUser(userId: string, name: string, username: string): Promise<Profile> {
    await this.assertUsernameAvailable(username);
    const profile = this.profileRepo.create({ userId, name, username });
    return this.profileRepo.save(profile);
  }

  async getByUserId(userId: string): Promise<Profile> {
    const profile = await this.profileRepo.findOne({ where: { userId } });
    if (!profile) {
      throw new NotFoundException('Perfil no encontrado');
    }
    return profile;
  }

  async getByUsername(username: string): Promise<Profile> {
    const profile = await this.profileRepo.findOne({ where: { username } });
    if (!profile) {
      throw new NotFoundException('Perfil no encontrado');
    }
    return profile;
  }

  async updateMe(userId: string, dto: UpdateProfileDto): Promise<Profile> {
    const profile = await this.getByUserId(userId);
    if (dto.username && dto.username !== profile.username) {
      await this.assertUsernameAvailable(dto.username);
      profile.username = dto.username;
    }
    if (dto.name !== undefined) profile.name = dto.name;
    if (dto.bio !== undefined) profile.bio = dto.bio;
    return this.profileRepo.save(profile);
  }

  async setAvatar(
    userId: string,
    file: { buffer: Buffer; originalname: string; mimetype: string },
  ): Promise<Profile> {
    const profile = await this.getByUserId(userId);

    const stored = await this.storage.upload({
      buffer: file.buffer,
      originalName: file.originalname,
      mimeType: file.mimetype,
      folder: 'avatars',
    });

    // Borrar avatar previo si existía.
    if (profile.avatarKey) {
      await this.storage.delete(profile.avatarKey);
    }

    profile.avatarUrl = stored.url;
    profile.avatarKey = stored.storageKey;
    return this.profileRepo.save(profile);
  }

  // --- Mantenimiento de contadores (usado por otros módulos) ---

  incrementPosts(userId: string, delta: number): Promise<unknown> {
    return this.profileRepo.increment({ userId }, 'postsCount', delta);
  }

  incrementLikes(userId: string, delta: number): Promise<unknown> {
    return this.profileRepo.increment({ userId }, 'likesCount', delta);
  }

  private async assertUsernameAvailable(username: string): Promise<void> {
    const exists = await this.profileRepo.findOne({ where: { username } });
    if (exists) {
      throw new ConflictException('El username ya está en uso');
    }
  }
}
