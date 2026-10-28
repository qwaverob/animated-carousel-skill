// Tests for scripts/doctor.mjs. Run from the skill folder: node --test scripts/test/*.test.mjs
// The doctor must only check this computer (Node, ffmpeg, skill files, HyperFrames, Chrome),
// never read or mention ManyChat or Buffer keys, and never call the network.

import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const doctor = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "doctor.mjs");
const source = readFileSync(doctor, "utf8");

function run(env) {
  const result = spawnSync(process.execPath, [doctor], { encoding: "utf8", env, timeout: 60000 });
  return { code: result.status, out: result.stdout + result.stderr };
}

test("doctor makes no network calls", () => {
  for (const banned of ["fetch(", "node:http", "node:https", "manychat.com", "buffer.com"]) {
    assert.ok(!source.includes(banned), `doctor.mjs should not contain ${banned}`);
  }
});

test("doctor reads only the browser path variables from the environment", () => {
  const read = [...source.matchAll(/process\.env\.([A-Z_]+)/g)].map((m) => m[1]);
  const allowed = ["PUPPETEER_EXECUTABLE_PATH", "CHROME_PATH", "HOME"];
  assert.deepEqual(read.filter((name) => !allowed.includes(name)), []);
});

test("no red line is about ManyChat, Buffer or keys, and the info line is there", () => {
  const { out } = run(process.env);
  assert.ok(out.includes("ManyChat and Buffer are set up by hand, no keys needed."));
  const red = out.split("\n").filter((line) => line.startsWith("✗"));
  assert.ok(red.every((line) => !/manychat|buffer|key|token/i.test(line)), "no red line may be about ManyChat, Buffer or keys");
});

test("exit code is 0 exactly when there is no red line", () => {
  const { code, out } = run(process.env);
  const red = out.split("\n").some((line) => line.startsWith("✗"));
  assert.equal(code, red ? 1 : 0);
});

test("missing tools are red with a one-line fix and exit 1", () => {
  const { code, out } = run({ HOME: process.env.HOME, PATH: "/nonexistent" });
  assert.equal(code, 1);
  assert.match(out, /✗ ffmpeg on PATH\n {2}Fix: Install ffmpeg/);
  assert.match(out, /✗ HyperFrames CLI\n {2}Fix: /);
});
