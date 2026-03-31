#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath, pathToFileURL } from "node:url";

function parseArgs(argv) {
  const args = { profile: "default", tokenFile: "" };
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--profile" || a === "-p") {
      args.profile = argv[i + 1] || "default";
      i += 1;
      continue;
    }
    if (a === "--token-file") {
      args.tokenFile = argv[i + 1] || "";
      i += 1;
      continue;
    }
  }
  return args;
}

function resolveTokenFile(profile, tokenFileArg) {
  if (tokenFileArg) return tokenFileArg;
  const __filename = fileURLToPath(import.meta.url);
  const scriptsDir = path.dirname(__filename);
  const rootDir = path.resolve(scriptsDir, "..");
  if (profile === "default") return path.join(rootDir, "xero-tokens.json");
  return path.join(rootDir, `xero-tokens.${profile}.json`);
}

async function main() {
  const __filename = fileURLToPath(import.meta.url);
  const scriptsDir = path.dirname(__filename);
  const rootDir = path.resolve(scriptsDir, "..");
  const { profile, tokenFile } = parseArgs(process.argv.slice(2));
  const resolvedTokenFile = resolveTokenFile(profile, tokenFile);

  if (!fs.existsSync(resolvedTokenFile)) {
    throw new Error(`Token file not found: ${resolvedTokenFile}`);
  }

  const raw = fs.readFileSync(resolvedTokenFile, "utf8");
  const data = JSON.parse(raw.replace(/^\uFEFF/, ""));
  const accessToken = String(data.access_token || "").trim();

  if (!accessToken) {
    throw new Error(`access_token missing in ${resolvedTokenFile}`);
  }

  process.env.XERO_CLIENT_BEARER_TOKEN = accessToken;

  const entry = path.join(
    rootDir,
    "node_modules",
    "@xeroapi",
    "xero-mcp-server",
    "dist",
    "index.js"
  );

  if (!fs.existsSync(entry)) {
    throw new Error("xero-mcp-server not installed. Run npm install first.");
  }

  await import(pathToFileURL(entry).href);
}

main().catch((err) => {
  const msg = err instanceof Error ? err.message : String(err);
  console.error(msg);
  process.exit(1);
});
