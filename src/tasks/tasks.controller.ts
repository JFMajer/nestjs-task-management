import { Body, Controller, Get, Post } from '@nestjs/common';
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

  // create new task - grab entire body
  // @Post()
  // createTask(@Body() body): Task {
  //   console.log('body', body);
  //   const newTask = this.tasksService.createTask(body.title, body.description);
  //   return newTask;
  // }

  // create new task - grab title and description
  @Post()
  createTask(
    @Body('title') title: string,
    @Body('description') description: string,
  ): Task {
    console.log('title', title);
    console.log('description', description);
    const newTask = this.tasksService.createTask(title, description);
    return newTask;
  }
}
