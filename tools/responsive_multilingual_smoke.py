#!/usr/bin/env python3
from __future__ import annotations

from html.parser import HTMLParser
from pathlib import Path
from urllib.request import urlopen
import sys


DOCS = Path(__file__).resolve().parents[1] / "docs"
BASE = "http://127.0.0.1:8765"
CHECKS = [
    ("en", "en-GB", ""),
    ("ru", "ru-RU", "ru/"),
    ("zh", "zh-CN", "zh/"),
    ("ar", "ar", "ar/"),
]
PAGES = ["", "features/", "finance/", "about/", "support/", "privacy/", "terms/"]
VIEWPORTS = {
    "desktop": 1280,
    "iphone": 390,
    "ipad": 820,
}


class SmokeParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.html_attrs = {}
        self.has_selector = False
        self.option_count = 0
        self.nav_labels = []
        self.in_nav = False
        self.in_select = False
        self.has_hero = False
        self.has_footer = False

    def handle_starttag(self, tag, attrs):
        data = dict(attrs)
        if tag == "html":
            self.html_attrs = data
        classes = data.get("class", "")
        if tag == "nav" and "nav" in classes:
            self.in_nav = True
        if tag == "label" and "language-selector" in classes:
            self.has_selector = True
        if tag == "select":
            self.in_select = True
        if tag == "option" and self.in_select:
            self.option_count += 1
        if "hero" in classes:
            self.has_hero = True
        if tag == "footer" and "site-footer" in classes:
            self.has_footer = True

    def handle_endtag(self, tag):
        if tag == "nav":
            self.in_nav = False
        if tag == "select":
            self.in_select = False

    def handle_data(self, data):
        text = " ".join(data.split())
        if text and self.in_nav and not self.in_select:
            self.nav_labels.append(text)


def local_path(prefix: str, page: str) -> Path:
    if prefix:
        return DOCS / prefix / page / "index.html" if page else DOCS / prefix / "index.html"
    return DOCS / page / "index.html" if page else DOCS / "index.html"


def main() -> int:
    errors = []
    css = (DOCS / "site.css").read_text(encoding="utf-8")
    for width_name, width in VIEWPORTS.items():
        if width <= 620 and "@media (max-width: 620px)" not in css:
            errors.append("missing iPhone media query")
        if width <= 860 and "@media (max-width: 860px)" not in css:
            errors.append("missing tablet media query")
    if ".language-selector" not in css:
        errors.append("missing language selector CSS")
    if "order: -1" not in css:
        errors.append("mobile language selector is not ordered first")

    for locale, lang, prefix in CHECKS:
        for page in PAGES:
            url = f"{BASE}/{prefix}{page}"
            try:
                with urlopen(url, timeout=4) as response:
                    html = response.read().decode("utf-8")
                    if response.status != 200:
                        errors.append(f"{url} returned {response.status}")
            except Exception as exc:
                errors.append(f"{url} unavailable: {exc}")
                html = local_path(prefix.strip("/"), page).read_text(encoding="utf-8")
            parser = SmokeParser()
            parser.feed(html)
            if parser.html_attrs.get("lang") != lang:
                errors.append(f"{url} wrong lang")
            if locale == "ar" and parser.html_attrs.get("dir") != "rtl":
                errors.append(f"{url} missing RTL")
            if not parser.has_selector or parser.option_count != 19:
                errors.append(f"{url} language selector incomplete")
            if not parser.has_footer:
                errors.append(f"{url} missing footer")
            if page in {"", "features/", "finance/"} and not parser.has_hero:
                errors.append(f"{url} missing hero layout")
            for width_name, width in VIEWPORTS.items():
                longest = max((len(label) for label in parser.nav_labels), default=0)
                if width <= 390 and longest > 28:
                    errors.append(f"{url} has oversized mobile nav label for {width_name}")

    if errors:
        print("Responsive multilingual smoke failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Responsive multilingual smoke passed: en/ru/zh/ar across desktop, iPhone-width and iPad-width structural/local checks.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
