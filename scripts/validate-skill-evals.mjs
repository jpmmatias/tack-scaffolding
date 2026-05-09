#!/usr/bin/env node
// Validate skills/*/evals/evals.json against skill-creator-style schema and SKILL.md name.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");

function readSkillName(skillDir) {
  const skillMd = path.join(skillDir, "SKILL.md");
  const raw = fs.readFileSync(skillMd, "utf8");
  const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) throw new Error(`${skillMd}: missing YAML frontmatter`);
  const nameLine = m[1].split(/\r?\n/).find((l) => /^name:\s*/.test(l));
  if (!nameLine) throw new Error(`${skillMd}: missing name in frontmatter`);
  const name = nameLine.replace(/^name:\s*/, "").trim();
  if (!name) throw new Error(`${skillMd}: empty name in frontmatter`);
  return name;
}

function validateEvalsJson(skillDir, data) {
  const expectedName = readSkillName(skillDir);
  if (data.skill_name !== expectedName) {
    throw new Error(
      `${skillDir}: evals.json skill_name "${data.skill_name}" !== SKILL.md name "${expectedName}"`,
    );
  }
  if (!Array.isArray(data.evals) || data.evals.length === 0) {
    throw new Error(`${skillDir}: evals must be a non-empty array`);
  }
  const ids = new Set();
  for (const ev of data.evals) {
    if (typeof ev.id !== "number" || !Number.isInteger(ev.id)) {
      throw new Error(`${skillDir}: eval id must be an integer`);
    }
    if (ids.has(ev.id)) throw new Error(`${skillDir}: duplicate eval id ${ev.id}`);
    ids.add(ev.id);
    for (const key of ["prompt", "expected_output", "expectations"]) {
      if (!(key in ev)) throw new Error(`${skillDir}: eval ${ev.id} missing "${key}"`);
    }
    if (typeof ev.prompt !== "string" || !ev.prompt.trim()) {
      throw new Error(`${skillDir}: eval ${ev.id} prompt must be non-empty string`);
    }
    if (typeof ev.expected_output !== "string" || !ev.expected_output.trim()) {
      throw new Error(`${skillDir}: eval ${ev.id} expected_output must be non-empty string`);
    }
    if (!Array.isArray(ev.expectations) || ev.expectations.length === 0) {
      throw new Error(`${skillDir}: eval ${ev.id} expectations must be a non-empty array of strings`);
    }
    for (const ex of ev.expectations) {
      if (typeof ex !== "string" || !ex.trim()) {
        throw new Error(`${skillDir}: eval ${ev.id} each expectation must be a non-empty string`);
      }
    }
    if (ev.files !== undefined) {
      if (!Array.isArray(ev.files)) throw new Error(`${skillDir}: eval ${ev.id} files must be an array`);
      for (const f of ev.files) {
        if (typeof f !== "string") throw new Error(`${skillDir}: eval ${ev.id} files entries must be strings`);
      }
    }
  }
}

const skillDirs = fs
  .readdirSync(path.join(ROOT, "skills"), { withFileTypes: true })
  .filter((d) => d.isDirectory())
  .map((d) => path.join(ROOT, "skills", d.name))
  .filter((dir) => fs.existsSync(path.join(dir, "SKILL.md")));

let ok = 0;
for (const skillDir of skillDirs) {
  const evalPath = path.join(skillDir, "evals", "evals.json");
  if (!fs.existsSync(evalPath)) {
    console.error(`validate-skill-evals: missing ${evalPath}`);
    process.exitCode = 1;
    continue;
  }
  let data;
  try {
    data = JSON.parse(fs.readFileSync(evalPath, "utf8"));
  } catch (e) {
    console.error(`validate-skill-evals: invalid JSON ${evalPath}:`, e.message);
    process.exitCode = 1;
    continue;
  }
  try {
    validateEvalsJson(skillDir, data);
  } catch (e) {
    console.error(`validate-skill-evals:`, e.message);
    process.exitCode = 1;
    continue;
  }
  console.log(`validate-skill-evals: OK ${evalPath}`);
  ok++;
}

if (process.exitCode === 1) process.exit(1);
if (ok === 0) {
  console.error("validate-skill-evals: no skills with evals found");
  process.exit(1);
}
