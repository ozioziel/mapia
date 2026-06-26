import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { Observable } from 'rxjs';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { IS_OPTIONAL_AUTH_KEY } from '../decorators/optional-auth.decorator';

/**
 * Guard JWT global.
 * - @Public(): deja pasar sin tocar el token.
 * - @OptionalAuth(): intenta autenticar; si hay token válido adjunta request.user,
 *   si no, deja pasar igual (user = undefined).
 * - resto: exige token válido.
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    const isOptional = this.reflector.getAllAndOverride<boolean>(IS_OPTIONAL_AUTH_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic && !isOptional) {
      return true;
    }

    if (isOptional) {
      return this.runOptionalAuth(context);
    }

    return super.canActivate(context);
  }

  private async runOptionalAuth(context: ExecutionContext): Promise<boolean> {
    try {
      const result = await super.canActivate(context);
      return Boolean(result);
    } catch {
      return true;
    }
  }

  handleRequest<TUser = unknown>(
    err: unknown,
    user: TUser,
    info: unknown,
    context: ExecutionContext,
  ): TUser {
    const isOptional = this.reflector.getAllAndOverride<boolean>(IS_OPTIONAL_AUTH_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isOptional) {
      return (user ?? undefined) as TUser;
    }
    return super.handleRequest(err, user, info, context);
  }
}
