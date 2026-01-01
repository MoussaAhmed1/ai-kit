---
paths:
  - "**/*.controller.ts"
---

# NestJS Controller Standards

## Structure

```typescript
import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common'
import { JwtAuthGuard } from 'src/auth/guards'
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'
import { CreateUserDto, UserResponseDto } from 'src/users/dto'

@Controller('users')
@UseGuards(JwtAuthGuard)  // REQUIRED
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto)
  }
}
```

## Requirements

- Guards on all protected routes (@UseGuards)
- DTOs for all inputs
- Response DTOs for outputs
- Absolute imports from barrel exports
- Constructor injection for dependencies

## Import Pattern

```typescript
// CORRECT - Absolute imports from barrel exports
import { UsersService } from 'src/users/services'
import { CreateUserDto } from 'src/users/dto'
import { User } from 'src/users/entities'

// WRONG - Relative imports
import { UsersService } from './users.service'
import { CreateUserDto } from '../dto/create-user.dto'
```

## Method Decorators

```typescript
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  @Get()
  findAll(): Promise<UserResponseDto[]> {
    return this.usersService.findAll()
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    return this.usersService.findOne(id)
  }

  @Post()
  create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto)
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    return this.usersService.update(id, dto)
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.usersService.remove(id)
  }
}
```

## Forbidden Patterns

- Controllers without @UseGuards
- Direct repository access (use services)
- Business logic in controllers
- Any type in parameters or return types
