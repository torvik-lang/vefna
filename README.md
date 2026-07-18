# Vefna

**A static site generator woven in [Torvik](https://github.com/torvik-lang/torvik).**

*(VEF-nah — coined from the Old Norse* vefa*, "to weave," and* vefr*, "web." In the myths,
the Norns sit beneath the world-tree weaving the threads of fate. Vefna weaves only web
pages, which is safer.)*

Vefna reads a folder of Markdown, presses it through your HTML templates, and writes a
complete static site — ready for GitHub Pages, Cloudflare Pages, Netlify, or any plain web
server. No runtime, no database, no dependencies: one compiled binary.

Vefna is also the flagship showcase for **Torvik v1.3.0**: it renders pages in parallel on
8 `raven` worker threads fed by typed `bridge` channels, and the whole tool is written in
Torvik itself. On modest hardware it weaves **500+ pages in well under a second**.

## Install

**Linux**
```
curl -fsSL https://raw.githubusercontent.com/torvik-lang/vefna/main/linux/install.sh | sh
```

**Windows (PowerShell)**
```
iwr -useb https://raw.githubusercontent.com/torvik-lang/vefna/main/windows/install.ps1 | iex
```

Or download the binary for your platform from the [releases page](https://github.com/torvik-lang/vefna/releases) and put it on your PATH — Vefna is a single file with no dependencies.

## Quick start

```bash
vefna new myblog
cd myblog
vefna build
```

Your site is in `site/`. Open `site/index.html` in a browser, or push `site/` to any
static host.

## Commands

| Command | What it does |
|---------|--------------|
| `vefna new <name>` | Create a starter site in a new directory |
| `vefna build` | Build changed pages (incremental) into `site/` |
| `vefna build --clean` | Delete `site/` and rebuild everything |
| `vefna version` | Version information |
| `vefna help` | Usage |

Builds are **incremental**: a page is rewoven only when its source, any template, or
`vefna.site` is newer than its output. They are also **deterministic**: the same inputs
produce a byte-identical site, every time, on every platform.

## A site's layout

```
myblog/
  vefna.site        # site configuration
  content/          # your pages, as Markdown (.md); folders carry through
    index.md
    posts/
      first.md      # -> site/posts/first.html
  templates/
    page.html       # the default template
  static/           # copied verbatim to site/static/ (binary-safe)
    style.css
  site/             # the generated site (never edit by hand)
```

## Configuration — `vefna.site`

Plain `key: value` lines; `#` starts a comment.

```
title: My Blog
description: Notes from the workshop
author: Sigrid
url:
```

`url` is the base prefix for links and assets in the default template. Leave it empty when
the site is served from a domain root; set it (for example `/myblog`) when the site lives
under a subpath, as on GitHub project pages.

## Pages and front matter

A page may open with a front-matter block:

```markdown
---
title: My First Post
date: 2026-07-17
description: In which things are woven
author: Sigrid
template: page
---

# My First Post

The body starts after the closing fence.
```

Every key is optional. `title`, `description`, and `author` fall back to the site values;
`template: name` selects `templates/name.html` instead of `templates/page.html`.

## Templates

A template is an ordinary HTML file with `{{slot}}` placeholders:

| Slot | Filled with |
|------|-------------|
| `{{content}}` | The page body, rendered from Markdown |
| `{{title}}`, `{{description}}`, `{{author}}`, `{{date}}` | The page's front matter (with site fallbacks) |
| `{{site_title}}`, `{{site_description}}`, `{{site_url}}` | Values from `vefna.site` |

## Markdown

Vefna renders a pragmatic Markdown subset, chosen to cover real sites while staying
predictable:

- Headings `#` through `######`
- Paragraphs (consecutive lines join; a blank line separates)
- `**bold**`, `*italic*`, and `` `inline code` `` (code spans protect their contents)
- `[links](url)` and `![images](url)`
- Unordered lists (`-` or `*`) and ordered lists (`1.`)
- `> blockquotes`, including multi-line
- Fenced code blocks, with an optional language emitted as
  `class="language-…"` for client-side highlighters
- Horizontal rules (`---` or `***`)

All text is HTML-escaped on the way through, including inside code blocks. An unclosed
`**`/`*`/`` ` `` is closed at the end of its line so output is always valid HTML; a lone
`*` in prose opens emphasis, so put literal asterisks inside a code span.

## Hosting for free

`site/` is plain files. GitHub Pages, Cloudflare Pages, and Netlify all host static sites
at no cost — build locally, publish the `site/` folder, done.

## Building Vefna from source

Vefna is a standard [rune](https://github.com/torvik-lang/torvik) project:

```bash
rune build --final     # -> build/vefna
```

Run the test suite from the project root — 21 cases covering the CLI, golden-file output,
incremental rebuild behavior, determinism, binary asset round-trips, and error paths:

```bash
bash tests/run_tests.sh build/vefna                                  # Linux
powershell -ExecutionPolicy Bypass -File tests\run_tests.ps1         # Windows
```

## License

AGPL-3.0. The sites Vefna generates are your content, entirely yours.
