import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import * as dgram from 'dgram';
import * as os from 'os';

@Injectable()
export class BroadcastService implements OnModuleInit, OnModuleDestroy {
    private readonly BROADCAST_PORT = 41234;
    private socket: dgram.Socket;
    private broadcastInterval: NodeJS.Timeout | null = null;

    constructor() {
        this.socket = dgram.createSocket('udp4');
    }

    async onModuleInit() {
        this.socket.bind(() => {
            this.socket.setBroadcast(true);
            console.log(`📡 Serveur UDP prêt à diffuser sur le port ${this.BROADCAST_PORT}`);
        });

        this.startBroadcasting();
    }

    onModuleDestroy() {
        this.stopBroadcasting();
        this.socket.close();
    }

    private startBroadcasting() {
        this.broadcastInterval = setInterval(() => {
            const message = Buffer.from(`${this.getLocalIP()}:8080`);
            this.socket.send(message, 0, message.length, this.BROADCAST_PORT, '255.255.255.255', (err) => {
                if (err) console.error("❌ Erreur d'envoi UDP :", err);
            });
            console.log(`📡 Broadcast envoyé: ${message.toString()}`);
        }, 5000);
    }

    private stopBroadcasting() {
        if (this.broadcastInterval) {
            clearInterval(this.broadcastInterval);
            this.broadcastInterval = null;
        }
    }

    private getLocalIP(): string {
        const interfaces = os.networkInterfaces();
        for (const name of Object.keys(interfaces)) {
            for (const net of interfaces[name] || []) {
                if (net.family === 'IPv4' && !net.internal) {
                    return net.address;
                }
            }
        }
        return '127.0.0.1';
    }
}