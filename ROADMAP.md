# Vefna Roadmap

Vefna v1.0.0 is deliberately small: Markdown in, HTML out, fast and deterministic.
These are the candidates for what comes next, in rough order of likelihood.

## Planned / under consideration

- **`vefna serve`** — a local preview server with rebuild-on-change. Deliberately held
  out of v1: doing it right means HTTP support in Torvik itself (a future `std::net`
  or networking library) rather than shelling out to an external server. Tracked here
  so it isn't forgotten.
- **Page collections** — an index-page mechanism that can list pages in a folder
  (newest first by `date`), for blog front pages and archives.
- **Tags** — `tags:` front matter and generated tag pages.
- **RSS/Atom feed** and **sitemap.xml** generation.
- **Draft pages** — `draft: true` front matter, skipped unless `--drafts` is passed.
- **Richer Markdown** — tables, nested lists, and reference-style links, as the need
  is proven by real sites.
- **Watch mode** — `vefna build --watch`, likely arriving together with `vefna serve`.

## Non-goals

- Themes marketplaces, plugins, JavaScript pipelines, bundlers. Vefna stays one binary
  that turns Markdown into HTML.

macOS support follows Torvik's own: once the language supports macOS, Vefna builds
there unchanged.
