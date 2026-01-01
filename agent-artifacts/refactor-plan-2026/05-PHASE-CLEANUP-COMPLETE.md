# Phase 5: Cleanup and Completion

**Goal**: Complete missing plugins, update documentation, remove redundancy

---

## Tasks

### 5.1 Complete smi-nuxtjs Plugin

Currently smi-nuxtjs has:
- 3 agents (nuxtjs-architect, frontend-visual, frontend-tester)
- 0 commands
- 0 skills

Need to add:

#### 5.1.1 Skills for Nuxt.js

**File**: `plugins/smi-nuxtjs/skills/accessibility-validator/SKILL.md`

```markdown
---
name: accessibility-validator
description: Automatically validate Vue 3/Nuxt.js components meet WCAG 2.1 AA standards. Activates when creating components, forms, or interactive UI elements.
---

# Vue Accessibility Validator

## When This Skill Activates

- Creating Vue components
- Writing template sections
- Adding interactive elements
- User mentions "component", "form", "button"

## Checks

### Semantic HTML

```vue
<!-- ❌ WRONG -->
<div @click="handleAction">Click me</div>

<!-- ✅ CORRECT -->
<button type="button" @click="handleAction">
  Click me
</button>
```

### Form Labels

```vue
<!-- ❌ WRONG -->
<input v-model="email" placeholder="Email" />

<!-- ✅ CORRECT -->
<label for="email">Email</label>
<input id="email" v-model="email" aria-describedby="email-hint" />
<span id="email-hint">Your work email address</span>
```

### Keyboard Navigation

```vue
<!-- ❌ WRONG - Only mouse -->
<div @click="toggle" class="dropdown">

<!-- ✅ CORRECT - Keyboard accessible -->
<button
  type="button"
  @click="toggle"
  @keydown.enter="toggle"
  @keydown.space="toggle"
  aria-expanded="isOpen"
  aria-haspopup="listbox"
>
```

## Auto-Fix Actions

1. Convert div with @click to button
2. Add missing labels
3. Add keyboard handlers
4. Add ARIA attributes
```

**File**: `plugins/smi-nuxtjs/skills/veevalidate-form-validator/SKILL.md`

```markdown
---
name: veevalidate-form-validator
description: Auto-enforce VeeValidate + Zod pattern for all forms. Activates when creating forms or handling user input.
---

# VeeValidate + Zod Form Validator

## When This Skill Activates

- Creating form components
- User mentions "form", "validation", "input"
- Writing <form> or v-model

## Required Pattern

```vue
<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

const schema = toTypedSchema(
  z.object({
    email: z.string().email('Invalid email'),
    password: z.string().min(8, 'Password too short'),
  })
)

const { handleSubmit, errors, defineField } = useForm({
  validationSchema: schema,
})

const [email, emailAttrs] = defineField('email')
const [password, passwordAttrs] = defineField('password')

const onSubmit = handleSubmit((values) => {
  // Type-safe values
  console.log(values.email, values.password)
})
</script>

<template>
  <form @submit="onSubmit">
    <div>
      <input v-model="email" v-bind="emailAttrs" type="email" />
      <span v-if="errors.email" class="error">{{ errors.email }}</span>
    </div>
    <div>
      <input v-model="password" v-bind="passwordAttrs" type="password" />
      <span v-if="errors.password" class="error">{{ errors.password }}</span>
    </div>
    <button type="submit">Submit</button>
  </form>
</template>
```

## Forbidden Patterns

```vue
<!-- ❌ No validation -->
<input v-model="email" />
<button @click="submit">Submit</button>

<!-- ❌ Manual validation -->
<input v-model="email" @blur="validateEmail" />
```
```

**File**: `plugins/smi-nuxtjs/skills/import-convention-enforcer/SKILL.md`

```markdown
---
name: import-convention-enforcer
description: Auto-enforce consistent import patterns for Nuxt.js. Activates when writing imports.
---

# Nuxt.js Import Convention Enforcer

## Import Order

1. Vue/Nuxt built-ins
2. Third-party packages
3. Composables (auto-imported)
4. Components (auto-imported)
5. Types

## Pattern

```vue
<script setup lang="ts">
// 1. Vue
import { ref, computed, watch } from 'vue'

