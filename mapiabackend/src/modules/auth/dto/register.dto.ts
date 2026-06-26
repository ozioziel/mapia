import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, Length, Matches } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'carla@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'Sup3rSegura!', minLength: 8 })
  @IsString()
  @Length(8, 72)
  password: string;

  @ApiProperty({ example: 'Carla Méndez' })
  @IsString()
  @Length(2, 120)
  name: string;

  @ApiProperty({ example: 'carla_m', description: 'Único; letras, números, punto, guion bajo' })
  @IsString()
  @Length(3, 40)
  @Matches(/^[a-zA-Z0-9._]+$/, {
    message: 'username solo admite letras, números, punto y guion bajo',
  })
  username: string;
}
