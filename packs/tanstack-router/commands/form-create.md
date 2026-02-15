---
name: form-create
description: Create TanStack Form components with Zod validation
args:
  - name: name
    description: Form name (e.g., CreatePost, EditUser, Login)
    required: false
  - name: feature
    description: Feature the form belongs to (e.g., posts, users, auth)
    required: false
---

# Create TanStack Form

Create a form component with TanStack Form and Zod validation.

## Instructions

1. **Gather Information** (if not provided via args):
   - Ask for the form name (e.g., `CreatePostForm`, `EditUserForm`)
   - Ask for the feature it belongs to
   - Ask for the fields the form should have
   - Ask if it should integrate with a mutation hook

2. **Create Zod Schema** in `src/features/{feature}/schemas/{name}Schema.ts`:
   ```typescript
   import { z } from 'zod'

   export const {name}Schema = z.object({
     title: z.string().min(3, 'Title must be at least 3 characters'),
     content: z.string().min(10, 'Content must be at least 10 characters'),
     email: z.string().email('Invalid email address'),
     // Add more fields as needed
   })

   export type {Name}FormData = z.infer<typeof {name}Schema>
   ```

3. **Create Form Component** in `src/features/{feature}/components/{Name}Form.tsx`:

   For a **create form**:
   ```typescript
   import { useForm } from '@tanstack/react-form'
   import { zodValidator } from '@tanstack/zod-form-adapter'
   import { {name}Schema, type {Name}FormData } from '../schemas/{name}Schema'
   import { useCreate{Feature} } from '../hooks'
   import { FormField } from '@/components/ui/FormField'

   interface {Name}FormProps {
     onSuccess?: () => void
   }

   export function {Name}Form({ onSuccess }: {Name}FormProps) {
     const create{Feature} = useCreate{Feature}()

     const form = useForm({
       defaultValues: {
         title: '',
         content: '',
         // ... default values for all fields
       } satisfies {Name}FormData,
       onSubmit: async ({ value }) => {
         await create{Feature}.mutateAsync(value)
         onSuccess?.()
       },
       validatorAdapter: zodValidator(),
       validators: {
         onChange: {name}Schema,
       },
     })

     return (
       <form
         onSubmit={(e) => {
           e.preventDefault()
           form.handleSubmit()
         }}
         className="space-y-4"
       >
         <form.Field
           name="title"
           children={(field) => (
             <div className="form-field">
               <label htmlFor={field.name}>Title</label>
               <input
                 id={field.name}
                 value={field.state.value}
                 onChange={(e) => field.handleChange(e.target.value)}
                 onBlur={field.handleBlur}
                 aria-invalid={field.state.meta.errors.length > 0}
                 aria-describedby={`${field.name}-error`}
               />
               {field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
                 <span id={`${field.name}-error`} className="error" role="alert">
                   {field.state.meta.errors[0]}
                 </span>
               )}
             </div>
           )}
         />

         <form.Field
           name="content"
           children={(field) => (
             <div className="form-field">
               <label htmlFor={field.name}>Content</label>
               <textarea
                 id={field.name}
                 value={field.state.value}
                 onChange={(e) => field.handleChange(e.target.value)}
                 onBlur={field.handleBlur}
                 rows={5}
                 aria-invalid={field.state.meta.errors.length > 0}
               />
               {field.state.meta.isTouched && field.state.meta.errors.length > 0 && (
                 <span className="error" role="alert">
                   {field.state.meta.errors[0]}
                 </span>
               )}
             </div>
           )}
         />

         {/* Add more fields as needed */}

         <form.Subscribe
           selector={(state) => [state.canSubmit, state.isSubmitting]}
           children={([canSubmit, isSubmitting]) => (
             <button
               type="submit"
               disabled={!canSubmit || isSubmitting}
               className="btn btn-primary"
             >
               {isSubmitting ? 'Saving...' : 'Save'}
             </button>
           )}
         />

         {create{Feature}.isError && (
           <div className="error" role="alert">
             {create{Feature}.error.message}
           </div>
         )}
       </form>
     )
   }
   ```

   For an **edit form** with initial data:
   ```typescript
   import { useForm } from '@tanstack/react-form'
   import { zodValidator } from '@tanstack/zod-form-adapter'
   import { {name}Schema, type {Name}FormData } from '../schemas/{name}Schema'
   import { useUpdate{Feature} } from '../hooks'
   import type { {Feature} } from '../types'

   interface {Name}FormProps {
     {feature}: {Feature}
     onSuccess?: () => void
   }

   export function {Name}Form({ {feature}, onSuccess }: {Name}FormProps) {
     const update{Feature} = useUpdate{Feature}()

     const form = useForm({
       defaultValues: {
         title: {feature}.title,
         content: {feature}.content,
         // ... populate from existing data
       } satisfies {Name}FormData,
       onSubmit: async ({ value }) => {
         await update{Feature}.mutateAsync({ id: {feature}.id, ...value })
         onSuccess?.()
       },
       validatorAdapter: zodValidator(),
       validators: {
         onChange: {name}Schema,
       },
     })

     return (
       <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit() }}>
         {/* Same field structure as create form */}
       </form>
     )
   }
   ```

