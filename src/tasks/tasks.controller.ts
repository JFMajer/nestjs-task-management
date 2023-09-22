import { Body, Controller, Get, Post } from '@nestjs/common';
import { TasksService } from './tasks.service';
import { Task } from './task.model';
import { CreateTaskDto } from './create-task.dto';

@Controller('tasks')
export class TasksController {
  constructor(private tasksService: TasksService) {}

  // get all tasks
  @Get()
  getAllTasks(): Task[] {
    return this.tasksService.getAllTasks();
  }

  // create a task
  @Post()
  async createTask(@Body() createTaskDto: CreateTaskDto): Promise<Task> {
    const newTask = await this.tasksService.createTask(createTaskDto);
    return newTask;
  }
}
