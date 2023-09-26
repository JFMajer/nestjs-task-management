import { Injectable } from '@nestjs/common';
import { TaskStatus } from './task.model';
import { v4 } from 'uuid';
import { CreateTaskDto } from './dto/create-task.dto';
import { NotFoundException } from '@nestjs/common';
// import { GetTasksFilterDto } from './dto/get-tasks-filter.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './dto/task.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task) private taskRepository: Repository<Task>,
  ) {}

  async findAll(): Promise<Task[]> {
    const tasks = await this.taskRepository.find();
    if (tasks.length === 0) {
      throw new NotFoundException('No tasks in database');
    }
    return tasks;
  }

  async findOne(id: string): Promise<Task | null> {
    const taskToBeReturned = await this.taskRepository.findOne({
      where: { id },
    });
    if (!taskToBeReturned) {
      throw new NotFoundException(`Task with ID "${id}" not found`);
    }
    return taskToBeReturned;
  }

  async remove(id: string): Promise<void> {
    await this.taskRepository.delete(id);
  }

  async createTask(createTaskDto: CreateTaskDto): Promise<Task> {
    const { title, description } = createTaskDto;
    const task: Task = {
      id: v4(),
      title,
      description,
      status: TaskStatus.OPEN,
    };
    return await this.taskRepository.save(task);
  }

  async createMultipleTasks(createTaskDtos: CreateTaskDto[]): Promise<Task[]> {
    const createdTasks: Task[] = [];

    for (const createTaskDto of createTaskDtos) {
      const { title, description } = createTaskDto;
      const task: Task = {
        id: v4(),
        title,
        description,
        status: TaskStatus.OPEN,
      };

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
}
