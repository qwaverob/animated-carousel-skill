#!/usr/bin/env node

// Setup check for the animated-carousel skill. It only looks at this computer:
// Node, ffmpeg and ffprobe, the skill files, and HyperFrames with a Chrome to render with.
// It makes no network calls and reads no keys. Exit code 0 means everything needed is present.

import { existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const skillDir = path.resolve(scriptDir, "..");
const useColor = process.stdout.isTTY;
let hasFailure = false;

const color = {
  green: "\x1b[32m",
  red: "\x1b[31m",
  reset: "\x1b[0m",
};

function paint(value, tone) {
  return useColor ? `${color[tone]}${value}${color.reset}` : value;
}

function pass(label, detail = "") {
  console.log(`${paint("✓", "green")} ${label}${detail ? `: ${detail}` : ""}`);
}

function fail(label, fix) {
  hasFailure = true;
  console.log(`${paint("✗", "red")} ${label}`);
  console.log(`  Fix: ${fix}`);
}

function info(text) {
  console.log(`i ${text}`);
}

function commandWorks(command, args) {
  const result = spawnSync(command, args, { encoding: "utf8", timeout: 8000 });
  return result.status === 0;
}

function commandPath(command) {
  const result = spawnSync("/bin/sh", ["-c", 'command -v "$1"', "sh", command], {
    encoding: "utf8",
    timeout: 2000,
  });
  const found = (result.stdout || "").trim();
  return result.status === 0 && found ? found : null;
}

function checkNode() {
  const major = Number(process.versions.node.split(".")[0]);
  if (major >= 22) {
    pass("Node.js 22+", `v${process.versions.node}`);
  } else {
    fail("Node.js 22+", "Install Node.js 22 or newer, then run this check again.");
  }
}

function checkFfmpeg() {
  for (const command of ["ffmpeg", "ffprobe"]) {
    if (commandPath(command)) {
      pass(`${command} on PATH`);
    } else {
      fail(`${command} on PATH`, "Install ffmpeg. It includes both ffmpeg and ffprobe. On a Mac: brew install ffmpeg");
    }
  }
}

function checkSkillFiles() {
  const required = [
    "SKILL.md",
    "references/manychat.md",
    "references/buffer.md",
    "references/motion-menu.md",
    "templates/cover-slide",
    "templates/content-slide",
    "scripts/new-carousel.sh",
    "scripts/grade-stills.sh",
    "scripts/render-slides.sh",
    "scripts/qa.sh",
    "scripts/contact-sheet.sh",
  ];
  const missing = required.filter((item) => !existsSync(path.join(skillDir, item)));
  if (missing.length) {
    fail("Skill files", `Restore these files (download the repo again if unsure): ${missing.join(", ")}.`);
  } else {
    pass("Skill files", "SKILL.md, references, templates and scripts are present");
  }
}

function hyperframesBrowserPath(useNpx) {
  const [command, args] = useNpx
    ? ["npx", ["--no-install", "hyperframes", "browser", "path"]]
    : ["hyperframes", ["browser", "path"]];
  const result = spawnSync(command, args, { encoding: "utf8", timeout: 8000 });
  const found = (result.stdout || "").trim().split("\n").pop();
  return result.status === 0 && found && existsSync(found) ? found : null;
}

function checkRenderTools() {
  let viaNpx = false;
  if (commandWorks("hyperframes", ["--version"])) {
    pass("HyperFrames CLI", "global install");
  } else if (commandWorks("npx", ["--no-install", "hyperframes", "--version"])) {
    viaNpx = true;
    pass("HyperFrames CLI", "available through npx");
  } else {
    fail("HyperFrames CLI", "Install it with npm install -g hyperframes, then run hyperframes doctor.");
  }

  const browsers = [
    process.env.PUPPETEER_EXECUTABLE_PATH,
    process.env.CHROME_PATH,
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    commandPath("google-chrome"),
    commandPath("google-chrome-stable"),
    commandPath("chromium"),
    commandPath("chromium-browser"),
  ].filter(Boolean);
  const system = browsers.find((candidate) => existsSync(candidate));
  const managed = system ? null : hyperframesBrowserPath(viaNpx);

  if (system) {
    pass("Chrome or Chromium", path.basename(system));
  } else if (managed) {
    pass("Chrome or Chromium", "the one HyperFrames downloaded");
  } else {
    fail("Chrome or Chromium", "Install Google Chrome, or run hyperframes browser ensure, then hyperframes doctor.");
  }
}

console.log("Setup check: Node, ffmpeg, skill files, HyperFrames and Chrome.");
checkNode();
checkFfmpeg();
checkSkillFiles();
checkRenderTools();
info("ManyChat and Buffer are set up by hand, no keys needed.");

process.exitCode = hasFailure ? 1 : 0;
