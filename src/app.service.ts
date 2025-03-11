import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getVersion(): { version: string } {
    return { version: '0.0.1-alpha.0'};
  }
}
