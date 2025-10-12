# NestJS Development Standards Plugin

Smicolon company standards for NestJS/TypeScript backend projects.

## Installation

```bash
# Add Smicolon marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install NestJS plugin
/plugin install smi-nestjs
```

## What's Included

### 3 Specialized Agents

- `@nestjs-architect` - Backend architecture design and planning
- `@nestjs-builder` - Feature implementation with NestJS best practices
- `@nestjs-tester` - Test writing for NestJS applications

### Automatic Convention Enforcement

**Import Pattern:**
```typescript
// CORRECT - Absolute imports from barrel exports
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'
import { CreateUserDto } from 'src/users/dto'

// WRONG - Relative imports
import { User } from './entities/user.entity'
```

**Entity Standards:**
- UUID primary keys
- Timestamps (createdAt, updatedAt)
- Soft deletes (deletedAt)
- DTOs with class-validator
- Dependency injection
- Guards on protected routes
- Barrel exports (index.ts) in all folders

## Usage

```bash
# Design architecture
@nestjs-architect "Design a REST API for inventory management"

# Implement features
@nestjs-builder "Implement inventory API endpoints"

# Write tests
@nestjs-tester "Write tests for inventory module"
```

## Documentation

See the main [Smicolon Claude Infra repository](https://github.com/smicolon/claude-infra) for complete documentation.
