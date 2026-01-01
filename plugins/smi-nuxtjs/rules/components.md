---
paths:
  - "**/components/**/*.vue"
  - "**/pages/**/*.vue"
  - "**/layouts/**/*.vue"
---

# Nuxt.js Component Standards

## Script Setup Pattern (MANDATORY)

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
    <button type="button" :class="buttonClass" @click="emit('close')">
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

## Accessibility (WCAG 2.1 AA)

```vue
<!-- WRONG -->
<div @click="handleAction">Click me</div>

<!-- CORRECT -->
<button type="button" @click="handleAction">
  Click me
</button>
```

## Auto-Imports

Nuxt auto-imports these - DON'T import explicitly:

```typescript
// Already auto-imported:
// ref, reactive, computed, watch, watchEffect
// useFetch, useAsyncData, useState, useCookie
// useHead, useSeoMeta, useRoute, useRouter
// navigateTo, definePageMeta

// WRONG - unnecessary import
import { ref, computed } from 'vue'

// CORRECT - just use directly
const count = ref(0)
const doubled = computed(() => count.value * 2)
```

## Path Aliases

```typescript
// CORRECT
import { useAuth } from '~/composables/useAuth'
import type { User } from '~/types/user'

// WRONG
import { useAuth } from '../../../composables/useAuth'
import { useAuth } from '@/composables/useAuth'  // Use ~/ for Nuxt
```

## Forbidden Patterns

- Options API (use Composition API with `<script setup>`)
- Explicit imports for auto-imported items
- `any` type
- Non-semantic interactive elements
