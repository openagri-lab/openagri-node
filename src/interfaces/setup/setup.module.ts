import { Module } from '@nestjs/common';
import { SetupController } from './setup.controller';
import { GreenhouseModule } from 'src/domains/greenhouse';

@Module({
  imports: [GreenhouseModule],
  controllers: [SetupController],
  providers: [],
})
export class SetupModule {}