// 2. Third-party
import { z } from 'zod'
import dayjs from 'dayjs'

// 3. Composables (usually auto-imported, explicit if needed)
import { useAuth } from '~/composables/useAuth'

// 4. Types
import type { User } from '~/types/user'

// Implementation
const user = ref<User | null>(null)
</script>
```

## Path Aliases

```typescript
// ✅ CORRECT
import { useAuth } from '~/composables/useAuth'
import type { User } from '~/types/user'

// ❌ WRONG
import { useAuth } from '../../../composables/useAuth'
import { useAuth } from '@/composables/useAuth'  // Use ~/ for Nuxt
```

## Auto-Import Awareness

Nuxt auto-imports:
- All composables from ~/composables
- All components from ~/components
- Vue Composition API (ref, computed, etc.)

Don't import what's auto-imported:
```vue
<!-- ❌ Unnecessary -->
<script setup>
import { ref } from 'vue'
import MyComponent from '~/components/MyComponent.vue'
</script>

<!-- ✅ Use auto-imports -->
<script setup>
// ref is auto-imported
const count = ref(0)
</script>
<template>
  <!-- MyComponent is auto-imported -->
  <MyComponent />
</template>
```
```

#### 5.1.2 Commands for Nuxt.js

**File**: `plugins/smi-nuxtjs/commands/component-create.md`

```markdown
---
name: component-create
description: Create a Nuxt.js/Vue 3 component following Smicolon conventions
---

# Nuxt.js Component Creation

## Component Types

1. **Page Component** - `/pages/*.vue`
2. **Layout Component** - `/layouts/*.vue`
3. **UI Component** - `/components/*.vue`
4. **Composable** - `/composables/*.ts`

## Template

```vue
<script setup lang="ts">
// Props with TypeScript
interface Props {
  title: string
  variant?: 'primary' | 'secondary'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
})

// Emits with TypeScript
const emit = defineEmits<{
  (e: 'update', value: string): void
  (e: 'close'): void
}>()

// Reactive state
const isOpen = ref(false)

// Computed
const buttonClass = computed(() => `btn-${props.variant}`)
</script>

<template>
  <div class="component">
    <h2>{{ title }}</h2>
    <button
      type="button"
      :class="buttonClass"
      @click="emit('close')"
    >
      Close
    </button>
  </div>
</template>

<style scoped>
.component {
  /* Scoped styles */
}
</style>
```

## Accessibility Checklist

- [ ] Semantic HTML elements
- [ ] Keyboard navigation
- [ ] ARIA attributes where needed
- [ ] Focus management
- [ ] Color contrast (4.5:1 minimum)
```

### 5.2 Update Documentation

#### 5.2.1 Fix README.md Accuracy

Update README.md to reflect actual state:

```markdown
## 5 Available Plugins

### 🐍 smi-django
- 5 agents, 3 commands, 6 skills, 6 rules, hooks

### 🦅 smi-nestjs
- 3 agents, 1 command, 2 skills, 4 rules, hooks

### ⚛️ smi-nextjs
- 4 agents, 1 command, 3 skills, 3 rules, hooks

### 💚 smi-nuxtjs
- 3 agents, 1 command, 3 skills, 3 rules, hooks  ← UPDATED

### 🏗️ smi-architect
- 1 agent, 1 command
```

#### 5.2.2 Update CLAUDE.md

Remove references to non-existent hook shell scripts.
Add references to new hooks.json format.

#### 5.2.3 Update SKILLS.md

Add new skills:
- test-validity-checker
- red-phase-verifier
- veevalidate-form-validator (Nuxt)
- composable-validator (Nuxt)

### 5.3 Remove Redundancy

#### 5.3.1 Deduplicate Shared Agents

`frontend-visual.md` and `frontend-tester.md` are identical in smi-nextjs and smi-nuxtjs.

Options:
1. **Keep duplicates** - Simpler, no shared dependency
2. **Create shared plugin** - More complex, DRY

