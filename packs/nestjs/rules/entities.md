---
paths:
  - "**/*.entity.ts"
---

# NestJS Entity Standards

## Structure

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from 'typeorm'

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ unique: true })
  email: string

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date

  @DeleteDateColumn()
  deletedAt?: Date  // Soft delete
}
```

## Requirements

- UUID primary keys (@PrimaryGeneratedColumn('uuid'))
- Timestamps (createdAt, updatedAt)
- Soft delete (deletedAt with @DeleteDateColumn)
- Explicit table name in @Entity()
- Export from barrel (index.ts)

## Relationships

```typescript
import { Entity, ManyToOne, OneToMany, JoinColumn } from 'typeorm'
import { User } from 'src/users/entities'
import { OrderItem } from 'src/orders/entities'

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @ManyToOne(() => User, user => user.orders)
  @JoinColumn({ name: 'user_id' })
  user: User

  @Column({ name: 'user_id' })
  userId: string

  @OneToMany(() => OrderItem, item => item.order)
  items: OrderItem[]

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date

  @DeleteDateColumn()
  deletedAt?: Date
}
```

## Column Options

```typescript
@Column({ length: 100 })
firstName: string

@Column({ type: 'decimal', precision: 10, scale: 2 })
price: number

@Column({ type: 'enum', enum: OrderStatus, default: OrderStatus.PENDING })
status: OrderStatus

@Column({ nullable: true })
description?: string
```

## Forbidden Patterns

- Auto-increment integer primary keys
- Missing timestamps
- Missing soft delete
- No explicit table name
- Relative imports
