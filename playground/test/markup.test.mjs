/**
 * Markup wiring tests for the playground.
 *
 * The playground is a zero-build static site, so the classic failure mode is
 * renaming an id in index.html and forgetting app.js (or vice versa). These
 * checks cross-reference the two files plus every local asset path, and they
 * need no dependencies — plain node:test.
 *
 * Run with: node --test playground/test/markup.test.mjs
 */
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, it } from 'node:test';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const read = (relative) => readFileSync(join(root, relative), 'utf8');

const html = read('index.html');
const appJs = read('assets/app.js');

const htmlIds = new Set([...html.matchAll(/\bid="([^"]+)"/g)].map((m) => m[1]));
const domQueries = [...appJs.matchAll(/\$\('#([A-Za-z0-9_-]+)'\)/g)].map((m) => m[1]);

describe('index.html', () => {
  it('declares a doctype, language and a viewport', () => {
    assert.match(html, /^<!DOCTYPE html>/i);
    assert.match(html, /<html[^>]*lang="en"/);
    assert.match(html, /name="viewport"/);
  });

  it('has a title and meta description for SEO/sharing', () => {
    assert.match(html, /<title>[^<]{20,}<\/title>/);
    assert.match(html, /name="description"/);
  });

  it('loads Tailwind and AOS from a CDN', () => {
    assert.match(html, /https:\/\/cdn\.tailwindcss\.com/);
    assert.match(html, /cdnjs\.cloudflare\.com\/ajax\/libs\/aos\/2\.3\.4\/aos\.css/);
    assert.match(html, /cdnjs\.cloudflare\.com\/ajax\/libs\/aos\/2\.3\.4\/aos\.js/);
  });

  it('ships a local fallback stylesheet and an AOS guard', () => {
    assert.match(html, /href="assets\/styles\.css"/);
    const css = read('assets/styles.css');
    assert.match(css, /html:not\(\.aos-ready\) \[data-aos\]/, 'AOS fallback rule missing');
    assert.match(css, /html:not\(\.tw-ready\)/, 'Tailwind fallback rule missing');
    // The fallback only works if something actually sets these classes when the
    // CDN scripts load, so assert both guards exist.
    assert.match(html, /window\.tailwind/);
    assert.match(html, /classList\.add\('tw-ready'\)/);
    assert.match(appJs, /typeof window\.AOS === 'undefined'/);
    assert.match(appJs, /classList\.add\('aos-ready'\)/);
  });

  it('links only local assets that exist on disk', () => {
    const locals = [...html.matchAll(/(?:href|src)="(?!https?:|data:|#)([^"]+)"/g)].map((m) => m[1]);
    assert.ok(locals.includes('assets/styles.css'), 'fallback stylesheet not linked');
    assert.ok(locals.includes('assets/app.js'), 'controller not linked');
    for (const path of locals) {
      assert.doesNotThrow(() => read(path), `missing local asset: ${path}`);
    }
    // The engine is imported by app.js rather than linked from the markup.
    assert.match(appJs, /from '\.\/engine\.js'/);
    assert.doesNotThrow(() => read('assets/engine.js'), 'missing assets/engine.js');
  });

  it('contains the sections the navigation points at', () => {
    for (const section of ['playground', 'what', 'pipeline', 'privacy', 'languages', 'watches', 'faq']) {
      assert.match(html, new RegExp(`id="${section}"`), `missing #${section}`);
      assert.match(html, new RegExp(`href="#${section}"`), `nav does not link #${section}`);
    }
  });

  it('exposes a skip link for keyboard users', () => {
    assert.match(html, /Skip to the live playground/);
  });
});

describe('app.js ↔ index.html wiring', () => {
  it('every element app.js queries exists in the markup', () => {
    assert.ok(domQueries.length >= 20, 'app.js should query the form controls by id');
    for (const id of domQueries) {
      assert.ok(htmlIds.has(id), `app.js queries #${id} but index.html does not define it`);
    }
  });

  it('imports only what the engine exports', async () => {
    const engine = await import('../assets/engine.js');
    const imported = [...appJs.matchAll(/import\s*\{([^}]+)\}\s*from\s*'\.\/engine\.js'/g)]
      .flatMap((m) => m[1].split(',').map((s) => s.trim()))
      .filter(Boolean);
    assert.ok(imported.length > 0);
    for (const name of imported) {
      assert.ok(name in engine, `app.js imports ${name}, which engine.js does not export`);
    }
  });

  it('has no leftover placeholder markup', () => {
    assert.doesNotMatch(html, /TODO|FIXME|lorem ipsum/i);
    assert.doesNotMatch(appJs, /TODO|FIXME/);
  });
});

describe('explanatory content', () => {
  const kotlinRoot = join(root, '..', 'android', 'core-engine', 'src', 'main', 'kotlin', 'com', 'wristreply', 'core');

  it('names a Kotlin class for every pipeline stage, and every one exists', () => {
    const stages = [...html.matchAll(/<li class="wr-stage"[^>]*>\s*<b>([^<]+)<\/b>\s*<code>([^<]+)<\/code>/g)];
    assert.strictEqual(stages.length, 8, `expected 8 pipeline stages, found ${stages.length}`);
    for (const [, title, path] of stages) {
      assert.ok(
        existsSync(join(kotlinRoot, path)),
        `stage "${title.trim()}" points at a Kotlin file that does not exist: ${path}`
      );
    }
  });

  it('answers what it is, how it works and why, in prose', () => {
    for (const heading of ['What is this, actually?', 'The eight-stage pipeline', 'The zero-cloud contract']) {
      assert.ok(html.includes(heading), `missing section heading: ${heading}`);
    }
    // "matter" requirement: the page must carry substantial prose, not just UI chrome.
    const prose = html
      .replace(/<script[\s\S]*?<\/script>/g, '')
      .replace(/<style[\s\S]*?<\/style>/g, '')
      .replace(/<[^>]+>/g, ' ')
      .replace(/\s+/g, ' ');
    assert.ok(prose.length > 6000, `expected substantial explanatory prose, found ${prose.length} chars`);
  });
});
