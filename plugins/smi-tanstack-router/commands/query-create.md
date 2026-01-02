---
name: query-create
description: Create TanStack Query options, mutations, and hooks with factory pattern
args:
  - name: feature
    description: Feature name (e.g., posts, users, orders)
    required: false
  - name: type
    description: Query type (query, mutation, infinite)
    required: false
---

# Create TanStack Query

Create query options, mutations, and hooks following the factory pattern.

## Instructions

1. **Gather Information** (if not provided via args):
   - Ask for the feature name (e.g., `posts`, `users`)
   - Ask for the query type: query, mutation, or infinite query
   - Ask for the operation (e.g., list, detail, create, update, delete)

2. **Create Feature Directory Structure** (if new feature):
   ```
   src/features/{feature}/
   ├── api/
   │   └── {feature}Api.ts
   ├── queries/
   │   ├── {feature}Queries.ts
   │   └── index.ts
   ├── hooks/
   │   ├── use{Operation}{Feature}.ts
   │   └── index.ts
   ├── types.ts
   └── index.ts
   ```

3. **Create/Update Query Keys** in `src/lib/query-keys.ts`:
   ```typescript
   export const queryKeys = {
     {feature}: {
       all: () => ['{feature}'] as const,
       lists: () => [...queryKeys.{feature}.all(), 'list'] as const,
       list: (filters: {Feature}Filters) => [...queryKeys.{feature}.lists(), filters] as const,
       details: () => [...queryKeys.{feature}.all(), 'detail'] as const,
       detail: (id: string) => [...queryKeys.{feature}.details(), id] as const,
     },
   } as const
   ```

4. **Create API Functions** in `src/features/{feature}/api/{feature}Api.ts`:
   ```typescript
   import { apiClient } from '@/lib/api-client'
   import type { {Feature}, Create{Feature}Input, Update{Feature}Input, {Feature}Filters } from '../types'

   export const {feature}Api = {
     get{Feature}s: async (filters?: {Feature}Filters): Promise<{Feature}[]> => {
       const response = await apiClient.get('/{feature}', { params: filters })
       return response.data
     },

     get{Feature}: async (id: string): Promise<{Feature}> => {
       const response = await apiClient.get(`/{feature}/${id}`)
       return response.data
     },

     create{Feature}: async (input: Create{Feature}Input): Promise<{Feature}> => {
       const response = await apiClient.post('/{feature}', input)
       return response.data
     },

     update{Feature}: async ({ id, ...input }: Update{Feature}Input): Promise<{Feature}> => {
       const response = await apiClient.patch(`/{feature}/${id}`, input)
       return response.data
     },

     delete{Feature}: async (id: string): Promise<void> => {
       await apiClient.delete(`/{feature}/${id}`)
     },
   }
   ```

5. **Create Query Options** in `src/features/{feature}/queries/{feature}Queries.ts`:

   For **list query**:
   ```typescript
   import { queryOptions } from '@tanstack/react-query'
   import { queryKeys } from '@/lib/query-keys'
   import { {feature}Api } from '../api/{feature}Api'
   import type { {Feature}Filters } from '../types'

   export const {feature}sQueryOptions = (filters: {Feature}Filters = {}) =>
     queryOptions({
       queryKey: queryKeys.{feature}.list(filters),
       queryFn: () => {feature}Api.get{Feature}s(filters),
       staleTime: 1 * 60 * 1000, // 1 minute
     })
   ```

   For **detail query**:
   ```typescript
   export const {feature}QueryOptions = (id: string) =>
     queryOptions({
       queryKey: queryKeys.{feature}.detail(id),
       queryFn: () => {feature}Api.get{Feature}(id),
       staleTime: 5 * 60 * 1000, // 5 minutes
     })
   ```

   For **infinite query**:
   ```typescript
   import { infiniteQueryOptions } from '@tanstack/react-query'

   export const {feature}sInfiniteQueryOptions = (filters: {Feature}Filters = {}) =>
     infiniteQueryOptions({
       queryKey: queryKeys.{feature}.list({ ...filters, infinite: true }),
       queryFn: ({ pageParam = 1 }) =>
         {feature}Api.get{Feature}s({ ...filters, page: pageParam }),
       getNextPageParam: (lastPage) =>
         lastPage.hasMore ? lastPage.nextPage : undefined,
       initialPageParam: 1,
     })
   ```

