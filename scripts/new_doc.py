#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///
"""Import a standalone HTML document into the site.

Given an HTML file or a multi-file bundle directory, this:

1. Copies the content **verbatim** into ``docs/pages/<slug>/`` (structure preserved), so MkDocs
   serves it unchanged with its own CSS/JS/images intact.
2. Generates a thin "card" at ``docs/library/<category>/<slug>.md`` carrying the metadata that drives
   navigation + the Tags index, with an "Open the document →" button linking to the verbatim bundle.

Examples::

    # single self-contained file -> wrapped as docs/pages/<slug>/index.html
    uv run scripts/new_doc.py ./report.html --title "My Report" --category specs --tags observability

    # multi-file bundle (index.html + assets) -> copied as a folder
    uv run scripts/new_doc.py ./guide/ --title "cmux Guide" --category guides --tags cmux,agents
"""

from __future__ import annotations

import argparse
import datetime
import re
import shutil
import sys
from pathlib import Path

# Repo root = parent of scripts/. docs/ lives at the root.
DEFAULT_DOCS_ROOT = Path(__file__).resolve().parent.parent / "docs"


def slugify(text: str) -> str:
    """Lowercase, collapse non-alphanumerics to single hyphens, trim edges."""
    slug = re.sub(r"[^a-z0-9]+", "-", text.strip().lower())
    return slug.strip("-")


def _yaml_quote(value: str) -> str:
    """Double-quote a scalar for YAML front matter, escaping backslashes and quotes."""
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def render_card(
    *,
    title: str,
    description: str,
    tags: list[str],
    category: str,
    html_url: str,
    source_label: str,
    added: str,
) -> str:
    """Return the markdown card (front matter + body) for a document."""
    tag_list = ", ".join(tags)
    front_matter = "\n".join(
        [
            "---",
            f"title: {_yaml_quote(title)}",
            f"description: {_yaml_quote(description)}",
            f"tags: [{tag_list}]",
            f"category: {_yaml_quote(category)}",
            f"html: {html_url}",
            f"source: {_yaml_quote(source_label)}",
            f"added: {added}",
            "---",
        ]
    )
    body_lines = [f"# {title}", ""]
    if description:
        body_lines += [description, ""]
    body_lines += [f"[Open the document →]({html_url}){{ .md-button .md-button--primary }}", ""]
    if source_label:
        body_lines += [f"**Source:** {source_label}", ""]
    return front_matter + "\n\n" + "\n".join(body_lines)


def import_doc(
    source: Path,
    *,
    title: str,
    category: str,
    tags: list[str],
    description: str = "",
    source_label: str = "",
    slug: str | None = None,
    added: str | None = None,
    docs_root: Path = DEFAULT_DOCS_ROOT,
    force: bool = False,
) -> tuple[Path, Path]:
    """Copy the verbatim bundle and write the card. Returns (pages_dir, card_path)."""
    source = Path(source)
    if not source.exists():
        raise FileNotFoundError(f"source does not exist: {source}")

    slug = slug or slugify(title)
    if not slug:
        raise ValueError("could not derive a slug; pass --slug")
    added = added or datetime.date.today().isoformat()

    pages_dir = Path(docs_root) / "pages" / slug
    card_path = Path(docs_root) / "library" / category / f"{slug}.md"

    if not force and (pages_dir.exists() or card_path.exists()):
        raise FileExistsError(f"slug '{slug}' already imported (use force=True to overwrite)")

    # Copy the verbatim content.
    if source.is_dir():
        shutil.copytree(source, pages_dir, dirs_exist_ok=force)
        if not (pages_dir / "index.html").exists():
            print(f"warning: {pages_dir} has no index.html; the URL /pages/{slug}/ may 404", file=sys.stderr)
    else:
        pages_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, pages_dir / "index.html")

    html_url = f"/pages/{slug}/"
    card_path.parent.mkdir(parents=True, exist_ok=True)
    card_path.write_text(
        render_card(
            title=title,
            description=description,
            tags=tags,
            category=category,
            html_url=html_url,
            source_label=source_label,
            added=added,
        ),
        encoding="utf-8",
    )
    return pages_dir, card_path


def _parse_tags(raw: str) -> list[str]:
    return [t.strip() for t in raw.split(",") if t.strip()]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Import a standalone HTML doc into the site.")
    parser.add_argument("source", type=Path, help="Path to an .html file or a bundle directory.")
    parser.add_argument("--title", required=True, help="Human title (also drives the slug).")
    parser.add_argument("--category", required=True, help="Category folder under docs/library/.")
    parser.add_argument("--tags", default="", help="Comma-separated tags.")
    parser.add_argument("--description", default="", help="One-line description for the card.")
    parser.add_argument("--source", dest="source_label", default="", help="Provenance note.")
    parser.add_argument("--slug", default=None, help="Override the derived slug.")
    parser.add_argument("--added", default=None, help="ISO date (default: today).")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing import.")
    args = parser.parse_args(argv)

    pages_dir, card_path = import_doc(
        args.source,
        title=args.title,
        category=args.category,
        tags=_parse_tags(args.tags),
        description=args.description,
        source_label=args.source_label,
        slug=args.slug,
        added=args.added,
        force=args.force,
    )
    print(f"bundle: {pages_dir}")
    print(f"card:   {card_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
