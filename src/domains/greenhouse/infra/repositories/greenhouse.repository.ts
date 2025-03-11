import { Injectable } from "@nestjs/common";
import { PrismaService } from "../../../../infra/prisma";

@Injectable()
export class GreenhouseRepository {
	constructor(private readonly prismaService: PrismaService) {}

	async create() {
		await this.prismaService.greenhouse.create({
			data: {
				name: 'Greenhouse 1',
			},
		});
	}

	async get() {
		return this.prismaService.greenhouse.findMany();
	}
}