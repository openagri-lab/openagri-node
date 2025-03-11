import { Module } from '@nestjs/common';
import { VersionModule } from './interfaces/version/version.module';

@Module({
  imports: [VersionModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
