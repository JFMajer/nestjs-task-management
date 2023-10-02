import { Injectable } from '@nestjs/common';
import { TaskStatus } from './task-status.enum';
import { CreateTaskDto } from './dto/create-task.dto';
import { NotFoundException } from '@nestjs/common';
// import { GetTasksFilterDto } from './dto/get-tasks-filter.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { DeleteResult, Repository } from 'typeorm';
import { Task } from './dto/task.entity';
import { Logger } from '@nestjs/common';

@Injectable()
export class TasksService {
  private logger = new Logger('TasksService');
  constructor(
    @InjectRepository(Task) private taskRepository: Repository<Task>,
  ) {}

  async findAll(): Promise<Task[]> {
    const tasks = await this.taskRepository.find();
    if (tasks.length === 0) {
      this.logger.error('No tasks in database');
      throw new NotFoundException('No tasks in database');
    }
    return tasks;
  }

  async findOne(id: string): Promise<Task | null> {
    const taskToBeReturned = await this.taskRepository.findOne({
      where: { id },
    });
    if (!taskToBeReturned) {
      this.logger.error(`Task with ID "${id}" not found`);
      throw new NotFoundException(`Task with ID "${id}" not found`);
    }
    return taskToBeReturned;
  }

  async remove(id: string): Promise<DeleteResult> {
    const result = await this.taskRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Task with ID "${id}" not found`);
    } else {
      return result;
    }
  }

  async createTask(createTaskDto: CreateTaskDto): Promise<Task> {
    const { title, description } = createTaskDto;
    const task = this.taskRepository.create({
      title,
      description,
      status: TaskStatus.OPEN,
    });

    await this.taskRepository.save(task);
    return task;
  }

  async createMultipleTasks(createTaskDtos: CreateTaskDto[]): Promise<Task[]> {
    const createdTasks: Task[] = [];

    for (const createTaskDto of createTaskDtos) {
      const { title, description } = createTaskDto;
      const task = this.taskRepository.create({
        title,
        description,
        status: TaskStatus.OPEN,
      });

      const createdTask = await this.taskRepository.save(task);
      createdTasks.push(createdTask);
    }

    return createdTasks;
  }

  async updateTaskStatus(
    id: string,
    updateTaskDto: UpdateTaskDto,
  ): Promise<Task> {
    const taskToBeUpdated = await this.findOne(id);
    const { status } = updateTaskDto;
    if (!taskToBeUpdated) {
      throw new NotFoundException(`Task with ID "${id}" not found`);
    }
    taskToBeUpdated.status = status;
    return await this.taskRepository.save(taskToBeUpdated);
  }

  async deleteAllTasks(): Promise<void> {
    await this.taskRepository.clear();
  }
}
