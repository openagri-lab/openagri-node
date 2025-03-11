import { Module } from '@nestjs/common';
import { VersionModule } from './interfaces/version/version.module';
import { SetupModule } from './interfaces/setup/setup.module';
import { BroadcastService } from './infra/broadcast';

@Module({
  imports: [VersionModule, SetupModule],
  controllers: [],
  providers: [BroadcastService],
})
export class AppModule {}
