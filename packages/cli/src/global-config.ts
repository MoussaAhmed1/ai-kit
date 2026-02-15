import fs from 'node:fs'
import path from 'node:path'
import os from 'node:os'
import type { ToolId } from './types.js'

interface GlobalConfig {
  tools: ToolId[]
}

function getConfigDir(): string {
  return path.join(os.homedir(), '.config', 'ai-kit')
}

function getConfigPath(): string {
  return path.join(getConfigDir(), 'config.json')
}

export function readGlobalConfig(): GlobalConfig | null {
  const fp = getConfigPath()
  if (!fs.existsSync(fp)) return null
  try {
    return JSON.parse(fs.readFileSync(fp, 'utf-8')) as GlobalConfig
  } catch {
    return null
  }
}

export function writeGlobalConfig(config: GlobalConfig): void {
  const dir = getConfigDir()
  fs.mkdirSync(dir, { recursive: true })
  fs.writeFileSync(getConfigPath(), JSON.stringify(config, null, 2) + '\n')
}

export function getGlobalTools(): ToolId[] | null {
  const config = readGlobalConfig()
  return config?.tools ?? null
}

export function saveGlobalTools(tools: ToolId[]): void {
  const existing = readGlobalConfig()
  writeGlobalConfig({ ...existing, tools })
}
