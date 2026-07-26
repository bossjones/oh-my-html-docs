"""Tests for scripts/new_doc.py — the standalone-HTML importer.

The script is PEP 723 (uv run) and guards its CLI behind ``if __name__ == "__main__"``, so we load it
by path with importlib and exercise the importable functions directly.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

_SCRIPT = Path(__file__).resolve().parent.parent / "scripts" / "new_doc.py"


def _load_module():
    spec = importlib.util.spec_from_file_location("new_doc", _SCRIPT)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


new_doc = _load_module()


def test_slugify():
    assert new_doc.slugify("cmux Guide!") == "cmux-guide"
    assert new_doc.slugify("  Boss AI / Monitoring  ") == "boss-ai-monitoring"


def test_import_bundle_directory(tmp_path):
    # A multi-file bundle: index.html + a sibling asset.
    src = tmp_path / "guide"
    src.mkdir()
    (src / "index.html").write_text("<h1>hello cmux</h1><img src='images/x.png'>", encoding="utf-8")
    (src / "images").mkdir()
    (src / "images" / "x.png").write_bytes(b"\x89PNG\r\n")

    docs_root = tmp_path / "docs"
    pages_dir, card_path = new_doc.import_doc(
        src,
        title="cmux Guide",
        category="guides",
        tags=["cmux", "agents"],
        description="Visual guide.",
        source_label="disler/learning-cmux-with-agents",
        docs_root=docs_root,
    )

    # Verbatim bundle copied with structure preserved.
    assert (pages_dir / "index.html").read_text(encoding="utf-8").startswith("<h1>hello cmux</h1>")
    assert (pages_dir / "images" / "x.png").exists()
    assert pages_dir == docs_root / "pages" / "cmux-guide"

    # Card generated at the category path with correct front matter.
    assert card_path == docs_root / "library" / "guides" / "cmux-guide.md"
    card = card_path.read_text(encoding="utf-8")
    assert 'title: "cmux Guide"' in card
    assert "tags: [cmux, agents]" in card
    assert "category: " in card
    assert "html: /pages/cmux-guide/" in card
    assert "[Open the document →](/pages/cmux-guide/)" in card


def test_import_single_file_wrapped_as_index(tmp_path):
    src = tmp_path / "report.html"
    src.write_text("<h1>report body</h1>", encoding="utf-8")

    docs_root = tmp_path / "docs"
    pages_dir, card_path = new_doc.import_doc(
        src,
        title="My Report",
        category="specs",
        tags=["observability"],
        docs_root=docs_root,
    )

    # Lone file is wrapped so the URL is a clean /pages/<slug>/.
    assert (pages_dir / "index.html").read_text(encoding="utf-8") == "<h1>report body</h1>"
    assert card_path.exists()


def test_refuses_overwrite_without_force(tmp_path):
    src = tmp_path / "a.html"
    src.write_text("<p>a</p>", encoding="utf-8")
    docs_root = tmp_path / "docs"
    new_doc.import_doc(src, title="Dup", category="c", tags=[], docs_root=docs_root)

    try:
        new_doc.import_doc(src, title="Dup", category="c", tags=[], docs_root=docs_root)
    except FileExistsError:
        pass
    else:
        raise AssertionError("expected FileExistsError on re-import without force")

    # force=True overwrites cleanly.
    new_doc.import_doc(src, title="Dup", category="c", tags=[], docs_root=docs_root, force=True)
