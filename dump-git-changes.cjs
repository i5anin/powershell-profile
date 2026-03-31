// dump-git-changes.cjs
'use strict'

const fs = require('node:fs')
const { execSync } = require('node:child_process')

const CC_HELP = [
  '=== Conventional Commits 1.0.0 ===',
  'Напиши коммит на русском языке',
  'Заголовок короткий: 30-40 символов, предел Git — 50',
  'Формат:',
  '<тип>(<контекст>)!: <описание>',
  '',
  'Типы:',
  'feat | fix | refactor | perf | test | docs | chore | build | ci | revert',
  '',
  'Правила:',
  '- контекст опционально',
  '- ! только для BREAKING CHANGE',
  '- описание короткое, без точки',
  '- при необходимости в теле: BREAKING CHANGE: ...',
  '',
  'Примеры:',
  'fix(monitor): пустые триггеры',
  'feat(report): ёмкость диска'
].join('\n')

const ANSI_RED = '\x1b[31m'
const ANSI_GREEN = '\x1b[32m'
const ANSI_YELLOW = '\x1b[33m'
const ANSI_CYAN = '\x1b[36m'
const ANSI_RESET = '\x1b[0m'

console.log(CC_HELP + '\n')

const argv = process.argv.slice(2)
const args = new Set(argv)

const STAGED = args.has('--staged')

const CONTEXT = (() => {
  const value = argv.find((arg) => arg.startsWith('--context='))
  const parsed = value ? Number(value.split('=')[1]) : 3
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : 3
})()

const FONT_EXTENSIONS = new Set([
  '.ttf',
  '.otf',
  '.woff',
  '.woff2',
  '.eot',
  '.fon',
  '.fnt',
  '.ttc',
  '.otc'
])

const sh = (cmd) =>
    execSync(cmd, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe']
    }).trimEnd()

const run = (cmd) => {
  try {
    return sh(cmd)
  }
  catch (error) {
    return (
        (error.stdout || '').toString().trimEnd() ||
        (error.stderr || '').toString().trimEnd()
    )
  }
}

const normalizePath = (filePath) =>
    filePath.replace(/\\/g, '/').trim()

const getExt = (filePath) => {
  const normalizedPath = normalizePath(filePath)
  const dotIndex = normalizedPath.lastIndexOf('.')

  if (dotIndex === -1) {
    return ''
  }

  return normalizedPath.slice(dotIndex).toLowerCase()
}

const isFontFile = (filePath) =>
    FONT_EXTENSIONS.has(getExt(filePath))

const parseNameStatus = (text) =>
    text
        .split('\n')
        .map((line) => line.trim())
        .filter(Boolean)
        .map((line) => {
          const parts = line.split('\t').filter(Boolean)

          return {
            status: parts[0] || '',
            filePath: normalizePath(parts[parts.length - 1] || '')
          }
        })

const getStatusColor = (status) => {
  if (status.startsWith('A') || status === '??') {
    return ANSI_GREEN
  }

  if (status.startsWith('D')) {
    return ANSI_RED
  }

  if (status.startsWith('M') || status.startsWith('R') || status.startsWith('C')) {
    return ANSI_YELLOW
  }

  return ''
}

const getStatusLabel = (status) => {
  if (status.startsWith('A') || status === '??') {
    return 'новый файл'
  }

  if (status.startsWith('D')) {
    return 'удалён'
  }

  if (status.startsWith('M')) {
    return 'изменён'
  }

  if (status.startsWith('R')) {
    return 'переименован'
  }

  if (status.startsWith('C')) {
    return 'скопирован'
  }

  return 'изменён'
}

const colorizeNameStatus = (text) =>
    parseNameStatus(text)
        .map(({ status, filePath }) => {
          if (!status || !filePath) {
            return ''
          }

          const color = getStatusColor(status)

          if (!color) {
            return `${status}\t${filePath}`
          }

          return `${color}${status}\t${filePath}${ANSI_RESET}`
        })
        .filter(Boolean)
        .join('\n')

const untracked = () =>
    run('git -c core.quotepath=false ls-files --others --exclude-standard')
        .split('\n')
        .map(normalizePath)
        .filter(Boolean)

const fileAsAddedDiff = (filePath) => {
  if (isFontFile(filePath)) {
    return ''
  }

  const body = fs.readFileSync(filePath, 'utf8').replace(/\r\n/g, '\n').trimEnd()
  const lines = body ? body.split('\n') : ['']

  return [
    `${ANSI_GREEN}==== ${filePath} [новый файл] ====${ANSI_RESET}`,
    `diff --git a/${filePath} b/${filePath}`,
    `${ANSI_GREEN}new file mode 100644${ANSI_RESET}`,
    '--- /dev/null',
    `${ANSI_GREEN}+++ b/${filePath}${ANSI_RESET}`,
    `@@ -0,0 +1,${lines.length} @@`,
    ...lines.map((line) => `${ANSI_GREEN}+${line}${ANSI_RESET}`),
    ''
  ].join('\n')
}

