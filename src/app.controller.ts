import { Controller, Get, Response, HttpStatus } from '@nestjs/common';
import { AppService } from './app.service';
import { exec } from 'child_process';
import { FastifyReply } from 'fastify';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getVersion(): { version: string } {
    return this.appService.getVersion();
  }

  @Get('update')
  updateVersion(@Response() reply: FastifyReply) {
    exec('/bin/bash /home/$USER/openagri-node/update.sh', (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing update script: ${error.message}`);
        return reply.status(HttpStatus.INTERNAL_SERVER_ERROR).send({ error: error.message });
      }
      if (stderr) {
        console.warn(`Script stderr: ${stderr}`);
      }
      return reply.status(HttpStatus.OK).send({ message: 'Update completed successfully', output: stdout });
    });
  }
}
