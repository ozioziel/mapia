import { Module } from '@nestjs/common';
import { STORAGE_SERVICE } from './storage.types';
import { LocalStorageService } from './local-storage.service';

@Module({
  providers: [
    LocalStorageService,
    {
      provide: STORAGE_SERVICE,
      useExisting: LocalStorageService,
    },
  ],
  exports: [STORAGE_SERVICE],
})
export class StorageModule {}
