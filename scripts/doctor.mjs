#!/usr/bin/env node

import { existsSync } from "node:fs";
import { access, readFile } from "node:fs/promises";
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
  yellow: "\x1b[33m",
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

function warn(label, detail) {
  console.log(`${paint("!", "yellow")} ${label}: ${detail}`);
}

function mask(value) {
  return value.length >= 4 ? `****${value.slice(-4)}` : "****";
}

function commandVersion(command, args) {
  const result = spawnSync(command, args, { encoding: "utf8", timeout: 8000 });
  return result.status === 0;
}

function commandPath(command) {
  const result = spawnSync("command", ["-v", command], {
    encoding: "utf8",
    shell: true,
    timeout: 2000,
  });
  const found = result.stdout.trim();
  return result.status === 0 && found ? found : null;
}

function normalBase(value, fallback) {
  return (value || fallback).replace(/\/$/, "");
}

async function jsonRequest(url, options) {
  try {
    const response = await fetch(url, { ...options, signal: AbortSignal.timeout(8000) });
    const contentType = response.headers.get("content-type") || "";
    const body = contentType.includes("application/json") ? await response.json() : null;
    return { response, body };
  } catch {
    return { response: null, body: null };
  }
}

async function checkNode() {
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
      fail(`${command} on PATH`, "Install ffmpeg. It includes both ffmpeg and ffprobe.");
    }
  }
}