6. **Create Mutation Hooks** in `src/features/{feature}/hooks/`:

   For **create mutation** (`useCreate{Feature}.ts`):
   ```typescript
   import { useMutation, useQueryClient } from '@tanstack/react-query'
   import { queryKeys } from '@/lib/query-keys'
   import { {feature}Api } from '../api/{feature}Api'

   export function useCreate{Feature}() {
     const queryClient = useQueryClient()

     return useMutation({
       mutationFn: {feature}Api.create{Feature},
       onSuccess: () => {
         queryClient.invalidateQueries({ queryKey: queryKeys.{feature}.lists() })
       },
     })
   }
   ```

   For **update mutation** with optimistic update (`useUpdate{Feature}.ts`):
   ```typescript
   import { useMutation, useQueryClient } from '@tanstack/react-query'
   import { queryKeys } from '@/lib/query-keys'
   import { {feature}Api } from '../api/{feature}Api'
   import type { {Feature}, Update{Feature}Input } from '../types'

   export function useUpdate{Feature}() {
     const queryClient = useQueryClient()

     return useMutation({
       mutationFn: {feature}Api.update{Feature},
       onMutate: async (newData: Update{Feature}Input) => {
         await queryClient.cancelQueries({
           queryKey: queryKeys.{feature}.detail(newData.id)
         })

         const previous = queryClient.getQueryData<{Feature}>(
           queryKeys.{feature}.detail(newData.id)
         )

         queryClient.setQueryData(
           queryKeys.{feature}.detail(newData.id),
           (old: {Feature} | undefined) => old ? { ...old, ...newData } : undefined
         )

         return { previous }
       },
       onError: (err, newData, context) => {
         if (context?.previous) {
           queryClient.setQueryData(
             queryKeys.{feature}.detail(newData.id),
             context.previous
           )
         }
       },
       onSettled: (data, error, variables) => {
         queryClient.invalidateQueries({
           queryKey: queryKeys.{feature}.detail(variables.id)
         })
       },
     })
   }
   ```

   For **delete mutation** (`useDelete{Feature}.ts`):
   ```typescript
   import { useMutation, useQueryClient } from '@tanstack/react-query'
   import { queryKeys } from '@/lib/query-keys'
   import { {feature}Api } from '../api/{feature}Api'

   export function useDelete{Feature}() {
     const queryClient = useQueryClient()

     return useMutation({
       mutationFn: {feature}Api.delete{Feature},
       onSuccess: () => {
         queryClient.invalidateQueries({ queryKey: queryKeys.{feature}.all() })
       },
     })
   }
   ```

7. **Create Types** in `src/features/{feature}/types.ts`:
   ```typescript
   export interface {Feature} {
     id: string
     // ... feature fields
     createdAt: string
     updatedAt: string
   }

   export interface Create{Feature}Input {
     // ... creation fields
   }

   export interface Update{Feature}Input extends Partial<Create{Feature}Input> {
     id: string
   }

   export interface {Feature}Filters {
     page?: number
     pageSize?: number
     search?: string
     // ... filter fields
   }
   ```

8. **Create Barrel Exports**:

   `src/features/{feature}/queries/index.ts`:
   ```typescript
   export * from './{feature}Queries'
   ```

   `src/features/{feature}/hooks/index.ts`:
   ```typescript
   export * from './useCreate{Feature}'
   export * from './useUpdate{Feature}'
   export * from './useDelete{Feature}'
   ```

   `src/features/{feature}/index.ts`:
   ```typescript
   export * from './queries'
   export * from './hooks'
   export * from './types'
   ```

## Quality Checklist

- [ ] Query keys follow factory pattern
- [ ] Query options use `queryOptions()` helper
- [ ] Mutations invalidate relevant queries
- [ ] Optimistic updates include rollback logic
- [ ] Types are properly defined and exported
- [ ] Barrel exports are in place
- [ ] API functions match expected backend endpoints
