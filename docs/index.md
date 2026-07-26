# oh-my-html-docs

A home for **standalone HTML documentation** — self-contained pages that carry their own CSS/JS (and
sibling image assets) — made browsable, categorized, tag-filterable, and searchable.

## How it works

Each document is stored two ways:

- **The verbatim bundle** lives under `docs/pages/<slug>/` (a folder with `index.html` + its assets) or as
  a single `docs/pages/<slug>.html`. MkDocs copies these to the built site **unchanged**, so every page
  renders exactly as authored — its own styling, scripts, and images intact.
- **A thin "card"** lives under `docs/library/<category>/<slug>.md`. The card carries the metadata
  (`title`, `description`, `tags`, `category`) that powers navigation and the [Tags](tags.md) index, and
  links out to the full document with an **"Open the document →"** button.

## Browse

- **[Library](library/index.md)** — every document, grouped by category.
- **[Tags](tags.md)** — filter documents by tag.
- **Search** — full-text search over the actual HTML is provided by
  [Pagefind](https://pagefind.app/) on the built/deployed site.

## Add a document

```bash
just add path/to/doc.html --title "My Doc" --category guides --tags cmux,agents
# or a multi-file bundle:
just add path/to/guide/ --title "My Guide" --category guides --tags orchestration
```

This is the scaffold; the library is empty until the first documents are imported.