async function checkRepoFiles() {
  const required = [
    "SKILL.md",
    "templates/cover-slide",
    "templates/content-slide",
    "scripts/new-carousel.sh",
    "scripts/grade-stills.sh",
    "scripts/render-slides.sh",
    "scripts/qa.sh",
    "scripts/contact-sheet.sh",
  ];
  const missing = required.filter((item) => !existsSync(path.join(skillDir, item)));
  const referencesDir = path.join(skillDir, "references");
  const scriptsDir = path.join(skillDir, "scripts");
  const references = existsSync(referencesDir) ? (await readFile(path.join(skillDir, "SKILL.md"), "utf8")).match(/references\//g) : [];
  const shellScripts = existsSync(scriptsDir) ? (await import("node:fs/promises")).readdir(scriptsDir) : [];

  if (!missing.length && references.length && (await shellScripts).some((name) => name.endsWith(".sh"))) {
    pass("Skill files", "SKILL.md, references, templates and scripts are present");
  } else {
    const parts = [...missing];
    if (!references.length) parts.push("references/*");
    if (!(await shellScripts).some((name) => name.endsWith(".sh"))) parts.push("scripts/*.sh");
    fail("Skill files", `Restore these required files: ${parts.join(", ")}.`);
  }
}

async function checkRenderTools() {
  let invocation = "";
  const commonPath = path.join(scriptDir, "_common.sh");
  if (existsSync(commonPath)) {
    const common = await readFile(commonPath, "utf8");
    invocation = common.includes("npx --yes hyperframes") ? "scripts use global HyperFrames, then npx" : "check scripts/_common.sh";
  }

  if (commandVersion("hyperframes", ["--version"])) {
    pass("HyperFrames CLI", `global install, ${invocation}`);
  } else if (commandVersion("npx", ["--no-install", "hyperframes", "--version"])) {
    pass("HyperFrames CLI", `available to npx without installing, ${invocation}`);
  } else {
    fail("HyperFrames CLI", "Install it with npm install -g hyperframes, then run hyperframes doctor.");
  }

  const browserPaths = [
    process.env.PUPPETEER_EXECUTABLE_PATH,
    process.env.CHROME_PATH,
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    commandPath("google-chrome"),
    commandPath("google-chrome-stable"),
    commandPath("chromium"),
    commandPath("chromium-browser"),
  ].filter(Boolean);
  const browser = browserPaths.find((candidate) => existsSync(candidate) || candidate.includes("/"));

  if (browser) {
    pass("Headless Chrome or Chromium", path.basename(browser));
  } else {
    fail("Headless Chrome or Chromium", "Install Google Chrome or Chromium, then run hyperframes doctor.");
  }
}

async function checkManyChat() {
  const key = process.env.MANYCHAT_API_KEY;
  if (!key) {
    fail("ManyChat API key", "Set MANYCHAT_API_KEY when you are ready to publish. It is optional until then.");
    return;
  }

  const base = normalBase(process.env.MANYCHAT_API_BASE, "https://api.manychat.com");
  const result = await jsonRequest(`${base}/fb/page/getInfo`, {
    headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
  });

  if (!result.response) {
    fail("ManyChat API", "Could not reach ManyChat. Check your connection and try again.");
  } else if (result.response.status === 401) {
    fail("ManyChat API", "ManyChat rejected the key. Create a valid API token and set MANYCHAT_API_KEY.");
  } else if (!result.response.ok || result.body?.status !== "success" || !result.body?.data?.name) {
    fail("ManyChat API", "ManyChat did not confirm this account. Check the API token and connected page.");
  } else {
    pass("ManyChat API", `${mask(key)} confirmed for ${result.body.data.name}`);
  }
}

async function bufferQuery(base, key, query, variables) {
  return jsonRequest(base, {
    method: "POST",
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
    body: JSON.stringify({ query, variables }),
  });
}

function isProfessional(channel) {
  const type = String(channel.type || "").toLowerCase();
  return type.includes("business") || type.includes("creator");
}

async function checkBuffer() {
  const keyName = process.env.BUFFER_API_KEY ? "BUFFER_API_KEY" : "BUFFER_ACCESS_TOKEN";
  const key = process.env.BUFFER_API_KEY || process.env.BUFFER_ACCESS_TOKEN;
  if (!key) {
    fail("Buffer API key", "Set BUFFER_API_KEY or BUFFER_ACCESS_TOKEN when you are ready to publish. It is optional until then.");
    warn("Instagram professional account", "Check manually in Instagram app > Settings > Account type and tools. Buffer and ManyChat both require a professional account.");
    return;
  }

  const base = normalBase(process.env.BUFFER_API_BASE, "https://api.buffer.com");
  const organizations = await bufferQuery(
    base,
    key,
    "query DoctorOrganizations { account { organizations { id name } } }",
  );

  if (!organizations.response) {
    fail("Buffer API", "Could not reach Buffer. Check your connection and try again.");
    return;
  }
  if (organizations.response.status === 401) {
    fail("Buffer API", "Buffer rejected the key. Create a valid API key and set it again.");
    return;
  }
  const orgs = organizations.body?.data?.account?.organizations;
  if (!organizations.response.ok || organizations.body?.errors?.length || !Array.isArray(orgs) || !orgs.length) {
    fail("Buffer API", "Buffer did not return an organization. Check the API key and Buffer account.");
    return;
  }

  const channelQuery = "query DoctorChannels($organizationId: OrganizationId!) { channels(input: { organizationId: $organizationId }) { name displayName service externalLink isDisconnected isLocked isQueuePaused timezone type } }";
  const allChannels = [];
  for (const organization of orgs) {
    const channels = await bufferQuery(base, key, channelQuery, { organizationId: organization.id });
    if (!channels.response || channels.response.status === 401 || !channels.response.ok || channels.body?.errors?.length || !Array.isArray(channels.body?.data?.channels)) {
      fail("Buffer channels", "Buffer could not list channels. Check the key and organization access.");
      return;
    }
    allChannels.push(...channels.body.data.channels);
  }

  if (!allChannels.length) {
    fail("Buffer channels", "Connect at least one social channel in Buffer, then run this check again.");
    warn("Instagram professional account", "Check manually in Instagram app > Settings > Account type and tools. Buffer and ManyChat both require a professional account.");
    return;
  }

  const listed = allChannels.map((channel) => `${channel.displayName || channel.name} (${channel.service})`).join(", ");
  pass("Buffer API", `${keyName} ${mask(key)} confirmed`);
  pass("Buffer channels", listed);

  const instagram = allChannels.filter((channel) => String(channel.service).toLowerCase() === "instagram");
  if (instagram.some(isProfessional)) {
    const kinds = instagram.filter(isProfessional).map((channel) => channel.type).join(", ");
    pass("Instagram professional account", `Buffer reports ${kinds}`);
  } else {
    warn("Instagram professional account", "Check manually in Instagram app > Settings > Account type and tools. Buffer and ManyChat both require a professional account.");
  }
}

console.log("Required checks: Node, media tools, skill files and render tools.");
console.log("Publish checks: ManyChat and Buffer keys are optional until publishing. Doctor exits nonzero while any check is incomplete.");

await checkNode();
checkFfmpeg();
await checkRepoFiles();
await checkRenderTools();
await checkManyChat();
await checkBuffer();

process.exitCode = hasFailure ? 1 : 0;
