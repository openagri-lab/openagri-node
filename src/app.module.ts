import { Module } from '@nestjs/common';
import { VersionModule } from './interfaces/version/version.module';
import { SetupModule } from './interfaces/setup/setup.module';

@Module({
  imports: [VersionModule, SetupModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
