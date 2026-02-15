---
name: auth-setup
description: Initialize Better Auth with configuration and optional auth pages
args:
  - name: with-pages
    description: Include login, register, and forgot-password pages
    required: false
  - name: providers
    description: Comma-separated list of social providers (google,github,discord)
    required: false
  - name: 2fa
    description: Enable two-factor authentication
    required: false
  - name: passkeys
    description: Enable passkey/WebAuthn support
    required: false
---

# Setup Better Auth

Initialize Better Auth with full configuration for your React application.

## Instructions

1. **Install Dependencies**:
   ```bash
   bun add better-auth
   bun add -D @types/better-auth
   ```

2. **Create Server Configuration** at `src/lib/auth.ts`:
   ```typescript
   import { betterAuth } from 'better-auth'
   import { prismaAdapter } from 'better-auth/adapters/prisma'
   import { prisma } from './prisma'

   export const auth = betterAuth({
     database: prismaAdapter(prisma, {
       provider: 'postgresql', // or 'mysql', 'sqlite'
     }),

     emailAndPassword: {
       enabled: true,
       requireEmailVerification: true,
       password: {
         minLength: 12,
         requireUppercase: true,
         requireNumber: true,
       },
       sendVerificationEmail: async (user, token, url) => {
         // TODO: Implement email sending
         console.log('Verification URL:', url)
       },
       sendResetPasswordToken: async (user, token, url) => {
         // TODO: Implement email sending
         console.log('Reset URL:', url)
       },
     },

     session: {
       expiresIn: 60 * 60 * 24 * 7, // 7 days
       updateAge: 60 * 60 * 24,     // Extend daily
       cookie: {
         httpOnly: true,
         secure: process.env.NODE_ENV === 'production',
         sameSite: 'lax',
       },
     },

     // Add social providers if requested
     socialProviders: {
       // Configured based on --providers flag
     },

     // Add plugins if requested
     plugins: [
       // Added based on --2fa and --passkeys flags
     ],
   })

   export type Auth = typeof auth
   ```

3. **Create Auth Client** at `src/auth/client.ts`:
   ```typescript
   import { createAuthClient } from 'better-auth/react'
   import type { Auth } from '@/lib/auth'

   export const authClient = createAuthClient<Auth>({
     baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000',
   })

   export const {
     signIn,
     signUp,
     signOut,
     useSession,
     getSession,
     resetPassword,
     verifyEmail,
   } = authClient
   ```

4. **Create Auth Hooks** at `src/auth/hooks.ts`:
   ```typescript
   import { useSession, signOut } from './client'
   import { useNavigate } from '@tanstack/react-router'
   import { useEffect } from 'react'

   export function useAuth() {
     const { data: session, isPending, error } = useSession()

     return {
       user: session?.user ?? null,
       session: session?.session ?? null,
       isAuthenticated: !!session?.user,
       isLoading: isPending,
       error,
     }
   }

   export function useRequireAuth() {
     const auth = useAuth()
     const navigate = useNavigate()

     useEffect(() => {
       if (!auth.isLoading && !auth.isAuthenticated) {
         navigate({ to: '/login' })
       }
     }, [auth.isLoading, auth.isAuthenticated, navigate])

     return auth
   }

   export function useLogout() {
     const navigate = useNavigate()

     return async () => {
       await signOut()
       navigate({ to: '/login' })
     }
   }
   ```

5. **Update Root Route** at `src/routes/__root.tsx`:
   ```typescript
   import { createRootRouteWithContext, Outlet } from '@tanstack/react-router'
   import { getSession } from '@/auth/client'
   import type { QueryClient } from '@tanstack/react-query'

   interface RouterContext {
     queryClient: QueryClient
     session: Awaited<ReturnType<typeof getSession>>['data'] | null
   }

   export const Route = createRootRouteWithContext<RouterContext>()({
     beforeLoad: async () => {
       const result = await getSession()
       return { session: result?.data ?? null }
     },
     component: RootComponent,
   })

   function RootComponent() {
     return (
       <>
         <Outlet />
       </>
     )
   }
   ```

