#!/usr/bin/env bun
/**
 * DailyWallpaper.ts — Generate a daily Hormozi quote wallpaper
 *
 * Renders a random quote from SecondBrain onto a 3840x2160 dark canvas
 * with gold accents and sets it as the Windows desktop wallpaper.
 *
 * Usage:
 *   bun DailyWallpaper.ts              # Generate + set (skips if already done today)
 *   bun DailyWallpaper.ts --force      # Regenerate even if already done today
 *   bun DailyWallpaper.ts --preview    # Generate PNG but don't set wallpaper
 *
 * Scheduled via Task Scheduler: daily at 6 AM + at logon.
 */

import { createCanvas, GlobalFonts } from '@napi-rs/canvas';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { spawnSync } from 'child_process';
import { loadAllQuotes, type Quote } from './DailyQuote';

// --- Config ---
const WIDTH = 3840;
const HEIGHT = 2160;
const BG_COLOR = '#0A0A0A';
const TEXT_COLOR = '#FFFFFF';
const GOLD = '#C5A572';
const ACCENT_STRIPE_WIDTH = 6;
const MARGIN_PCT = 0.15; // 15% margin on each side → 70% text column

const HOME = process.env.HOME || process.env.USERPROFILE || '';
const OUTPUT_DIR = join(HOME, 'Pictures', 'PAI');
const OUTPUT_PATH = join(OUTPUT_DIR, 'wallpaper-current.png');
const STATE_PATH = join(HOME, '.claude', 'wallpaper-state.json');

// --- CLI flags ---
const args = process.argv.slice(2);
const FORCE = args.includes('--force');
const PREVIEW = args.includes('--preview');

// --- State management ---
interface WallpaperState {
  shownIndices: number[];
  lastDate: string;
  lastQuoteText: string;
  cycleCount: number;
}

function loadState(): WallpaperState {
  try {
    return JSON.parse(readFileSync(STATE_PATH, 'utf-8'));
  } catch {
    return { shownIndices: [], lastDate: '', lastQuoteText: '', cycleCount: 0 };
  }
}

function saveState(state: WallpaperState): void {
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2));
}

function todayStr(): string {
  return new Date().toISOString().slice(0, 10);
}

// --- Font registration ---
function registerFonts(): void {
  const boldPaths = [
    'C:\\Windows\\Fonts\\segoeuib.ttf',
    'C:\\Windows\\Fonts\\SegoeUIBold.ttf',
    join(process.env.LOCALAPPDATA || '', 'Microsoft', 'Windows', 'Fonts', 'segoeuib.ttf'),
  ];
  const regularPaths = [
    'C:\\Windows\\Fonts\\segoeui.ttf',
    'C:\\Windows\\Fonts\\SegoeUI.ttf',
    join(process.env.LOCALAPPDATA || '', 'Microsoft', 'Windows', 'Fonts', 'segoeui.ttf'),
  ];

  const boldPath = boldPaths.find(p => existsSync(p));
  const regularPath = regularPaths.find(p => existsSync(p));

  if (!boldPath) throw new Error('Segoe UI Bold not found — check font paths');
  if (!regularPath) throw new Error('Segoe UI Regular not found — check font paths');

  GlobalFonts.registerFromPath(boldPath, 'Segoe UI Bold');
  GlobalFonts.registerFromPath(regularPath, 'Segoe UI');
}

// --- Quote selection with no-repeat cycle ---
function selectQuote(quotes: Quote[], state: WallpaperState): { quote: Quote; index: number } {
  // If all quotes shown, reset cycle
  if (state.shownIndices.length >= quotes.length) {
    state.shownIndices = [];
    state.cycleCount++;
  }

  // Pick random from unshown
  const available = quotes
    .map((q, i) => ({ q, i }))
    .filter(({ i }) => !state.shownIndices.includes(i));

  const pick = available[Math.floor(Math.random() * available.length)];
  return { quote: pick.q, index: pick.i };
}

// --- Text rendering helpers ---
function wrapText(ctx: CanvasRenderingContext2D, text: string, maxWidth: number): string[] {
  const words = text.split(/\s+/);
  const lines: string[] = [];
  let current = '';

  for (const word of words) {
    const test = current ? `${current} ${word}` : word;
    if (ctx.measureText(test).width > maxWidth && current) {
      lines.push(current);
      current = word;
    } else {
      current = test;
    }
  }
  if (current) lines.push(current);
  return lines;
}

function chooseFontSize(ctx: CanvasRenderingContext2D, text: string, maxWidth: number): number {
  // Try sizes from large to small, pick the largest that wraps to <= 6 lines
  for (let size = 72; size >= 36; size -= 4) {
    ctx.font = `${size}px "Segoe UI Bold"`;
    const lines = wrapText(ctx, text, maxWidth);
    if (lines.length <= 6) return size;
  }
  return 36; // Minimum
}

