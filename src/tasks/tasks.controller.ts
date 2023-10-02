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
import { DeleteResult } from 'typeorm';
import { Logger } from '@nestjs/common';

@Controller('tasks')
export class TasksController {
  private logger = new Logger('TasksController');
  constructor(private tasksService: TasksService) {}

  // delete all tasks
  @Delete('delete-all')
  deleteAllTasks(): Promise<void> {
    this.logger.verbose('Deleting all tasks');
    return this.tasksService.deleteAllTasks();
  }

  // get all tasks
  @Get()
  getAllTasks(): Promise<Task[]> {
    this.logger.verbose('Getting all tasks');
    return this.tasksService.findAll();
  }

  // get task by id
  @Get(':id')
  getTaskById(@Param('id') id: string): Promise<Task | null> {
    this.logger.verbose(`Getting task with id ${id}`);
    return this.tasksService.findOne(id);
  }

  // create task
  @Post()
  createTask(@Body() createTaskDto: CreateTaskDto): Promise<Task> {
    this.logger.verbose(`Creating task with title ${createTaskDto.title}`);
    return this.tasksService.createTask(createTaskDto);
  }

  // create multiple tasks
  @Post('multiple')
  createMultipleTasks(@Body() createTaskDto: CreateTaskDto[]): Promise<Task[]> {
    this.logger.verbose(`Creating multiple tasks`);
    return this.tasksService.createMultipleTasks(createTaskDto);
  }

  // delete task by id
  @Delete(':id')
  deleteTask(@Param('id') id: string): Promise<DeleteResult> {
    this.logger.verbose(`Deleting task with id ${id}`);
    return this.tasksService.remove(id);
  }

  // update task status
  @Patch(':id/status')
  updateTaskStatus(
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
  ): Promise<Task> {
    this.logger.verbose(`Updating task status with id ${id}`);
    return this.tasksService.updateTaskStatus(id, updateTaskDto);
  }
}
