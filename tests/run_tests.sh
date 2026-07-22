#!/usr/bin/env bash
# Vefna test suite (Linux). Run from the project root:
#   bash tests/run_tests.sh [path/to/vefna]
set -u
VEFNA="${1:-build/vefna}"
VEFNA="$(cd "$(dirname "$VEFNA")" && pwd)/$(basename "$VEFNA")"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$ROOT/tests/tmp"
PASS=0; FAIL=0

t() { # t <name> <exit-code-of-test>
    if [ "$2" -eq 0 ]; then PASS=$((PASS+1)); echo "  ok   $1";
    else FAIL=$((FAIL+1)); echo "  FAIL $1"; fi
}

rm -rf "$TMP"; mkdir -p "$TMP"; cd "$TMP"

# --- CLI surface ---
"$VEFNA" version | grep -q "vefna v"; t "version prints version" $?
"$VEFNA" help >/dev/null 2>&1; t "help exits 0" $?
"$VEFNA" bogus >/dev/null 2>&1 && t "unknown command exits non-zero" 1 || t "unknown command exits non-zero" 0
"$VEFNA" build >/dev/null 2>&1 && t "build outside a site exits non-zero" 1 || t "build outside a site exits non-zero" 0
"$VEFNA" new "a/b" >/dev/null 2>&1 && t "new rejects a slash in the name" 1 || t "new rejects a slash in the name" 0

# --- new + double-new ---
"$VEFNA" new scaffolded >/dev/null 2>&1; t "new creates a site" $?
[ -f scaffolded/vefna.site ] && [ -f scaffolded/templates/page.html ] && [ -f scaffolded/content/index.md ]; t "new lays out config, template, content" $?
"$VEFNA" new scaffolded >/dev/null 2>&1 && t "new refuses an existing directory" 1 || t "new refuses an existing directory" 0
( cd scaffolded && "$VEFNA" build >/dev/null 2>&1 ); t "scaffolded site builds" $?
grep -q "{{title}}" scaffolded/templates/page.html; t "scaffolded template holds literal {{slots}}" $?
grep -q "<h1>" scaffolded/site/index.html; t "scaffolded site rendered markdown" $?

# --- golden-file build ---
cp -r "$ROOT/tests/fixture" fx
( cd fx && "$VEFNA" build --clean >/dev/null 2>&1 ); t "fixture builds clean" $?
diff -r fx/site "$ROOT/tests/golden" >/dev/null 2>&1; t "fixture output matches golden files" $?
cmp -s fx/static/img/rune.bin fx/site/static/img/rune.bin; t "binary asset round-trips byte-identical" $?

# --- incremental behavior ---
( cd fx && "$VEFNA" build 2>/dev/null | grep -q "up to date" ); t "second build is a no-op" $?
sleep 1.1; touch fx/content/nested/deep.md
( cd fx && "$VEFNA" build 2>/dev/null | grep -q "Wove 1 of 3" ); t "touched page rebuilds exactly one page" $?
sleep 1.1; touch fx/templates/page.html
( cd fx && "$VEFNA" build 2>/dev/null | grep -q "Wove 3 of 3" ); t "touched template rebuilds every page" $?
sleep 1.1; touch fx/vefna.site
( cd fx && "$VEFNA" build 2>/dev/null | grep -q "Wove 3 of 3" ); t "touched config rebuilds every page" $?

# --- determinism: two clean builds are byte-identical ---
cp -r "$ROOT/tests/fixture" fx2
( cd fx2 && "$VEFNA" build --clean >/dev/null 2>&1 )
( cd fx  && "$VEFNA" build --clean >/dev/null 2>&1 )
diff -r fx/site fx2/site >/dev/null 2>&1; t "clean builds are deterministic" $?

# --- error paths ---
cp -r "$ROOT/tests/fixture" fxerr
printf -- '---\ntitle: Broken\ntemplate: nope\n---\n\n# x\n' > fxerr/content/broken.md
( cd fxerr && "$VEFNA" build --clean >/dev/null 2>&1 ) && t "missing template fails the build" 1 || t "missing template fails the build" 0
( cd fxerr && "$VEFNA" build --clean 2>/dev/null | grep -q "error:" ); t "missing template reports the page" $?

# --- drafts (v1.1.0) ---
"$VEFNA" new drafttest >/dev/null 2>&1
printf '%s\n' '---' 'title: Draft' 'draft: true' '---' '# Draft body' > drafttest/content/secret.md
( cd drafttest && "$VEFNA" build --clean >/dev/null 2>&1 ); t "site with a draft builds" $?
[ ! -f drafttest/site/secret.html ]; t "draft is excluded by default" $?
( cd drafttest && "$VEFNA" build --clean --drafts >/dev/null 2>&1 ); t "build --drafts rebuilds" $?
[ -f drafttest/site/secret.html ]; t "draft is included with --drafts" $?
( cd drafttest && "$VEFNA" build --clean 2>/dev/null | grep -q "draft(s) skipped" ); t "default build reports skipped drafts" $?


echo ""
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
