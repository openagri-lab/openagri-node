import { Controller, Get, Response, HttpStatus } from '@nestjs/common';
import { GreenhouseSetupService } from 'src/domains/greenhouse/app/services';

@Controller('setup')
export class SetupController {
  constructor(private readonly setupService: GreenhouseSetupService) {}

  @Get()
  async status() {
    const greenhouse = await this.setupService.getConfig();

    if (!greenhouse) {
      return { initialized: false };
    }

    return { initialized: true, greenhouse }
  }

  @Get('init')
  async createGreenhouse() {
    const greenhouse = await this.setupService.init()
    return { greenhouse }
  }
}
