# LLM-wiki pattern (reference)

A generic example of a library an agent maintains for a human. Use it as a fallback when a repo has no library rules of its own.

## Layout

```
library/
├── schema/          conventions and workflows (the configuration layer)
│   ├── README.md    layout, naming, page format, frontmatter, lint cadence
│   ├── ingest.md    ingest workflow, points to the ingest skill
│   └── lint.md      lint workflow, points to the lint skill
├── raw/             source documents, immutable after they are added
│   └── example-source.md
└── wiki/            agent-owned pages, flat (no subfolders)
    ├── index.md     content catalog, grouped by category
    ├── log.md       append-only chronological log
    └── example-topic.md
```

- `schema/` changes only when conventions change.
- `raw/` is the source of truth. Never edit a file there after it is added.
- `wiki/` is written and maintained by the agent. Pages are flat.

## Naming

- Wiki filenames are `kebab-case.md`: no spaces, no uppercase, one topic per file.
- Source filenames in `raw/` are free-form.

## Frontmatter

Every wiki page starts with:

```yaml
---
title: Example Topic
tags: [example, pattern]
created: 2025-01-01
updated: 2025-01-01
sources: [example-source]
---
```

- `title`: human-readable title.
- `tags`: array of lowercase topic tags.
- `created`, `updated`: `YYYY-MM-DD`. Bump `updated` on every edit.
- `sources`: raw files that informed the page. `index.md` and `log.md` use `[]`.

## Links

- Internal links are wikilinks: `[[page-name]]`, with no `.md` and no path.
- Every page links to at least one other page, and is linked from at least one page.
- Show literal link syntax inside a code span so it is not parsed as a link.

## Index

`wiki/index.md` lists every page once, under a category heading:

```markdown
## Patterns
- [[example-topic]] — one-line summary
```

Add a heading for a new category. Bump `updated` in the index's frontmatter when it changes.

## Log

`wiki/log.md` is append-only. Add new entries at the end. Heading format:

```markdown
## [2025-01-01] ingest | Example Topic
- Source: example-source
- Pages created: example-topic
- Index updated: yes
- Log updated: yes
- Key takeaways: one line
```

The operation slot is one of `ingest`, `query`, or `lint`. The format lets you list recent entries with `grep "^## \[" log.md | tail -5`.

## Ingest flow

1. Read `schema/README.md`, `wiki/index.md`, and the tail of `wiki/log.md`.
2. Add the source to `raw/` if it is a document, URL content, or a long transcript. Short notes go straight to the wiki.
3. Search for an existing page on the topic. Update it if one fits.
4. Otherwise create `wiki/<kebab-case-name>.md` with full frontmatter and at least one outbound and one inbound link.
5. Update the index, bump `updated`, and append a log entry.
6. If the new source contradicts a page, edit that page and note the contradiction.

## Example page

```markdown
---
title: Example Topic
tags: [example, pattern]
created: 2025-01-01
updated: 2025-01-01
sources: [example-source]
---

# Example Topic

One paragraph summarising the topic in plain terms.

## Details

- Point one, with a fact that can be checked against the source.
- Point two.

## See Also
- [[example-related-topic]] — how it relates
- [[example-index-topic]] — the broader pattern
```

Pattern: H1 matches `title`, a one-paragraph summary, H2 sections, and a `## See Also` list of wikilinks with one em-dash description per line.