4. **Create Reusable Form Field Component** (if not exists) in `src/components/ui/FormField.tsx`:
   ```typescript
   import type { FieldApi } from '@tanstack/react-form'

   interface FormFieldProps<T> {
     field: FieldApi<any, any, any, any, T>
     label: string
     type?: 'text' | 'email' | 'password' | 'textarea' | 'number'
     placeholder?: string
   }

   export function FormField<T extends string | number>({
     field,
     label,
     type = 'text',
     placeholder,
   }: FormFieldProps<T>) {
     const hasError = field.state.meta.isTouched && field.state.meta.errors.length > 0

     const inputProps = {
       id: field.name,
       name: field.name,
       value: field.state.value,
       onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
         const value = type === 'number' ? Number(e.target.value) : e.target.value
         field.handleChange(value as T)
       },
       onBlur: field.handleBlur,
       placeholder,
       'aria-invalid': hasError,
       'aria-describedby': hasError ? `${field.name}-error` : undefined,
     }

     return (
       <div className="form-field">
         <label htmlFor={field.name}>{label}</label>
         {type === 'textarea' ? (
           <textarea {...inputProps} rows={5} />
         ) : (
           <input type={type} {...inputProps} />
         )}
         {hasError && (
           <span id={`${field.name}-error`} className="error" role="alert">
             {field.state.meta.errors[0]}
           </span>
         )}
       </div>
     )
   }
   ```

5. **Handle Array Fields** (if needed):
   ```typescript
   <form.Field
     name="tags"
     mode="array"
     children={(field) => (
       <div className="form-field">
         <label>Tags</label>
         {field.state.value.map((_, index) => (
           <div key={index} className="flex gap-2">
             <form.Field
               name={`tags[${index}]`}
               children={(tagField) => (
                 <input
                   value={tagField.state.value}
                   onChange={(e) => tagField.handleChange(e.target.value)}
                 />
               )}
             />
             <button type="button" onClick={() => field.removeValue(index)}>
               Remove
             </button>
           </div>
         ))}
         <button type="button" onClick={() => field.pushValue('')}>
           Add Tag
         </button>
       </div>
     )}
   />
   ```

6. **Add Async Validation** (if needed):
   ```typescript
   <form.Field
     name="username"
     validators={{
       onChange: z.string().min(3),
       onChangeAsyncDebounceMs: 500,
       onChangeAsync: async ({ value }) => {
         const exists = await checkUsernameExists(value)
         return exists ? 'Username already taken' : undefined
       },
     }}
     children={(field) => (
       <div>
         <input {...inputProps} />
         {field.state.meta.isValidating && <span>Checking...</span>}
         {/* error display */}
       </div>
     )}
   />
   ```

7. **Update Barrel Exports**:
   ```typescript
   // src/features/{feature}/components/index.ts
   export { {Name}Form } from './{Name}Form'

   // src/features/{feature}/schemas/index.ts
   export * from './{name}Schema'
   ```

## Quality Checklist

- [ ] Zod schema validates all fields
- [ ] Form uses `zodValidator()` adapter
- [ ] All fields have proper labels with htmlFor
- [ ] Error messages use role="alert" for accessibility
- [ ] aria-invalid and aria-describedby properly set
- [ ] Submit button disabled during submission
- [ ] Mutation errors displayed to user
- [ ] defaultValues use `satisfies` for type checking
- [ ] Form prevents default submission