const splitDiffBlocks = (diffText) => {
  const normalized = diffText.replace(/\r\n/g, '\n').trim()

  if (!normalized) {
    return []
  }

  return normalized
      .split(/^diff --git /m)
      .filter(Boolean)
      .map((block) => `diff --git ${block}`.trim())
}

const getDiffPath = (block) => {
  const firstLine = block.split('\n')[0] || ''
  const match = firstLine.match(/^diff --git a\/(.+?) b\/(.+)$/)

  if (!match) {
    return ''
  }

  return normalizePath(match[2])
}

const isNewFileDiff = (block) =>
    block.includes('\nnew file mode ')

const isDeletedFileDiff = (block) =>
    block.includes('\ndeleted file mode ')

const getDiffBlockType = (block) => {
  if (isNewFileDiff(block)) {
    return 'A'
  }

  if (isDeletedFileDiff(block)) {
    return 'D'
  }

  return 'M'
}

const removeFontDiff = (diffText) => {
  const blocks = splitDiffBlocks(diffText)

  return blocks
      .filter((block) => {
        const filePath = getDiffPath(block)
        return filePath && !isFontFile(filePath)
      })
      .join('\n\n')
      .trim()
}

const colorizeDiffLine = (line) => {
  if (!line) {
    return line
  }

  if (line.startsWith('+++ ')) {
    return `${ANSI_GREEN}${line}${ANSI_RESET}`
  }

  if (line.startsWith('--- ')) {
    return `${ANSI_RED}${line}${ANSI_RESET}`
  }

  if (line.startsWith('+') && !line.startsWith('+++')) {
    return `${ANSI_GREEN}${line}${ANSI_RESET}`
  }

  if (line.startsWith('-') && !line.startsWith('---')) {
    return `${ANSI_RED}${line}${ANSI_RESET}`
  }

  if (line.startsWith('@@')) {
    return `${ANSI_CYAN}${line}${ANSI_RESET}`
  }

  if (line.startsWith('new file mode')) {
    return `${ANSI_GREEN}${line}${ANSI_RESET}`
  }

  if (line.startsWith('deleted file mode')) {
    return `${ANSI_RED}${line}${ANSI_RESET}`
  }

  if (line.startsWith('index ')) {
    return `${ANSI_YELLOW}${line}${ANSI_RESET}`
  }

  if (line.startsWith('diff --git ')) {
    return `${ANSI_CYAN}${line}${ANSI_RESET}`
  }

  return line
}

const colorizeDiffBlock = (block) =>
    block
        .split('\n')
        .map(colorizeDiffLine)
        .join('\n')

const addFileHeadersToDiff = (diffText) => {
  const blocks = splitDiffBlocks(diffText)

  if (!blocks.length) {
    return ''
  }

  return blocks
      .map((block) => {
        const filePath = getDiffPath(block)

        if (!filePath) {
          return colorizeDiffBlock(block)
        }

        const blockType = getDiffBlockType(block)
        const headerColor = getStatusColor(blockType)
        const headerLabel = getStatusLabel(blockType)

        return [
          `${headerColor}==== ${filePath} [${headerLabel}] ====${ANSI_RESET}`,
          colorizeDiffBlock(block)
        ].join('\n')
      })
      .join('\n\n')
      .trim()
}

const printSection = (title, nameStatusCmd, diffCmd, extraDiff = '') => {
  const nameStatus = run(nameStatusCmd)
  const rawDiff = run(diffCmd)
  const cleanDiff = removeFontDiff(rawDiff)

  const diff = [cleanDiff, extraDiff]
      .filter(Boolean)
      .join('\n\n')
      .trim()

  if (!nameStatus && !diff) {
    return false
  }

  console.log(`\n=== ${title}: файлы ===\n`)
  console.log('```')
  console.log(colorizeNameStatus(nameStatus) || '(пусто)')
  console.log('```')

  console.log(`\n=== ${title}: diff (-U${CONTEXT}) ===\n`)
  console.log('```diff')
  console.log(addFileHeadersToDiff(diff) || '(diff пуст)')
  console.log('```')

  return true
}

let hasChanges = false

if (!STAGED) {
  const untrackedFiles = untracked()
  const untrackedDiff = untrackedFiles
      .map(fileAsAddedDiff)
      .filter(Boolean)
      .join('\n\n')

  hasChanges =
      printSection(
          'Working tree',
          'git -c core.quotepath=false diff --name-status',
          `git -c core.quotepath=false diff -U${CONTEXT}`,
          untrackedDiff
      ) || hasChanges
}

hasChanges =
    printSection(
        'Staged',
        'git -c core.quotepath=false diff --name-status --staged',
        `git -c core.quotepath=false diff --staged -U${CONTEXT}`
    ) || hasChanges

if (!hasChanges) {
  console.log(STAGED ? 'Нет staged-изменений.' : 'Нет изменений.')
}