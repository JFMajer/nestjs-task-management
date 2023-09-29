import { Module } from '@nestjs/common';
import { TasksModule } from './tasks/tasks.module';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
    TasksModule,
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: 5432,
      username: 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: 'tasks',
      autoLoadEntities: true,
      synchronize: true,
    }),
  ],
})
export class AppModule {}
