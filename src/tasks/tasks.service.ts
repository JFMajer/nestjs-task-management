import { Injectable } from '@nestjs/common';
import { Task, TaskStatus } from './task.model';
import { v4 } from 'uuid';
import { CreateTaskDto } from './dto/create-task.dto';
import { NotFoundException } from '@nestjs/common';

@Injectable()
export class TasksService {
  private tasks: Task[] = [];

  getAllTasks(): Task[] {
    return this.tasks;
  }

  createTask(createTaskDto: CreateTaskDto): Task {
    const { title, description } = createTaskDto;
    const task: Task = {
      id: v4(),
      title,
      description,
      status: TaskStatus.OPEN,
    };
    this.tasks.push(task);
    return task;
  }

  findOne(id: string): Task {
    const taskToBeReturned = this.tasks.find(task => task.id === id);

    if (!taskToBeReturned) {
      throw new NotFoundException(`Task with ID "${id}" not found`);
    }

    return taskToBeReturned;
  }

  remove(id: string): Task {
    const taskToBeDeleted = this.findOne(id);
    this.tasks = this.tasks.filter(task => task.id !== taskToBeDeleted.id);
    return taskToBeDeleted;
  }
}
