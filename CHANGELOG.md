# Vefna Changelog

## v1.0.0 - 2026-07-17

The first release, built with Torvik v1.3.0.

- `vefna new` — scaffold a complete starter site (config, template, sample
  content, stylesheet)
- `vefna build` — incremental, deterministic site generation into `site/`
  (`--clean` for a full rebuild)
- Markdown subset: headings, paragraphs, bold/italic/inline code, links, images,
  ordered and unordered lists, blockquotes, fenced code blocks with language
  classes, horizontal rules — all output HTML-escaped
- Front matter (`title`, `description`, `author`, `date`, `template`) with
  site-level fallbacks from `vefna.site`
- HTML templates with `{{slot}}` placeholders; per-page template selection
- `static/` assets copied binary-safe to `site/static/`, with the same
  incremental mtime logic as pages
- Parallel rendering on 8 `raven` worker threads over typed `bridge` channels —
  500+ pages weave in well under a second
- Test suite: 21 cases (CLI surface, golden-file output, incremental behavior,
  determinism, binary round-trips, error paths) with runners for Linux and Windows
