---
paths:
  - "**/*.dto.ts"
---

# NestJS DTO Standards

## Structure

```typescript
import { IsEmail, IsString, MinLength, IsOptional } from 'class-validator'
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

export class CreateUserDto {
  @ApiProperty({ description: 'User email address' })
  @IsEmail()
  email: string

  @ApiProperty({ description: 'User password', minLength: 8 })
  @IsString()
  @MinLength(8)
  password: string

  @ApiPropertyOptional({ description: 'User first name' })
  @IsOptional()
  @IsString()
  firstName?: string
}
```

## Requirements

- class-validator decorators for validation
- @nestjs/swagger decorators for API documentation
- Separate DTOs for create, update, response
- Export from barrel (index.ts)

## Naming Convention

- Create DTOs: `Create{Entity}Dto`
- Update DTOs: `Update{Entity}Dto`
- Response DTOs: `{Entity}ResponseDto`
- Query DTOs: `{Entity}QueryDto`

## Update DTOs with PartialType

```typescript
import { PartialType } from '@nestjs/swagger'
import { CreateUserDto } from './create-user.dto'

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

## Response DTOs

```typescript
import { Exclude, Expose } from 'class-transformer'

export class UserResponseDto {
  @Expose()
  id: string

  @Expose()
  email: string

  @Expose()
  firstName: string

  @Expose()
  createdAt: Date

  @Exclude()
  password: string  // Never expose
}
```

## Validation Examples

```typescript
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  IsUUID,
  IsEnum,
  IsInt,
  Min,
  Max,
  IsArray,
  ValidateNested,
} from 'class-validator'
import { Type } from 'class-transformer'

export class CreateOrderDto {
  @IsUUID()
  userId: string

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[]

  @IsEnum(PaymentMethod)
  paymentMethod: PaymentMethod
}

export class OrderItemDto {
  @IsUUID()
  productId: string

  @IsInt()
  @Min(1)
  @Max(100)
  quantity: number
}
```

## Forbidden Patterns

- DTOs without validation decorators
- Exposing sensitive fields in response DTOs
- Using `any` type
- Missing Swagger documentation
