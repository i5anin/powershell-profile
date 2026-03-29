// dump-git-changes.cjs
'use strict'

const fs = require('node:fs')
const { execSync } = require('node:child_process')

const CC_HELP = [
  '=== Соглашение о коммитах 1.0.0 ===',
  'Напиши комит на русском языке',
  'Заголовок максимально короткий 30-40 символов предел гит 50',
  'Формат:',
  '<тип>(<контекст>)!: <описание>',
  '',
  'Типы:',
  'feat | fix | refactor | perf | test | docs | chore | build | ci | revert',
  '',
  'Правила:',
  '- контекст опционально',
  '- ! только для BREAKING CHANGE',
  '- описание коротко, без точки',
  '- при необходимости в теле: BREAKING CHANGE: ...',
  '',
  'Примеры:',
  'fix(monitor): пустые триггеры',
  'feat(report): ёмкость диска'
].join('\n')

console.log(CC_HELP + '\n')

const argv = process.argv.slice(2)
const args = new Set(argv)

// --staged = показать только staged; без флага = показать working tree + staged + untracked
const STAGED = args.has('--staged')

const CONTEXT = (() => {
  const v = argv.find((a) => a.startsWith('--context='))
  const n = v ? Number(v.split('=')[1]) : 3
  return Number.isFinite(n) && n >= 0 ? n : 3
})()

const sh = (cmd) =>
    execSync(cmd, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe']
    }).trimEnd()

const run = (cmd) => {
  try {
    return sh(cmd)
  } catch (e) {
    return (
        (e.stdout || '').toString().trimEnd() ||
        (e.stderr || '').toString().trimEnd()
    )
  }
}

const untracked = () =>
    run('git -c core.quotepath=false ls-files --others --exclude-standard')
        .split('\n')
        .map((s) => s.trim())
        .filter(Boolean)

const fileAsAddedDiff = (p) => {
  const body = fs.readFileSync(p, 'utf8').replace(/\r\n/g, '\n').trimEnd()
  const lines = body ? body.split('\n') : ['']
  return [
    `diff --git a/${p} b/${p}`,
    'new file mode 100644',
    '--- /dev/null',
    `+++ b/${p}`,
    `@@ -0,0 +1,${lines.length} @@`,
    ...lines.map((l) => `+${l}`),
    ''
  ].join('\n')
}

const section = (title, nameStatusCmd, diffCmd, extraDiff = '') => {
  const nameStatus = run(nameStatusCmd)
  const diff = run(diffCmd)

  if (!nameStatus && !diff && !extraDiff) return false

  console.log(`\n=== ${title} (name-status) ===\n`)
  console.log('```')
  console.log(nameStatus || '(пусто)')
  console.log('```')

  console.log(`\n=== ${title} (diff, -U${CONTEXT}) ===\n`)
  console.log('```diff')
  console.log(diff || '(diff пуст)')
  if (extraDiff) console.log('\n' + extraDiff.trimEnd())
  console.log('```')

  return true
}

let any = false

if (!STAGED) {
  const ut = untracked()
  const utDiff = ut.length ? ut.map(fileAsAddedDiff).join('\n') : ''

  any =
      section(
          'git working tree',
          'git -c core.quotepath=false diff --name-status',
          `git -c core.quotepath=false diff -U${CONTEXT}`,
          utDiff
      ) || any
}

any =
    section(
        'git staged',
        'git -c core.quotepath=false diff --name-status --staged',
        `git -c core.quotepath=false diff --staged -U${CONTEXT}`
    ) || any

if (!any) console.log(STAGED ? 'Нет staged-изменений.' : 'Нет изменений.')
