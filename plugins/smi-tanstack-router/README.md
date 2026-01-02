# smi-tanstack-router

TanStack SPA development with the full ecosystem: Router, Query, Form, Table, Virtual, and experimental libraries.

## Overview

This plugin provides comprehensive support for building React SPAs with the TanStack ecosystem, using Bun as the runtime and following feature-based architecture with `@/` import aliases.

## Installation

```bash
/plugin install smi-tanstack-router
```

## Features

### Core Libraries
- **TanStack Router** - Type-safe file-based routing
- **TanStack Query** - Server state management with factory key patterns
- **TanStack Form** - Type-safe form handling
- **TanStack Table** - Headless table/datagrid
- **TanStack Virtual** - List virtualization

### Experimental Libraries (Alpha/Beta)
- **TanStack Store** - Framework-agnostic state
- **TanStack DB** - Client-first reactive store
- **TanStack AI** - Unified AI SDK
- **TanStack Pacer** - Rate limiting, debouncing, throttling
- **TanStack Devtools** - Unified debugging tools

## Agents

| Agent | Purpose |
|-------|---------|
| `tanstack-architect` | Design TanStack application architecture |
| `tanstack-builder` | Implement features with TanStack patterns |
| `tanstack-tester` | Write tests for TanStack applications |

## Commands

| Command | Description |
|---------|-------------|
| `/route-create` | Create a new file-based route |
| `/query-create` | Create query with factory key pattern |
| `/form-create` | Create type-safe form with validation |
| `/table-create` | Create headless table component |

## Conventions

### Folder Structure (Feature-Based)
```
src/
├── features/
│   ├── posts/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── queries/
│   │   └── types.ts
│   └── users/
├── routes/
│   ├── __root.tsx
│   ├── index.tsx
│   └── posts/
│       ├── index.tsx
│       └── $postId.tsx
├── lib/
│   ├── query-client.ts
│   └── query-keys.ts
└── components/
    └── ui/
```

### Import Alias
```typescript
import { PostList } from '@/features/posts/components'
import { queryKeys } from '@/lib/query-keys'
```

### Query Key Factory Pattern
```typescript
export const queryKeys = {
  posts: {
    all: () => ['posts'] as const,
    lists: () => [...queryKeys.posts.all(), 'list'] as const,
    list: (filters: Filters) => [...queryKeys.posts.lists(), filters] as const,
    details: () => [...queryKeys.posts.all(), 'detail'] as const,
    detail: (id: string) => [...queryKeys.posts.details(), id] as const,
  }
}
```

### Data Fetching (Hybrid Approach)
- **Loaders**: Prefetch data in route loaders
- **Queries**: Hydrate and manage in components

```typescript
// Route loader prefetches
export const Route = createFileRoute('/posts/$postId')({
  loader: ({ context, params }) =>
    context.queryClient.ensureQueryData(postQueryOptions(params.postId)),
})

// Component hydrates
function PostPage() {
  const { postId } = Route.useParams()
  const { data } = useSuspenseQuery(postQueryOptions(postId))
}
```

## Runtime

- **Bun** - Package manager and runtime
- Commands use `bun` instead of `npm`/`yarn`
