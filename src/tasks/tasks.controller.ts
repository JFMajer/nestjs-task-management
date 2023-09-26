import {
  Body,
  Controller,
  Get,
  Post,
  Param,
  Delete,
  Patch,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './dto/task.entity';

@Controller('tasks')
export class TasksController {
  constructor(private tasksService: TasksService) {}

  // get all tasks
  @Get()
  getAllTasks(): Promise<Task[]> {
    return this.tasksService.findAll();
  }

  // get task by id
  @Get(':id')
  getTaskById(@Param('id') id: string): Promise<Task | null> {
    return this.tasksService.findOne(id);
  }

  // create task
  @Post()
  createTask(@Body() createTaskDto: CreateTaskDto): Promise<Task> {
    return this.tasksService.createTask(createTaskDto);
  }

  // create multiple tasks
  @Post('/multiple')
  createMultipleTasks(@Body() createTaskDto: CreateTaskDto[]): Promise<Task[]> {
    return this.tasksService.createMultipleTasks(createTaskDto);
  }

  // delete task by id
  @Delete(':id')
  deleteTask(@Param('id') id: string): Promise<void> {
    return this.tasksService.remove(id);
  }

  // update task status
  @Patch(':id/status')
  updateTaskStatus(
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ): Promise<Task> {
    return this.tasksService.updateTaskStatus(id, updateTaskDto);
  }
}
