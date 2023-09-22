import { Controller, Get } from '@nestjs/common';
import { TasksService } from './tasks.service';
import { Task } from './task.model';

@Controller('tasks')
export class TasksController {
  constructor(private tasksService: TasksService) {}

  // get all tasks
  @Get()
  getAllTasks(): Task[] {
    return this.tasksService.getAllTasks();
  }
}
