import type { EnsureRepoOptions } from './registry.js'

let _opts: EnsureRepoOptions = {}

export function setGlobalRegistryOptions(opts: EnsureRepoOptions): void {
  _opts = opts
}

export function getRegistryOptions(): EnsureRepoOptions {
  return _opts
}
