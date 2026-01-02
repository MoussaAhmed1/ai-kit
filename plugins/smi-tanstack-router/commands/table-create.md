---
name: table-create
description: Create TanStack Table components with sorting, filtering, and pagination
args:
  - name: name
    description: Table name (e.g., PostsTable, UsersTable)
    required: false
  - name: feature
    description: Feature the table belongs to (e.g., posts, users)
    required: false
---

# Create TanStack Table

Create a data table component with TanStack Table, including sorting, filtering, and pagination.

## Instructions

1. **Gather Information** (if not provided via args):
   - Ask for the table name (e.g., `PostsTable`)
   - Ask for the feature it belongs to
   - Ask what columns to include
   - Ask what features to enable: sorting, filtering, pagination, row selection

2. **Create Column Definitions** in `src/features/{feature}/components/{Name}Columns.tsx`:
   ```typescript
   import { createColumnHelper } from '@tanstack/react-table'
   import { Link } from '@tanstack/react-router'
   import type { {Feature} } from '../types'

   const columnHelper = createColumnHelper<{Feature}>()

   export const {name}Columns = [
     columnHelper.accessor('title', {
       header: ({ column }) => (
         <button
           onClick={() => column.toggleSorting()}
           className="flex items-center gap-1"
         >
           Title
           {column.getIsSorted() === 'asc' && ' ↑'}
           {column.getIsSorted() === 'desc' && ' ↓'}
         </button>
       ),
       cell: (info) => (
         <Link
           to="/{feature}/$id"
           params={{ id: info.row.original.id }}
           className="hover:underline"
         >
           {info.getValue()}
         </Link>
       ),
     }),

     columnHelper.accessor('status', {
       header: 'Status',
       cell: (info) => (
         <span className={`badge badge-${info.getValue()}`}>
           {info.getValue()}
         </span>
       ),
       filterFn: 'equals',
     }),

     columnHelper.accessor('createdAt', {
       header: 'Created',
       cell: (info) => new Date(info.getValue()).toLocaleDateString(),
       sortingFn: 'datetime',
     }),

     columnHelper.display({
       id: 'actions',
       header: 'Actions',
       cell: ({ row }) => (
         <div className="flex gap-2">
           <Link to="/{feature}/$id/edit" params={{ id: row.original.id }}>
             Edit
           </Link>
           <button onClick={() => handleDelete(row.original.id)}>
             Delete
           </button>
         </div>
       ),
     }),
   ]
   ```

3. **Create Table Component** in `src/features/{feature}/components/{Name}Table.tsx`:

   For a **basic table**:
   ```typescript
   import {
     useReactTable,
     getCoreRowModel,
     flexRender,
   } from '@tanstack/react-table'
   import { {name}Columns } from './{Name}Columns'
   import type { {Feature} } from '../types'

   interface {Name}TableProps {
     data: {Feature}[]
   }

   export function {Name}Table({ data }: {Name}TableProps) {
     const table = useReactTable({
       data,
       columns: {name}Columns,
       getCoreRowModel: getCoreRowModel(),
     })

     return (
       <table className="w-full">
         <thead>
           {table.getHeaderGroups().map((headerGroup) => (
             <tr key={headerGroup.id}>
               {headerGroup.headers.map((header) => (
                 <th key={header.id} className="text-left p-2">
                   {header.isPlaceholder
                     ? null
                     : flexRender(
                         header.column.columnDef.header,
                         header.getContext()
                       )}
                 </th>
               ))}
             </tr>
           ))}
         </thead>
         <tbody>
           {table.getRowModel().rows.map((row) => (
             <tr key={row.id} className="border-t">
               {row.getVisibleCells().map((cell) => (
                 <td key={cell.id} className="p-2">
                   {flexRender(cell.column.columnDef.cell, cell.getContext())}
                 </td>
               ))}
             </tr>
           ))}
         </tbody>
       </table>
     )
   }
   ```

   For a **full-featured table** with sorting, filtering, pagination:
   ```typescript
   import { useState } from 'react'
   import {
     useReactTable,
     getCoreRowModel,
     getSortedRowModel,
     getFilteredRowModel,
     getPaginationRowModel,
     flexRender,
     type SortingState,
     type ColumnFiltersState,
   } from '@tanstack/react-table'
   import { {name}Columns } from './{Name}Columns'
   import type { {Feature} } from '../types'

   interface {Name}TableProps {
     data: {Feature}[]
   }

   export function {Name}Table({ data }: {Name}TableProps) {
     const [sorting, setSorting] = useState<SortingState>([])
     const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
     const [globalFilter, setGlobalFilter] = useState('')

     const table = useReactTable({
       data,
       columns: {name}Columns,
       state: {
         sorting,
         columnFilters,
         globalFilter,
       },
       onSortingChange: setSorting,
       onColumnFiltersChange: setColumnFilters,
       onGlobalFilterChange: setGlobalFilter,
       getCoreRowModel: getCoreRowModel(),
       getSortedRowModel: getSortedRowModel(),
       getFilteredRowModel: getFilteredRowModel(),
       getPaginationRowModel: getPaginationRowModel(),
       initialState: {
         pagination: { pageSize: 10 },
       },
     })

     return (
       <div className="space-y-4">
         {/* Search */}
         <input
           type="search"
           placeholder="Search..."
           value={globalFilter}
           onChange={(e) => setGlobalFilter(e.target.value)}
           className="input"
         />

         {/* Column Filters */}
         <div className="flex gap-4">
           <select
             value={(table.getColumn('status')?.getFilterValue() as string) ?? ''}
             onChange={(e) =>
               table.getColumn('status')?.setFilterValue(e.target.value || undefined)
             }
           >
             <option value="">All statuses</option>
             <option value="draft">Draft</option>
             <option value="published">Published</option>
           </select>
         </div>

         {/* Table */}
         <table className="w-full">
           <thead>
             {table.getHeaderGroups().map((headerGroup) => (
               <tr key={headerGroup.id}>
                 {headerGroup.headers.map((header) => (
                   <th key={header.id} className="text-left p-2">
                     {header.isPlaceholder
                       ? null
                       : flexRender(
                           header.column.columnDef.header,
                           header.getContext()
                         )}
                   </th>
                 ))}
               </tr>
             ))}
           </thead>
           <tbody>
             {table.getRowModel().rows.length === 0 ? (
               <tr>
                 <td colSpan={table.getAllColumns().length} className="text-center p-4">
                   No results found
                 </td>
               </tr>
             ) : (
               table.getRowModel().rows.map((row) => (
                 <tr key={row.id} className="border-t hover:bg-gray-50">
                   {row.getVisibleCells().map((cell) => (
                     <td key={cell.id} className="p-2">
                       {flexRender(cell.column.columnDef.cell, cell.getContext())}
                     </td>
                   ))}
                 </tr>
               ))
             )}
           </tbody>
         </table>

         {/* Pagination */}
         <div className="flex items-center justify-between">
           <span>
             Showing {table.getState().pagination.pageIndex * table.getState().pagination.pageSize + 1} to{' '}
             {Math.min(
               (table.getState().pagination.pageIndex + 1) * table.getState().pagination.pageSize,
               table.getFilteredRowModel().rows.length
             )}{' '}
             of {table.getFilteredRowModel().rows.length}
           </span>

           <div className="flex gap-2">
             <button
               onClick={() => table.previousPage()}
               disabled={!table.getCanPreviousPage()}
               className="btn"
             >
               Previous
             </button>
             <span className="flex items-center">
               Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
             </span>
             <button
               onClick={() => table.nextPage()}
               disabled={!table.getCanNextPage()}
               className="btn"
             >
               Next
             </button>
           </div>

           <select
             value={table.getState().pagination.pageSize}
             onChange={(e) => table.setPageSize(Number(e.target.value))}
           >
             {[10, 20, 50].map((size) => (
               <option key={size} value={size}>
                 Show {size}
               </option>
             ))}
           </select>
         </div>
       </div>
     )
   }
   ```

