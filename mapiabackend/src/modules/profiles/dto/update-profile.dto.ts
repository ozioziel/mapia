import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, Length, Matches } from 'class-validator';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Carla Méndez' })
  @IsOptional()
  @IsString()
  @Length(2, 120)
  name?: string;

  @ApiPropertyOptional({
    example: 'carla_m',
    description: 'Solo letras, números, punto y guion bajo',
  })
  @IsOptional()
  @IsString()
  @Length(3, 40)
  @Matches(/^[a-zA-Z0-9._]+$/, {
    message: 'username solo admite letras, números, punto y guion bajo',
  })
  username?: string;

  @ApiPropertyOptional({ example: 'Vecina de Sopocachi 📍' })
  @IsOptional()
  @IsString()
  @Length(0, 280)
  bio?: string;
}
