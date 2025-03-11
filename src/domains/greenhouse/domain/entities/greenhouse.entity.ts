import { v4 as uuid } from 'uuid';

export class Greenhouse {
    constructor(
      public readonly id: string = uuid(),
      public name: string,
    ) {}
  
    rename(newName: string) {
      this.name = newName;
    }
  }