4. **Create Server-Side Pagination Table** (for large datasets):
   ```typescript
   import { Route } from '@tanstack/react-router'

   export function {Name}Table() {
     const { page, pageSize, sort } = Route.useSearch()
     const navigate = Route.useNavigate()

     const { data, isLoading } = useQuery({
       queryKey: queryKeys.{feature}.list({ page, pageSize, sort }),
       queryFn: () => {feature}Api.get{Feature}s({ page, pageSize, sort }),
     })

     const table = useReactTable({
       data: data?.items ?? [],
       columns: {name}Columns,
       pageCount: data?.pageCount ?? -1,
       state: {
         pagination: { pageIndex: page - 1, pageSize },
       },
       onPaginationChange: (updater) => {
         const newState =
           typeof updater === 'function'
             ? updater({ pageIndex: page - 1, pageSize })
             : updater
         navigate({
           search: (prev) => ({
             ...prev,
             page: newState.pageIndex + 1,
             pageSize: newState.pageSize,
           }),
         })
       },
       getCoreRowModel: getCoreRowModel(),
       manualPagination: true,
     })

     if (isLoading) return <TableSkeleton />

     return (/* Table JSX */)
   }
   ```

5. **Add Row Selection** (if needed):
   ```typescript
   import { useState } from 'react'
   import type { RowSelectionState } from '@tanstack/react-table'

   export function {Name}Table({ data, onSelectionChange }: Props) {
     const [rowSelection, setRowSelection] = useState<RowSelectionState>({})

     // Add selection column
     const columnsWithSelection = [
       columnHelper.display({
         id: 'select',
         header: ({ table }) => (
           <input
             type="checkbox"
             checked={table.getIsAllRowsSelected()}
             onChange={table.getToggleAllRowsSelectedHandler()}
           />
         ),
         cell: ({ row }) => (
           <input
             type="checkbox"
             checked={row.getIsSelected()}
             onChange={row.getToggleSelectedHandler()}
           />
         ),
       }),
       ...{name}Columns,
     ]

     const table = useReactTable({
       data,
       columns: columnsWithSelection,
       state: { rowSelection },
       onRowSelectionChange: setRowSelection,
       getCoreRowModel: getCoreRowModel(),
       enableRowSelection: true,
     })

     // Get selected rows
     const selectedRows = table.getSelectedRowModel().rows.map((r) => r.original)

     return (
       <div>
         <span>{selectedRows.length} selected</span>
         {/* Table JSX */}
       </div>
     )
   }
   ```

6. **Update Barrel Exports**:
   ```typescript
   // src/features/{feature}/components/index.ts
   export { {Name}Table } from './{Name}Table'
   export { {name}Columns } from './{Name}Columns'
   ```

## Quality Checklist

- [ ] Columns defined outside component or memoized
- [ ] All cells use `flexRender()`
- [ ] Sortable columns have toggle handler
- [ ] Empty state displayed when no data
- [ ] Pagination shows current range and total
- [ ] Row selection includes select-all checkbox
- [ ] Server pagination uses `manualPagination: true`
- [ ] Loading state shown during data fetch
- [ ] Actions column has proper key handling
