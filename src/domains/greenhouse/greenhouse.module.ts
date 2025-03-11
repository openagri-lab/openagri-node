import { PrismaService } from "../../infra/prisma";
import { Module } from "@nestjs/common";

import * as Services from "./app/services";

@Module({
  providers: [
    PrismaService,
    ...Object.values(Services),
  ],
  exports: [
    ...Object.values(Services),
  ],
})
export class GreenhouseModule {}