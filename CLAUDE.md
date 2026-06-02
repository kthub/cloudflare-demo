# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A collection of standalone static HTML documents served as a single site on Cloudflare Workers (Static Assets). There is no build step, no framework, no `package.json`, and no test suite — pages are hand-written HTML that share one stylesheet. Live at https://cloudflare-demo.shrewd.workers.dev/.

## Commands

```bash
npx wrangler dev      # local preview at http://localhost:8787/
npx wrangler deploy   # deploy to Cloudflare (publishes everything in the repo root)
```

`wrangler` is not a declared dependency — it is run via `npx`.

## Architecture

- `wrangler.jsonc` sets `assets.directory` to `./public`, so **only files under `public/` are published**. Everything else in the repo (`scripts/`, `README.md`, `CLAUDE.md`, `work/`, `wrangler.jsonc`) stays private. `public/index.html` resolves at `/`, `public/cloudflare-guide.html` at `/cloudflare-guide.html`, etc. Put anything that should be web-accessible under `public/`.
- `public/index.html` is the table of contents ("Temporary Static Documents"). Each document is one `<li><a class="doc">` entry inside `<ul class="docs">`, with a two-digit `idx` sequence number.
- `public/css/style.css` is the **single shared stylesheet for the whole site** — every page links it. It holds the design tokens (`:root` vars), shared chrome (header/footer/`.wrap`), guide-specific components (`.steps`, `.tabs`, `pre` code blocks, `.note`), and the TOC card styles (`.docs`/`.doc`). All pages are expected to share this one look; do not add per-page CSS files.
- Each document page is self-contained HTML linking the Google Fonts (Bricolage Grotesque / Zen Kaku Gothic New / JetBrains Mono) and `css/style.css`, with markup-only `<body>`.

## Adding a document

Use the generator rather than hand-creating files — it keeps the TOC in sync:

```bash
scripts/new-doc.sh <slug> "<title>" ["<description>"]
```

It creates `public/<slug>.html` from the shared template (a sample doc demonstrating the common components) and appends a correctly-numbered entry to the `<ul class="docs">` in `public/index.html` (inserted before its `</ul>`, numbering auto-derived from the existing entry count). `slug` must be `[a-zA-Z0-9_-]` and must not collide with an existing file.