6. **Create Protected Route Layout** at `src/routes/_auth.tsx`:
   ```typescript
   import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'

   export const Route = createFileRoute('/_auth')({
     beforeLoad: async ({ context, location }) => {
       if (!context.session) {
         throw redirect({
           to: '/login',
           search: { redirect: location.pathname },
         })
       }
     },
     component: () => <Outlet />,
   })
   ```

7. **Create Guest Route Layout** at `src/routes/_guest.tsx`:
   ```typescript
   import { createFileRoute, Outlet, redirect } from '@tanstack/react-router'

   export const Route = createFileRoute('/_guest')({
     beforeLoad: async ({ context }) => {
       if (context.session) {
         throw redirect({ to: '/dashboard' })
       }
     },
     component: () => <Outlet />,
   })
   ```

8. **If --with-pages, Create Auth Pages**:

   `src/routes/_guest.login.tsx`:
   ```typescript
   import { createFileRoute } from '@tanstack/react-router'
   import { LoginForm } from '@/features/auth/components/LoginForm'
   import { SocialLoginButtons } from '@/features/auth/components/SocialLoginButtons'

   export const Route = createFileRoute('/_guest/login')({
     component: LoginPage,
   })

   function LoginPage() {
     return (
       <div className="min-h-screen flex items-center justify-center">
         <div className="w-full max-w-md space-y-8">
           <h1 className="text-2xl font-bold text-center">Sign In</h1>
           <LoginForm />
           <div className="relative">
             <div className="absolute inset-0 flex items-center">
               <div className="w-full border-t" />
             </div>
             <div className="relative flex justify-center text-sm">
               <span className="bg-white px-2 text-gray-500">Or continue with</span>
             </div>
           </div>
           <SocialLoginButtons />
         </div>
       </div>
     )
   }
   ```

   `src/routes/_guest.register.tsx`:
   ```typescript
   import { createFileRoute } from '@tanstack/react-router'
   import { RegisterForm } from '@/features/auth/components/RegisterForm'

   export const Route = createFileRoute('/_guest/register')({
     component: RegisterPage,
   })

   function RegisterPage() {
     return (
       <div className="min-h-screen flex items-center justify-center">
         <div className="w-full max-w-md space-y-8">
           <h1 className="text-2xl font-bold text-center">Create Account</h1>
           <RegisterForm />
         </div>
       </div>
     )
   }
   ```

9. **Create Auth Components** in `src/features/auth/components/`:

   - `LoginForm.tsx` - Email/password login form
   - `RegisterForm.tsx` - Registration form
   - `ForgotPasswordForm.tsx` - Password reset request
   - `ResetPasswordForm.tsx` - New password form
   - `SocialLoginButtons.tsx` - OAuth provider buttons

10. **Add Environment Variables** to `.env`:
    ```bash
    # Better Auth
    BETTER_AUTH_SECRET=your-secret-key-min-32-chars

    # Database
    DATABASE_URL=postgresql://...

    # Social Providers (if enabled)
    GOOGLE_CLIENT_ID=
    GOOGLE_CLIENT_SECRET=
    GITHUB_CLIENT_ID=
    GITHUB_CLIENT_SECRET=
    ```

11. **Run Database Migrations**:
    ```bash
    bunx prisma db push
    # or
    bunx prisma migrate dev
    ```

## Quality Checklist

- [ ] Server auth config at `lib/auth.ts`
- [ ] Client at `auth/client.ts` with typed exports
- [ ] Session loaded in `__root.tsx` beforeLoad
- [ ] Protected routes use `_auth.tsx` layout
- [ ] Guest routes use `_guest.tsx` layout
- [ ] Environment variables documented
- [ ] Database adapter configured
- [ ] Email verification enabled
- [ ] Secure session cookies configured
