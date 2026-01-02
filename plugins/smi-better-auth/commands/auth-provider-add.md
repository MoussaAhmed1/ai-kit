---
name: auth-provider-add
description: Add a new authentication provider to Better Auth
args:
  - name: provider
    description: Provider name (google, github, discord, apple, microsoft, etc.)
    required: false
  - name: scopes
    description: Comma-separated OAuth scopes (e.g., "user:email,read:org")
    required: false
---

# Add Authentication Provider

Add a new social/OAuth provider to your Better Auth configuration.

## Supported Providers

- **google** - Google OAuth 2.0
- **github** - GitHub OAuth
- **discord** - Discord OAuth
- **apple** - Apple Sign In
- **microsoft** - Microsoft Identity
- **twitter** - Twitter/X OAuth 2.0
- **facebook** - Facebook Login
- **linkedin** - LinkedIn OAuth
- **gitlab** - GitLab OAuth
- **slack** - Slack OAuth

## Instructions

1. **Get Provider Credentials**:

   **Google**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create OAuth 2.0 credentials
   - Add authorized redirect URI: `{YOUR_API_URL}/api/auth/callback/google`

   **GitHub**:
   - Go to [GitHub Developer Settings](https://github.com/settings/developers)
   - Create new OAuth App
   - Set callback URL: `{YOUR_API_URL}/api/auth/callback/github`

   **Discord**:
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Create application, get OAuth2 credentials
   - Add redirect: `{YOUR_API_URL}/api/auth/callback/discord`

   **Apple**:
   - Go to [Apple Developer](https://developer.apple.com/)
   - Create Service ID with Sign In with Apple capability
   - Configure return URL: `{YOUR_API_URL}/api/auth/callback/apple`

   **Microsoft**:
   - Go to [Azure Portal](https://portal.azure.com/)
   - Register application in Azure AD
   - Add redirect URI: `{YOUR_API_URL}/api/auth/callback/microsoft`

2. **Add Environment Variables** to `.env`:
   ```bash
   # Google
   GOOGLE_CLIENT_ID=your-client-id
   GOOGLE_CLIENT_SECRET=your-client-secret

   # GitHub
   GITHUB_CLIENT_ID=your-client-id
   GITHUB_CLIENT_SECRET=your-client-secret

   # Discord
   DISCORD_CLIENT_ID=your-client-id
   DISCORD_CLIENT_SECRET=your-client-secret

   # Apple
   APPLE_CLIENT_ID=your-service-id
   APPLE_CLIENT_SECRET=your-client-secret
   APPLE_TEAM_ID=your-team-id
   APPLE_KEY_ID=your-key-id

   # Microsoft
   MICROSOFT_CLIENT_ID=your-client-id
   MICROSOFT_CLIENT_SECRET=your-client-secret
   MICROSOFT_TENANT_ID=your-tenant-id
   ```

3. **Update Server Configuration** in `src/lib/auth.ts`:

   **Google**:
   ```typescript
   socialProviders: {
     google: {
       clientId: process.env.GOOGLE_CLIENT_ID!,
       clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
       scopes: ['email', 'profile'],
       // Optional: Force account selection
       prompt: 'select_account',
     },
   }
   ```

   **GitHub**:
   ```typescript
   socialProviders: {
     github: {
       clientId: process.env.GITHUB_CLIENT_ID!,
       clientSecret: process.env.GITHUB_CLIENT_SECRET!,
       scopes: ['user:email', 'read:user'],
       // Optional: Request additional scopes
       // scopes: ['user:email', 'read:user', 'read:org'],
     },
   }
   ```

   **Discord**:
   ```typescript
   socialProviders: {
     discord: {
       clientId: process.env.DISCORD_CLIENT_ID!,
       clientSecret: process.env.DISCORD_CLIENT_SECRET!,
       scopes: ['identify', 'email'],
       // Optional: Guild-specific
       // scopes: ['identify', 'email', 'guilds'],
     },
   }
   ```

   **Apple**:
   ```typescript
   socialProviders: {
     apple: {
       clientId: process.env.APPLE_CLIENT_ID!,
       clientSecret: process.env.APPLE_CLIENT_SECRET!,
       teamId: process.env.APPLE_TEAM_ID!,
       keyId: process.env.APPLE_KEY_ID!,
     },
   }
   ```

   **Microsoft**:
   ```typescript
   socialProviders: {
     microsoft: {
       clientId: process.env.MICROSOFT_CLIENT_ID!,
       clientSecret: process.env.MICROSOFT_CLIENT_SECRET!,
       tenantId: process.env.MICROSOFT_TENANT_ID!, // or 'common' for multi-tenant
       scopes: ['openid', 'profile', 'email'],
     },
   }
   ```

4. **Update Auth Client** in `src/auth/client.ts`:
   ```typescript
   export const {
     // ... existing exports
     signInWithGoogle,
     signInWithGithub,
     signInWithDiscord,
     signInWithApple,
     signInWithMicrosoft,
   } = authClient
   ```

5. **Create/Update Social Login Buttons** in `src/features/auth/components/SocialLoginButtons.tsx`:
   ```typescript
   import {
     signInWithGoogle,
     signInWithGithub,
     signInWithDiscord,
   } from '@/auth/client'

   interface SocialLoginButtonsProps {
     callbackURL?: string
   }

   export function SocialLoginButtons({ callbackURL = '/dashboard' }: SocialLoginButtonsProps) {
     const handleGoogle = async () => {
       await signInWithGoogle({ callbackURL })
     }

     const handleGithub = async () => {
       await signInWithGithub({ callbackURL })
     }

     const handleDiscord = async () => {
       await signInWithDiscord({ callbackURL })
     }

     return (
       <div className="flex flex-col gap-3">
         <button
           onClick={handleGoogle}
           className="flex items-center justify-center gap-2 w-full p-3 border rounded-lg hover:bg-gray-50"
         >
           <svg className="w-5 h-5" viewBox="0 0 24 24">
             {/* Google icon SVG */}
           </svg>
           Continue with Google
         </button>

         <button
           onClick={handleGithub}
           className="flex items-center justify-center gap-2 w-full p-3 border rounded-lg hover:bg-gray-50"
         >
           <svg className="w-5 h-5" viewBox="0 0 24 24">
             {/* GitHub icon SVG */}
           </svg>
           Continue with GitHub
         </button>

         <button
           onClick={handleDiscord}
           className="flex items-center justify-center gap-2 w-full p-3 border rounded-lg hover:bg-gray-50"
         >
           <svg className="w-5 h-5" viewBox="0 0 24 24">
             {/* Discord icon SVG */}
           </svg>
           Continue with Discord
         </button>
       </div>
     )
   }
   ```

6. **Handle Provider Callback** (if custom handling needed):
   ```typescript
   // In your server/API routes
   export const auth = betterAuth({
     socialProviders: {
       google: {
         // ...config
         onUserCreated: async (user, account) => {
           // Custom logic when user signs up via Google
           await sendWelcomeEmail(user.email)
         },
         onSignIn: async (user, account) => {
           // Custom logic on each sign in
           await updateLastLogin(user.id)
         },
       },
     },
   })
   ```

## Common Scopes Reference

| Provider | Common Scopes |
|----------|--------------|
| Google | `email`, `profile`, `openid` |
| GitHub | `user:email`, `read:user`, `read:org` |
| Discord | `identify`, `email`, `guilds` |
| Apple | (automatic: email, name) |
| Microsoft | `openid`, `profile`, `email`, `User.Read` |
| Twitter | `users.read`, `tweet.read` |
| Facebook | `email`, `public_profile` |
| LinkedIn | `r_emailaddress`, `r_liteprofile` |

## Quality Checklist

- [ ] Provider credentials obtained from developer portal
- [ ] Environment variables added to `.env`
- [ ] Callback URL configured in provider dashboard
- [ ] Provider added to `socialProviders` config
- [ ] Client export added for `signInWith{Provider}`
- [ ] Button added to SocialLoginButtons component
- [ ] Scopes appropriate for app needs
- [ ] Tested sign-in flow works correctly
