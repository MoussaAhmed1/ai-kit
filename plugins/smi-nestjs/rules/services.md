---
paths:
  - "**/*.service.ts"
---

# NestJS Service Standards

## Structure

```typescript
import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { User } from 'src/users/entities'
import { CreateUserDto, UpdateUserDto } from 'src/users/dto'

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find()
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } })
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`)
    }
    return user
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(dto)
    return this.usersRepository.save(user)
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id)
    Object.assign(user, dto)
    return this.usersRepository.save(user)
  }

  async remove(id: string): Promise<void> {
    await this.usersRepository.softDelete(id)
  }
}
```

## Requirements

- @Injectable() decorator
- Constructor injection for repositories
- Proper error handling with NestJS exceptions
- Soft delete using softDelete()
- Absolute imports from barrel exports

## Import Pattern

```typescript
// CORRECT
import { User } from 'src/users/entities'
import { CreateUserDto } from 'src/users/dto'

// WRONG
import { User } from './entities/user.entity'
```

## Transaction Support

```typescript
import { DataSource } from 'typeorm'

@Injectable()
export class OrdersService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(Order)
    private readonly ordersRepository: Repository<Order>,
  ) {}

  async createWithItems(dto: CreateOrderDto): Promise<Order> {
    return this.dataSource.transaction(async manager => {
      const order = manager.create(Order, { userId: dto.userId })
      await manager.save(order)

      for (const item of dto.items) {
        const orderItem = manager.create(OrderItem, { ...item, orderId: order.id })
        await manager.save(orderItem)
      }

      return order
    })
  }
}
```

## Forbidden Patterns

- Missing @Injectable() decorator
- Direct database operations without repository
- Catching exceptions without re-throwing
- Hard deletes (use softDelete)
