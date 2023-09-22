import {
  Body,
  Controller,
  Get,
  Post,
  Param,
  Delete,
  Patch,
  Query,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { Task, TaskStatus } from './task.model';
import { CreateTaskDto } from './dto/create-task.dto';
import { GetTasksFilterDto } from './dto/get-tasks-filter.dto';

@Controller('tasks')
export class TasksController {
  constructor(private tasksService: TasksService) {}

  // get tasks
  @Get()
  getTasks(@Query() filterDto: GetTasksFilterDto): Task[] {
    if (Object.keys(filterDto).length) {
      return this.tasksService.getTasksWithFilters(filterDto);
    }
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
  remove(@Param('id') id: string): void {
    return this.tasksService.remove(id);
  }

  // update task's status
  @Patch(':id/status')
  updateTaskStatus(
    @Param('id') id: string,
    @Body('status') status: TaskStatus,
  ): Task {
    return this.tasksService.updateTaskStatus(id, status);
  }
}
