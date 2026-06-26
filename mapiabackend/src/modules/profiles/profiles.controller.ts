import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiConsumes,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { Public } from '@common/decorators/public.decorator';
import { Profile } from './entities/profile.entity';
import { ProfilesService } from './profiles.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

const MAX_AVATAR_BYTES = 5 * 1024 * 1024; // 5 MB
const ALLOWED_IMAGE = ['image/jpeg', 'image/png', 'image/webp'];

@ApiTags('profiles')
@ApiBearerAuth()
@Controller('profiles')
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  @Get('me')
  @ApiOperation({ summary: 'Perfil del usuario autenticado' })
  getMe(@CurrentUser('userId') userId: string): Promise<Profile> {
    return this.profilesService.getByUserId(userId);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Actualizar mi perfil' })
  updateMe(
    @CurrentUser('userId') userId: string,
    @Body() dto: UpdateProfileDto,
  ): Promise<Profile> {
    return this.profilesService.updateMe(userId, dto);
  }

  @Post('me/avatar')
  @ApiOperation({ summary: 'Subir/actualizar avatar' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file', { limits: { fileSize: MAX_AVATAR_BYTES } }))
  uploadAvatar(
    @CurrentUser('userId') userId: string,
    @UploadedFile() file?: Express.Multer.File,
  ): Promise<Profile> {
    if (!file) {
      throw new BadRequestException('Archivo "file" requerido');
    }
    if (!ALLOWED_IMAGE.includes(file.mimetype)) {
      throw new BadRequestException('Formato no permitido (jpeg, png, webp)');
    }
    return this.profilesService.setAvatar(userId, file);
  }

  @Public()
  @Get(':username')
  @ApiOperation({ summary: 'Perfil público por username' })
  getByUsername(@Param('username') username: string): Promise<Profile> {
    return this.profilesService.getByUsername(username);
  }
}
