---
name: route-create
description: Create TanStack Router routes with proper file structure and conventions
args:
  - name: path
    description: Route path (e.g., /posts, /posts/$postId, /users/$userId/settings)
    required: false
  - name: type
    description: Route type (page, layout, pathless, index)
    required: false
---

# Create TanStack Router Route

Create a new route following TanStack Router file-based conventions.

## Instructions

1. **Gather Route Information** (if not provided via args):
   - Ask for the route path (e.g., `/posts/$postId`)
   - Ask for the route type: page, layout, pathless layout, or index
   - Ask if the route needs data loading (loader)
   - Ask if the route needs search params validation

2. **Determine File Name**:
   Convert the path to TanStack Router file naming convention:
   - `/posts` → `posts.tsx` (layout) or `posts.index.tsx` (index)
   - `/posts/$postId` → `posts.$postId.tsx`
   - `/posts/$postId/edit` → `posts_.$postId.edit.tsx`
   - Pathless layout → `_auth.tsx` (prefix with `_`)

3. **Create Route File** in `src/routes/`:

   For a **page route with loader**:
   ```typescript
   import { createFileRoute } from '@tanstack/react-router'
   import { {Feature}QueryOptions } from '@/features/{feature}/queries'
   import { {Component} } from '@/features/{feature}/components'

   export const Route = createFileRoute('{path}')({
     loader: ({ context: { queryClient }, params }) =>
       queryClient.ensureQueryData({feature}QueryOptions(params.{param})),
     component: {Component}Page,
   })

   function {Component}Page() {
     const data = Route.useLoaderData()
     const params = Route.useParams()

     return <{Component} data={data} />
   }
   ```

   For a **route with search params**:
   ```typescript
   import { createFileRoute } from '@tanstack/react-router'
   import { z } from 'zod'

   const searchSchema = z.object({
     page: z.number().default(1),
     sort: z.enum(['newest', 'oldest']).default('newest'),
     search: z.string().optional(),
   })

   export const Route = createFileRoute('{path}')({
     validateSearch: searchSchema,
     component: {Component}Page,
   })

   function {Component}Page() {
     const { page, sort, search } = Route.useSearch()
     const navigate = Route.useNavigate()

     // Update search params
     const setPage = (newPage: number) => {
       navigate({ search: (prev) => ({ ...prev, page: newPage }) })
     }

     return <{Component} page={page} sort={sort} search={search} onPageChange={setPage} />
   }
   ```

   For a **layout route**:
   ```typescript
   import { createFileRoute, Outlet } from '@tanstack/react-router'

   export const Route = createFileRoute('{path}')({
     component: {Feature}Layout,
   })

   function {Feature}Layout() {
     return (
       <div className="{feature}-layout">
         <nav>{/* Feature navigation */}</nav>
         <main>
           <Outlet />
         </main>
       </div>
     )
   }
   ```

   For a **pathless layout** (e.g., auth guard):
   ```typescript
   import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'

   export const Route = createFileRoute('/_auth')({
     beforeLoad: async ({ context }) => {
       if (!context.user) {
         throw redirect({ to: '/login' })
       }
     },
     component: AuthLayout,
   })

   function AuthLayout() {
     return <Outlet />
   }
   ```

4. **Add Error and Loading States** (if data loading):
   ```typescript
   export const Route = createFileRoute('{path}')({
     loader: ...,
     pendingComponent: () => <{Component}Skeleton />,
     errorComponent: ({ error }) => (
       <div className="error">
         <h2>Error loading {feature}</h2>
         <p>{error.message}</p>
       </div>
     ),
     component: {Component}Page,
   })
   ```

5. **Create Query Options** (if needed) in `src/features/{feature}/queries/`:
   ```typescript
   import { queryOptions } from '@tanstack/react-query'
   import { queryKeys } from '@/lib/query-keys'
   import { {feature}Api } from '@/features/{feature}/api'

   export const {feature}QueryOptions = (id: string) =>
     queryOptions({
       queryKey: queryKeys.{feature}.detail(id),
       queryFn: () => {feature}Api.get{Feature}(id),
       staleTime: 5 * 60 * 1000,
     })
   ```

6. **Update Query Keys** (if new feature) in `src/lib/query-keys.ts`:
   ```typescript
   export const queryKeys = {
     // existing keys...
     {feature}: {
       all: () => ['{feature}'] as const,
       lists: () => [...queryKeys.{feature}.all(), 'list'] as const,
       list: (filters: {Feature}Filters) => [...queryKeys.{feature}.lists(), filters] as const,
       details: () => [...queryKeys.{feature}.all(), 'detail'] as const,
       detail: (id: string) => [...queryKeys.{feature}.details(), id] as const,
     },
   } as const
   ```

7. **Regenerate Route Tree**:
   ```bash
   bun run routes:generate
   ```

## File Naming Quick Reference

| URL Path | File Name |
|----------|-----------|
| `/` | `index.tsx` |
| `/about` | `about.tsx` |
| `/posts` (layout) | `posts.tsx` |
| `/posts` (page) | `posts.index.tsx` |
| `/posts/$postId` | `posts.$postId.tsx` |
| `/posts/$postId/edit` | `posts_.$postId.edit.tsx` |
| Auth wrapper | `_auth.tsx` |
| Catch-all | `$.tsx` |

## Quality Checklist

- [ ] File name follows TanStack Router conventions
- [ ] Route uses `createFileRoute` with correct path
- [ ] Loader uses `ensureQueryData` (not direct fetch)
- [ ] Search params validated with Zod schema
- [ ] Error and pending components provided for data routes
- [ ] Component uses `Route.useParams()` and `Route.useLoaderData()`
- [ ] Route tree regenerated after creation