// --- Main render ---
function renderWallpaper(quote: Quote): Buffer {
  const canvas = createCanvas(WIDTH, HEIGHT);
  const ctx = canvas.getContext('2d');

  // Background
  ctx.fillStyle = BG_COLOR;
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  // Gold accent stripe on left edge (30% opacity)
  ctx.fillStyle = `rgba(197, 165, 114, 0.30)`;
  ctx.fillRect(0, 0, ACCENT_STRIPE_WIDTH, HEIGHT);

  // Large decorative open-quote mark (gold, 15% opacity)
  ctx.fillStyle = `rgba(197, 165, 114, 0.15)`;
  ctx.font = '400px "Segoe UI Bold"';
  const quoteMarkX = WIDTH * MARGIN_PCT;
  const quoteMarkY = HEIGHT * 0.30;
  ctx.fillText('\u201C', quoteMarkX - 40, quoteMarkY);

  // Calculate text area
  const textX = WIDTH * MARGIN_PCT;
  const maxTextWidth = WIDTH * (1 - 2 * MARGIN_PCT);

  // Choose font size and wrap
  const fontSize = chooseFontSize(ctx, quote.text, maxTextWidth);
  ctx.font = `${fontSize}px "Segoe UI Bold"`;
  const lines = wrapText(ctx, quote.text, maxTextWidth);
  const lineHeight = fontSize * 1.4;

  // Vertically center the text block
  const totalTextHeight = lines.length * lineHeight;
  const attrHeight = 80; // Space for rule + attribution
  const blockHeight = totalTextHeight + attrHeight;
  let startY = (HEIGHT - blockHeight) / 2 + fontSize;

  // Ensure it doesn't overlap the decorative quote mark too much
  if (startY < quoteMarkY + 40) startY = quoteMarkY + 40;

  // Draw quote text (white, bold)
  ctx.fillStyle = TEXT_COLOR;
  ctx.font = `${fontSize}px "Segoe UI Bold"`;
  for (let i = 0; i < lines.length; i++) {
    ctx.fillText(lines[i], textX, startY + i * lineHeight);
  }

  // Gold horizontal rule (200px wide, 60% opacity)
  const ruleY = startY + lines.length * lineHeight + 30;
  ctx.strokeStyle = `rgba(197, 165, 114, 0.60)`;
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.moveTo(textX, ruleY);
  ctx.lineTo(textX + 200, ruleY);
  ctx.stroke();

  // Attribution (gold, regular)
  if (quote.attribution) {
    ctx.fillStyle = GOLD;
    ctx.font = '32px "Segoe UI"';
    ctx.fillText(`\u2014 ${quote.attribution}`, textX, ruleY + 50);
  }

  return canvas.toBuffer('image/png');
}

// --- Set wallpaper via PowerShell ---
function setWallpaper(imagePath: string): void {
  const ps = `
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
Set-ItemProperty -Path "HKCU:\\Control Panel\\Desktop" -Name WallpaperStyle -Value 10
Set-ItemProperty -Path "HKCU:\\Control Panel\\Desktop" -Name TileWallpaper -Value 0
[Wallpaper]::SystemParametersInfo(0x0014, 0, "${imagePath.replace(/\\/g, '\\\\')}", 0x03)
`;

  const result = spawnSync('powershell', ['-NoProfile', '-Command', ps], {
    encoding: 'utf-8',
    timeout: 10000,
  });

  if (result.status !== 0) {
    console.error('Failed to set wallpaper:', result.stderr);
    process.exit(1);
  }
}

// --- Main ---
function main(): void {
  const today = todayStr();
  const state = loadState();

  // Same-day guard
  if (state.lastDate === today && !FORCE) {
    console.log(`Already generated today (${today}). Use --force to override.`);
    process.exit(0);
  }

  // Load quotes
  const quotes = loadAllQuotes();
  if (quotes.length === 0) {
    console.warn('No quotes available — keeping current wallpaper.');
    process.exit(0);
  }

  // Register fonts
  registerFonts();

  // Select quote
  const { quote, index } = selectQuote(quotes, state);

  // Render
  console.log(`Rendering: "${quote.text.slice(0, 60)}..." (${quote.attribution})`);
  const png = renderWallpaper(quote);

  // Ensure output directory
  if (!existsSync(OUTPUT_DIR)) {
    mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  // Save PNG
  writeFileSync(OUTPUT_PATH, png);
  console.log(`Saved: ${OUTPUT_PATH} (${png.length} bytes)`);

  // Set wallpaper (unless preview mode)
  if (!PREVIEW) {
    setWallpaper(OUTPUT_PATH);
    console.log('Wallpaper set successfully.');
  } else {
    console.log('Preview mode — wallpaper not changed.');
  }

  // Update state
  state.shownIndices.push(index);
  state.lastDate = today;
  state.lastQuoteText = quote.text;
  saveState(state);
  console.log(`State saved. Shown ${state.shownIndices.length}/${quotes.length} quotes (cycle ${state.cycleCount}).`);
}

main();
