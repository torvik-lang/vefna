---
title: Kitchen Sink
date: 2026-07-17
description: Every Markdown feature Vefna supports
---

# Heading one

## Heading two

### Heading three

#### Heading four

##### Heading five

###### Heading six

A paragraph with **bold text**, *italic text*, and `inline code`.
This second line joins the same paragraph.

A [link](https://example.com/a?b=1&c=2) and an image:

![a rune stone](img/rune.png)

Inline code protects markdown: `**not bold** and [not](a-link)`.

- first unordered
- second with **bold**
* star bullet also works

1. first ordered
2. second ordered
10. tenth ordered

> A blockquote line
> and its continuation.

```torvik
df main() -> void {
    check 1 < 2 { echo!("escaped: <tags> & ampersands"); }
}
```

```
plain fence, no language
```

---

HTML must be escaped: <script>alert("x")</script> & so on.

Unclosed **bold stays valid HTML.

Literal [brackets without a target and a lone * survive.
