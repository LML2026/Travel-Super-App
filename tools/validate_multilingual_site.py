#!/usr/bin/env python3
from __future__ import annotations

from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse
import re
import sys
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
BASE = "https://www.itarevo.com"
LOCALES = [
    ("en", "en-GB"),
    ("fr", "fr-FR"),
    ("es", "es-ES"),
    ("it", "it-IT"),
    ("de", "de-DE"),
    ("pt", "pt-PT"),
    ("ja", "ja-JP"),
    ("ar", "ar"),
    ("bg", "bg-BG"),
    ("cs", "cs-CZ"),
    ("da", "da-DK"),
    ("el", "el-GR"),
    ("nl", "nl-NL"),
    ("pl", "pl-PL"),
    ("ro", "ro-RO"),
    ("ru", "ru-RU"),
    ("sv", "sv-SE"),
    ("tr", "tr-TR"),
    ("zh", "zh-CN"),
]
PAGES = [
    ("home", "", "index.html"),
    ("features", "features/", "features/index.html"),
    ("finance", "finance/", "finance/index.html"),
    ("about", "about/", "about/index.html"),
    ("support", "support/", "support/index.html"),
    ("privacy", "privacy/", "privacy/index.html"),
    ("terms", "terms/", "terms/index.html"),
]


class Parser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.html_attrs = {}
        self.links = []
        self.assets = []
        self.select_values = []
        self.canonical = None
        self.alternates = {}

    def handle_starttag(self, tag, attrs):
        data = dict(attrs)
        if tag == "html":
            self.html_attrs = data
        if tag == "a" and data.get("href"):
            self.links.append(data["href"])
        if tag in {"img", "script"} and data.get("src"):
            self.assets.append(data["src"])
        if tag == "link":
            if data.get("rel") == "stylesheet" and data.get("href"):
                self.assets.append(data["href"])
            if data.get("rel") == "icon" and data.get("href"):
                self.assets.append(data["href"])
            if data.get("rel") == "canonical":
                self.canonical = data.get("href")
            if data.get("rel") == "alternate" and data.get("hreflang"):
                self.alternates[data["hreflang"]] = data.get("href")
        if tag == "option" and data.get("value"):
            self.select_values.append(data["value"])


def page_path(locale: str, output: str) -> Path:
    return DOCS / output if locale == "en" else DOCS / locale / output


def page_url(locale: str, slug: str) -> str:
    prefix = "" if locale == "en" else f"{locale}/"
    return f"{BASE}/{prefix}{slug}"


def selector_path(locale: str, slug: str) -> str:
    prefix = "" if locale == "en" else f"{locale}/"
    return f"/{prefix}{slug}"


def resolve_path(page: Path, href: str) -> Path | None:
    if href.startswith(("mailto:", "tel:", "#")):
        return None
    parsed = urlparse(href)
    if parsed.scheme in {"http", "https"}:
        if parsed.netloc == "www.itarevo.com":
            rel = parsed.path.lstrip("/")
            return DOCS / rel / "index.html" if parsed.path.endswith("/") else DOCS / rel
        return None
    clean = href.split("#", 1)[0]
    if not clean:
        return None
    candidate = (page.parent / clean).resolve()
    return candidate / "index.html" if clean.endswith("/") else candidate


def validate() -> list[str]:
    errors = []
    expected_urls = set()
    parsed_pages = {}
    for locale, lang in LOCALES:
        for key, slug, output in PAGES:
            expected_urls.add(page_url(locale, slug))
            path = page_path(locale, output)
            if not path.exists():
                errors.append(f"missing page: {path}")
                continue
            html = path.read_text(encoding="utf-8")
            parser = Parser()
            try:
                parser.feed(html)
            except Exception as exc:
                errors.append(f"HTML parse failed for {path}: {exc}")
                continue
            parsed_pages[(locale, key)] = parser
            if parser.html_attrs.get("lang") != lang:
                errors.append(f"wrong lang for {path}: {parser.html_attrs.get('lang')}")
            if locale == "ar" and parser.html_attrs.get("dir") != "rtl":
                errors.append(f"Arabic page missing dir=rtl: {path}")
            if locale != "ar" and parser.html_attrs.get("dir"):
                errors.append(f"non-Arabic page has unexpected dir: {path}")
            if parser.canonical != page_url(locale, slug):
                errors.append(f"bad canonical for {path}: {parser.canonical}")
            expected_alts = {alt_lang: page_url(code, slug) for code, alt_lang in LOCALES}
            expected_alts["x-default"] = page_url("en", slug)
            if parser.alternates != expected_alts:
                errors.append(f"bad hreflang set for {path}")
            expected_switches = {selector_path(code, slug) for code, _ in LOCALES}
            if set(parser.select_values) != expected_switches:
                errors.append(f"bad language selector targets for {path}")
            for href in parser.links:
                target = resolve_path(path, href)
                if target and not target.exists():
                    errors.append(f"missing internal link target from {path}: {href} -> {target}")
            for src in parser.assets:
                target = resolve_path(path, src)
                if target and not target.exists():
                    errors.append(f"missing asset from {path}: {src} -> {target}")

    sitemap = DOCS / "sitemap.xml"
    try:
        tree = ET.parse(sitemap)
        ns = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
        urls = {node.text for node in tree.findall(".//sm:loc", ns)}
        if urls != expected_urls:
            errors.append(f"sitemap URL set mismatch: expected {len(expected_urls)}, got {len(urls)}")
    except Exception as exc:
        errors.append(f"sitemap parse failed: {exc}")

    if (DOCS / "CNAME").read_text(encoding="utf-8").strip() != "www.itarevo.com":
        errors.append("CNAME changed or invalid")

    css = (DOCS / "site.css").read_text(encoding="utf-8")
    if css.count("{") != css.count("}"):
        errors.append("CSS brace count mismatch")
    for asset in re.findall(r"url\(['\"]?([^)'\"#]+)", css):
        if not asset.startswith(("data:", "http:", "https:", "#")) and not (DOCS / asset).exists():
            errors.append(f"missing CSS asset: {asset}")

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("Multilingual validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Multilingual validation passed: 133 pages, lang/RTL, canonical/hreflang, switching, links, assets, sitemap, CNAME, HTML and CSS.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
