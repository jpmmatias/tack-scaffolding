#!/usr/bin/env node
// bin/tack.mjs — optional CLI for consumers (doctor, template copy, specialist stub).

import { spawnSync } from 'node:child_process';
import {
  existsSync,
  mkdirSync,
  copyFileSync,
  cpSync,
  statSync,
} from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

function packageRoot() {
  return resolve(__dirname, '..');
}

/**
 * @returns {string}
 */
function resolveTemplateDir() {
  const root = packageRoot();
  const dev = join(root, 'skills/tack-bootstrap/template');
  if (existsSync(dev)) {
    return dev;
  }
  const packed = join(root, 'pkg/template');
  if (existsSync(packed)) {
    return packed;
  }
  console.error(
    'tack: cannot find bootstrap template (expected skills/tack-bootstrap/template in this repo, or pkg/template after npm pack).'
  );
  process.exit(2);
}

function usage() {
  console.log(`Usage:
  tack doctor [-- ARGS...]     Run project/scripts/tack-doctor.sh (pass-through args).
  tack init [--target DIR] [--force]
                               Copy bootstrap template into DIR/project (default DIR: cwd).
  tack specialist add <slug>   Copy specialist prompt template to project/prompts/<slug>.md.

Global:
  -h, --help                   Show this help.

Full bootstrap (interview, routing, skill mirrors) stays in the tack-bootstrap skill — see README.md.
`);
}

function die(message, code = 2) {
  console.error(`tack: ${message}`);
  process.exit(code);
}

/**
 * @param {string[]} argv
 */
function parseInit(argv) {
  let target = process.cwd();
  let force = false;
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === '--force') {
      force = true;
      continue;
    }
    if (a === '--target' || a === '-t') {
      const v = argv[i + 1];
      if (!v) die('init: --target requires a directory');
      target = resolve(v);
      i += 1;
      continue;
    }
    if (a.startsWith('--target=')) {
      const v = a.slice('--target='.length);
      if (!v) die('init: --target= requires a path');
      target = resolve(v);
      continue;
    }
    if (a === '-h' || a === '--help') {
      console.log(`Usage: tack init [--target DIR] [--force]

Copy the bootstrap template tree into <target>/project (default target: current directory).
Refuses to overwrite an existing project/ unless --force.

After copying, run the tack-bootstrap skill for routing, mirrors, and filled docs — this command only materializes files.
`);
      process.exit(0);
    }
    die(`init: unknown argument: ${a}`);
  }
  return { target, force };
}

/**
 * @param {string} slug
 */
function validateSlug(slug) {
  if (!slug || typeof slug !== 'string') {
    die('specialist add: missing slug (use letters, digits, hyphen, underscore; start with a letter)');
  }
  if (!/^[a-z][a-z0-9_-]*$/u.test(slug)) {
    die(
      'specialist add: invalid slug — use lowercase letters, digits, hyphen, underscore (must start with a letter)'
    );
  }
}

function cmdDoctor(forward) {
  const cwd = process.cwd();
  const script = join(cwd, 'project/scripts/tack-doctor.sh');
  if (!existsSync(script)) {
    die(
      `missing ${script}\nRun from a bootstrapped repo root or copy tack-doctor.sh into project/scripts (see CONTRIBUTING.md).`,
      1
    );
  }
  const r = spawnSync('bash', [script, ...forward], {
    encoding: 'utf8',
    cwd,
    env: process.env,
  });
  if (r.stdout) process.stdout.write(r.stdout);
  if (r.stderr) process.stderr.write(r.stderr);
  const code = r.status ?? 1;
  process.exit(code);
}

function cmdInit(argv) {
  const { target, force } = parseInit(argv);
  const dest = join(target, 'project');
  if (existsSync(dest)) {
    const st = statSync(dest);
    if (!st.isDirectory()) {
      die(`init: ${dest} exists and is not a directory`);
    }
    if (!force) {
      die(
        `init: ${dest} already exists (remove it or run with --force to replace contents)`
      );
    }
  }
  const src = resolveTemplateDir();
  mkdirSync(dirname(dest), { recursive: true });
  cpSync(src, dest, { recursive: true, force: true });
  console.error(
    `tack: copied template to ${dest}\nNext: run the tack-bootstrap skill for AGENTS.md / CLAUDE.md / TACK.md routing and filled governance docs — init only lays down files.`,
  );
}

function cmdSpecialistAdd(slug) {
  validateSlug(slug);
  const cwd = process.cwd();
  const promptsDir = join(cwd, 'project/prompts');
  const outPath = join(promptsDir, `${slug}.md`);
  if (existsSync(outPath)) {
    die(`specialist add: ${outPath} already exists`);
  }
  const templ = join(resolveTemplateDir(), 'prompts/_specialist-template.md');
  if (!existsSync(templ)) {
    die(`missing specialist template at ${templ}`);
  }
  mkdirSync(promptsDir, { recursive: true });
  copyFileSync(templ, outPath);
  console.error(
    `tack: wrote ${outPath}\nNext: add Specialist routing rows to project/prompts/auto-orchestrator.md (and optional orchestrator.md) per the template instructions.`
  );
}

const argv = process.argv.slice(2);

if (argv.length === 0 || argv[0] === '-h' || argv[0] === '--help') {
  usage();
  process.exit(0);
}

const cmd = argv[0];
const rest = argv.slice(1);

if (cmd === 'doctor') {
  cmdDoctor(rest);
}

if (cmd === 'init') {
  cmdInit(rest);
  process.exit(0);
}

if (cmd === 'specialist' && rest[0] === 'add') {
  const slug = rest[1];
  const extra = rest.slice(2);
  if (extra.length > 0) {
    die(`specialist add: unexpected arguments after slug: ${extra.join(' ')}`);
  }
  if (!slug || slug.startsWith('-')) {
    die('specialist add: expected slug (e.g. tack specialist add api)');
  }
  cmdSpecialistAdd(slug);
  process.exit(0);
}

die(`unknown command: ${argv.join(' ')}\nRun tack --help.`);
