#!/usr/bin/env bun
/**
 * DailyQuote.ts - Serve a random Alex Hormozi quote at session start
 *
 * Reads the consolidated quotes file from SecondBrain and outputs
 * a random quote. Called by StartupGreeting.hook.ts.
 *
 * Output: A formatted quote string to stdout
 */

import { readFileSync } from 'fs';
import { join } from 'path';

const FALLBACK_QUOTES = [
  '"Discipline Equals Freedom." -- Alex Hormozi',
  '"You have nothing to lose and that makes you a very dangerous person." -- Alex Hormozi',
  '"This is what hard feels like. And this is why most people can\'t do it. But you can." -- Alex Hormozi',
  '"Successful people see opportunity in every failure normal people see failure in every opportunity." -- Alex Hormozi',
  '"Until you win, effort always goes unnoticed. Get used to it." -- Alex Hormozi',
  '"The world belongs to those who can continue to work without seeing the result of their work." -- Alex Hormozi',
  '"Everything worth doing is hard, and the more worth doing it is, the harder it is." -- Alex Hormozi',
  '"I don\'t have to deserve success. I can still just do the stuff that gets it." -- Alex Hormozi',
  '"Shame only exists in the shadows. Once you put it in the light you look at it and it evaporates." -- Alex Hormozi',
  '"I will never wish for fewer epic stories at the end of my life." -- Alex Hormozi',
];

function pickRandom(arr: string[]): string {
  return arr[Math.floor(Math.random() * arr.length)];
}

const quotesPath = join(
  process.env.HOME || process.env.USERPROFILE || '',
  'SecondBrain/Knowledge/Alex-Hormozi-Quotes.md'
);

try {
  const content = readFileSync(quotesPath, 'utf-8');

  // Extract all lines that start with "- " and contain " -- " (quote attribution pattern)
  const quotes = content
    .split('\n')
    .filter(line => line.startsWith('- "') && line.includes(' -- '))
    .map(line => line.slice(2).trim()); // Remove "- " prefix

  if (quotes.length === 0) {
    console.log(pickRandom(FALLBACK_QUOTES));
    process.exit(0);
  }

  console.log(pickRandom(quotes));
} catch {
  // File missing or unreadable — use fallback quotes
  console.log(pickRandom(FALLBACK_QUOTES));
}
