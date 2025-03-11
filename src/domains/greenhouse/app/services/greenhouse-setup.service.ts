import { Injectable } from "@nestjs/common";
import { PrismaService } from "src/infra/prisma";

@Injectable()
export class GreenhouseSetupService {
  constructor(private readonly prismaService: PrismaService) {}

  async getConfig() {
    const greenhouse = await this.prismaService.greenhouse.findFirst();
    return greenhouse
  }

  async init() {
    const greenhouse = await this.prismaService.greenhouse.create({
      data: {
        name: 'Greenhouse 12',
      },
    });

    return greenhouse
  }
}