# Security Policy

## Supported Versions

Vefna follows the Torvik project's five-year support policy. Each major version gets
three years of **Active** support (features, bug fixes, security), one year of
**Maintenance** (bug and security fixes only), and one year of **Security** fixes.

| Line | Stage | Security fixes until |
| ---- | ----- | -------------------- |
| 1.x  | **Active** | 4 July 2031 |
| < 1.0 | End of life | — |

Fixes are backported to every line still inside its window, so a 1.x release keeps
receiving security patches even after a 2.0 ships.

Full policy: [SUPPORT.md](https://github.com/torvik-lang/torvik/blob/main/SUPPORT.md)

## Reporting a Vulnerability

Please **do not** open a public issue for a security problem.

Instead, use GitHub's private vulnerability reporting: go to the repository's
**Security** tab and choose **Report a vulnerability**
(https://github.com/torvik-lang/vefna/security/advisories/new). That opens a
private thread visible only to you and the maintainer.

If that route doesn't work for you, open a regular issue saying only that you
have a security report and would like a private channel — **without any
details** — and the maintainer will arrange one.

What to include: the Vefna version (`vefna version`), your platform, what an
attacker can do, and reproduction steps or a proof-of-concept if you have one.

What to expect:

- **Acknowledgment** within 7 days.
- **Assessment** — whether it's accepted as a vulnerability, with reasoning
  either way — typically within 14 days of acknowledgment.
- **A fix** in a patch release as quickly as severity warrants, with credit to
  the reporter in the release notes unless you'd rather stay anonymous.

## Scope

Vefna is a local build tool: it reads the files of a site project you control
and writes HTML. In scope, roughly in order of interest:

- Path traversal — crafted content, config, or front-matter values causing
  writes or reads **outside** the site project (for example escaping `site/`).
- Crashes or memory-safety issues triggered by malformed input files.
- The install scripts (`linux/install.sh`, `windows/install.ps1`) — anything
  that could make them fetch or run something other than the intended release.
- Flaws in Vefna's HTML escaping that let *Markdown body text* inject raw
  markup or script into the output.

Out of scope, by design:

- **Templates emitting arbitrary HTML.** Template files are trusted input —
  they exist to write whatever HTML you want, scripts included. Building a site
  from a template you didn't review is equivalent to running code you didn't
  review.
- Building wholly untrusted site projects in a security boundary. Vefna doesn't
  sandbox; treat a site project like source code.
- Vulnerabilities in the Torvik toolchain itself — report those to
  https://github.com/torvik-lang/torvik.
