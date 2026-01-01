---
paths:
  - "**/components/**/*.tsx"
  - "**/components/**/*.jsx"
---

# Next.js Component Standards

## Accessibility (WCAG 2.1 AA)

```tsx
// WRONG - No keyboard access
<div onClick={handleClick}>Click me</div>

// CORRECT - Semantic HTML
<button type="button" onClick={handleClick}>
  Click me
</button>
```

## Form Pattern (React Hook Form + Zod)

```tsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

type FormData = z.infer<typeof schema>

export function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <label htmlFor="email">Email</label>
      <input id="email" {...register('email')} aria-describedby="email-error" />
      {errors.email && <span id="email-error" role="alert">{errors.email.message}</span>}
    </form>
  )
}
```

## Import Pattern

```tsx
// CORRECT - Path aliases
import { Button } from '@/components/ui/button'
import { useAuth } from '@/hooks/useAuth'

// WRONG - Deep relative paths
import { Button } from '../../../components/ui/button'
```

## Requirements

- TypeScript strict mode (no `any`)
- Semantic HTML elements
- ARIA attributes where needed
- Error boundaries for async components
- Loading states for data fetching

## Component Structure

```tsx
import { type FC } from 'react'

interface ButtonProps {
  children: React.ReactNode
  variant?: 'primary' | 'secondary'
  disabled?: boolean
  onClick?: () => void
}

export const Button: FC<ButtonProps> = ({
  children,
  variant = 'primary',
  disabled = false,
  onClick,
}) => {
  return (
    <button
      type="button"
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

## Forbidden Patterns

- `any` type
- Non-semantic interactive elements
- Missing form labels
- Inline styles (use Tailwind/CSS modules)
- Missing error boundaries for async components
