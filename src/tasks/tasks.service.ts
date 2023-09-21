import { Injectable } from '@nestjs/common';

@Injectable()
export class TasksService {
  private tasks = [];

  getAllTasks() {
    return this.tasks;
  }

  createTask(title: string, description: string) {
    const task = {
      id: this.tasks.length + 1,
      title,
      description,
      status: 'OPEN',
    };

    this.tasks.push(task);
    return task;
  }
}
