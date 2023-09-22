import { Injectable } from '@nestjs/common';
import { Task, TaskStatus } from './task.model';
import { v4 } from 'uuid';
import { CreateTaskDto } from './dto/create-task.dto';
import { NotFoundException } from '@nestjs/common';
import { GetTasksFilterDto } from './dto/get-tasks-filter.dto';

@Injectable()
export class TasksService {
  private tasks: Task[] = [];

  getAllTasks(): Task[] {
    return this.tasks;
  }

  getTasksWithFilters(filterDto: GetTasksFilterDto): Task[] {
    const { status, search } = filterDto;

    let tasksToBeReturned = this.getAllTasks();

    if (status) {
      tasksToBeReturned = tasksToBeReturned.filter(
        task => task.status === status,
      );
    }

    if (search) {
      tasksToBeReturned = tasksToBeReturned.filter(
        task =>
          task.title.includes(search) || task.description.includes(search),
      );
    }

    return tasksToBeReturned;
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

  remove(id: string) {
    const taskToBeDeleted = this.findOne(id);
    this.tasks = this.tasks.filter(task => task.id !== taskToBeDeleted.id);
  }

  updateTaskStatus(id: string, status: TaskStatus): Task {
    const taskToBeUpdated = this.findOne(id);
    if (!taskToBeUpdated) {
      throw new NotFoundException(`Task with ID "${id}" not found`);
    }
    taskToBeUpdated.status = status;
    return taskToBeUpdated;
  }
}
