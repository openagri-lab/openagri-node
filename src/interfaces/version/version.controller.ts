import { Controller, Get, Response, HttpStatus } from '@nestjs/common';
import { VersionService } from './version.service';
import { exec } from 'child_process';
import { FastifyReply } from 'fastify';

@Controller()
export class VersionController {
  constructor(private readonly versionService: VersionService) {}

  @Get()
  getVersion(): { version: string } {
    return this.versionService.getVersion();
  }

  @Get('update')
  updateVersion(@Response() reply: FastifyReply) {
    exec('nohup /bin/bash /home/$USER/openagri-node/scripts/update.sh > /home/$USER/openagri-node/scripts/update.log 2>&1 &', (error, stdout, stderr) => {
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