Recommendation: Keep duplicates for simplicity. Each plugin should be self-contained.

### 5.4 Update marketplace.json

**File**: `.claude-plugin/marketplace.json`

```json
{
  "name": "smicolon-marketplace",
  "version": "2.0.0",  // Major version bump
  "description": "Official marketplace for Smicolon development standards - 5 plugins with 14 agents, 15 skills, path-specific rules, and TDD automation",
  "plugins": [
    {
      "name": "smi-django",
      "version": "2.0.0",
      "description": "Django standards with 5 agents, 6 skills, 6 path rules, and TDD automation",
      "source": "./plugins/smi-django",
      "agents": [...],
      "commands": [...],
      "skills": [...],
      "hooks": ["./hooks/hooks.json"],
      "rules": [
        "./rules/models.md",
        "./rules/views.md",
        "./rules/services.md",
        "./rules/serializers.md",
        "./rules/tests.md",
        "./rules/migrations.md"
      ]
    },
    // ... other plugins with similar updates
  ]
}
```

### 5.5 Update Agent Frontmatter

Add skill loading to all agents:

```yaml
---
name: django-builder
description: Expert Django developer
model: inherit
skills:
  - import-convention-enforcer
  - model-entity-validator
  - security-first-validator
  - performance-optimizer
allowedTools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---
```

### 5.6 Create Test Suite

Create tests for verifying plugin functionality:

**File**: `tests/test-plugin-structure.sh`

```bash
#!/bin/bash
# Test plugin structure validity

echo "Testing Smicolon Marketplace Plugins"
echo "====================================="

ERRORS=0

# Test each plugin
for plugin in plugins/smi-*/; do
  name=$(basename "$plugin")
  echo "Testing $name..."

  # Check required directories
  if [ ! -d "$plugin/agents" ]; then
    echo "  ❌ Missing agents directory"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ agents directory exists"
  fi

  # Check for README
  if [ ! -f "$plugin/README.md" ]; then
    echo "  ❌ Missing README.md"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ README.md exists"
  fi

  # Check hooks.json if hooks dir exists
  if [ -d "$plugin/hooks" ]; then
    if [ ! -f "$plugin/hooks/hooks.json" ]; then
      echo "  ❌ hooks directory exists but no hooks.json"
      ERRORS=$((ERRORS + 1))
    else
      echo "  ✅ hooks.json exists"
    fi
  fi

  echo ""
done

# Validate marketplace.json
echo "Validating marketplace.json..."
if python3 -m json.tool .claude-plugin/marketplace.json > /dev/null 2>&1; then
  echo "  ✅ Valid JSON"
else
  echo "  ❌ Invalid JSON"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "====================================="
if [ $ERRORS -eq 0 ]; then
  echo "✅ All tests passed!"
else
  echo "❌ $ERRORS errors found"
  exit 1
fi
```

---

## Success Criteria

- [ ] smi-nuxtjs has 3 skills
- [ ] smi-nuxtjs has 1 command
- [ ] README.md matches reality
- [ ] CLAUDE.md matches reality
- [ ] SKILLS.md includes all skills
- [ ] marketplace.json version 2.0.0
- [ ] All agents have skill frontmatter
- [ ] Test script passes

---

## Files to Create/Update

### Create
1. `plugins/smi-nuxtjs/skills/accessibility-validator/SKILL.md`
2. `plugins/smi-nuxtjs/skills/veevalidate-form-validator/SKILL.md`
3. `plugins/smi-nuxtjs/skills/import-convention-enforcer/SKILL.md`
4. `plugins/smi-nuxtjs/commands/component-create.md`
5. `tests/test-plugin-structure.sh`

### Update
1. `README.md` - Accurate counts and features
2. `.claude/CLAUDE.md` - Remove old hook references
3. `SKILLS.md` - Add new skills
4. `.claude-plugin/marketplace.json` - Version 2.0.0, add hooks/rules
5. All `agents/*.md` - Add skills frontmatter
6. All `plugins/*/README.md` - Update to match
