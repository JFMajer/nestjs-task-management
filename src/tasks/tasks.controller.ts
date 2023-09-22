import { Body, Controller, Get, Post, Param, Delete } from '@nestjs/common';
import { TasksService } from './tasks.service';
import { Task } from './task.model';
import { CreateTaskDto } from './dto/create-task.dto';

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

  // get one task by id
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Task> {
    return await this.tasksService.findOne(id);
  }

  // delete task by id
  @Delete(':id')
  remove(@Param('id') id: string): Task {
    return this.tasksService.remove(id);
  }
}
