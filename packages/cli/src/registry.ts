import fs from 'node:fs'
import path from 'node:path'
import os from 'node:os'
import { execSync } from 'node:child_process'

const REPO = 'smicolon/ai-kit'
const DEFAULT_BRANCH = 'main'

function getCacheDir(): string {
  return path.join(os.homedir(), '.config', 'ai-kit', 'cache')
}

function getRepoDir(): string {
  return path.join(getCacheDir(), 'repo')
}

function getCachedMarketplacePath(): string {
  return path.join(getCacheDir(), 'marketplace.json')
}

function rawUrl(branch: string, filePath: string): string {
  return `https://raw.githubusercontent.com/${REPO}/${branch}/${filePath}`
}

function tarballUrl(branch: string): string {
  return `https://github.com/${REPO}/archive/refs/heads/${branch}.tar.gz`
}

async function fetchMarketplaceRaw(branch: string): Promise<string> {
  const url = rawUrl(branch, '.claude-plugin/marketplace.json')
  const res = await fetch(url)
  if (!res.ok) {
    throw new Error(`Failed to fetch marketplace.json: ${res.status} ${res.statusText}`)
  }
  return res.text()
}

async function downloadRepo(branch: string): Promise<void> {
  const cacheDir = getCacheDir()
  const repoDir = getRepoDir()
  const tarPath = path.join(cacheDir, 'repo.tar.gz')

  // Clean previous repo
  if (fs.existsSync(repoDir)) {
    fs.rmSync(repoDir, { recursive: true })
  }
  fs.mkdirSync(repoDir, { recursive: true })

  // Download tarball
  const url = tarballUrl(branch)
  const res = await fetch(url)
  if (!res.ok) {
    throw new Error(`Failed to download repo tarball: ${res.status} ${res.statusText}`)
  }

  const buffer = Buffer.from(await res.arrayBuffer())
  fs.writeFileSync(tarPath, buffer)

  // Extract — strip top-level directory (ai-kit-main/)
  execSync(`tar xzf "${tarPath}" --strip-components=1 -C "${repoDir}"`, {
    stdio: 'ignore',
  })

  // Cleanup tarball
  fs.unlinkSync(tarPath)
}

export interface EnsureRepoOptions {
  noCache?: boolean
  branch?: string
}

export async function ensureRepo(options: EnsureRepoOptions = {}): Promise<string> {
  const branch = options.branch ?? DEFAULT_BRANCH
  const cacheDir = getCacheDir()
  const repoDir = getRepoDir()
  const cachedMpPath = getCachedMarketplacePath()

  fs.mkdirSync(cacheDir, { recursive: true })

  // If --no-cache, always re-download
  if (options.noCache) {
    const mpContent = await fetchMarketplaceRaw(branch)
    await downloadRepo(branch)
    fs.writeFileSync(cachedMpPath, mpContent)
    return repoDir
  }

  // Freshness check: fetch remote marketplace.json and compare
  try {
    const remoteMp = await fetchMarketplaceRaw(branch)

    let needsDownload = true
    if (fs.existsSync(cachedMpPath) && fs.existsSync(repoDir)) {
      const cachedMp = fs.readFileSync(cachedMpPath, 'utf-8')
      needsDownload = remoteMp !== cachedMp
    }

    if (needsDownload) {
      await downloadRepo(branch)
      fs.writeFileSync(cachedMpPath, remoteMp)
    }

    return repoDir
  } catch (err) {
    // Offline / GitHub down: use stale cache if available
    if (fs.existsSync(repoDir) && fs.existsSync(path.join(repoDir, '.claude-plugin', 'marketplace.json'))) {
      const msg = err instanceof Error ? err.message : String(err)
      console.error(`Warning: Could not reach GitHub (${msg}). Using cached packs.`)
      return repoDir
    }

    throw new Error(
      'Could not fetch packs from GitHub and no local cache exists. ' +
      'Check your internet connection and try again.',
    )
  }
}

export function clearCache(): void {
  const cacheDir = getCacheDir()
  if (fs.existsSync(cacheDir)) {
    fs.rmSync(cacheDir, { recursive: true })
  }
}
