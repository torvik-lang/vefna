# Vefna Roadmap

Vefna is deliberately small: Markdown in, HTML out, fast and deterministic.
These are the candidates for what comes next, in rough order of likelihood.

## Shipped in v1.1.0

- **`vefna serve`** — a local preview server with rebuild-on-change, built on
  Torvik's `std::net`.
- **Watch mode** — `vefna watch` / `vefna build --watch`.
- **Draft pages** — `draft: true` front matter, skipped unless `--drafts` is passed.

## Planned / under consideration

- **Page collections** — an index-page mechanism that can list pages in a folder
  (newest first by `date`), for blog front pages and archives.
- **Tags** — `tags:` front matter and generated tag pages.
- **RSS/Atom feed** and **sitemap.xml** generation.
- **Richer Markdown** — tables, nested lists, and reference-style links, as the need
  is proven by real sites.

## Non-goals

- Themes marketplaces, plugins, JavaScript pipelines, bundlers. Vefna stays one binary
  that turns Markdown into HTML.

macOS support follows Torvik's own: once the language supports macOS, Vefna builds
there unchanged.
