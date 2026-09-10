#!/usr/bin/env python3
from __future__ import annotations

from html import escape
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
BASE = "https://www.itarevo.com"

LOCALES = [
    ("en", "en-GB", "English", "English"),
    ("fr", "fr-FR", "Français", "French"),
    ("es", "es-ES", "Español", "Spanish"),
    ("it", "it-IT", "Italiano", "Italian"),
    ("de", "de-DE", "Deutsch", "German"),
    ("pt", "pt-PT", "Português", "Portuguese"),
    ("ja", "ja-JP", "日本語", "Japanese"),
    ("ar", "ar", "العربية", "Arabic"),
    ("bg", "bg-BG", "Български", "Bulgarian"),
    ("cs", "cs-CZ", "Čeština", "Czech"),
    ("da", "da-DK", "Dansk", "Danish"),
    ("el", "el-GR", "Ελληνικά", "Greek"),
    ("nl", "nl-NL", "Nederlands", "Dutch"),
    ("pl", "pl-PL", "Polski", "Polish"),
    ("ro", "ro-RO", "Română", "Romanian"),
    ("ru", "ru-RU", "Русский", "Russian"),
    ("sv", "sv-SE", "Svenska", "Swedish"),
    ("tr", "tr-TR", "Türkçe", "Turkish"),
    ("zh", "zh-CN", "中文", "Chinese"),
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

ORIGINAL_HTML = {
    page: (DOCS / output).read_text(encoding="utf-8")
    for page, _, output in PAGES
}

COMMON = {
    "en": {
        "nav": ["Travel", "Finance", "About", "Support", "Privacy", "Terms", "Availability"],
        "language": "Language",
        "brand_home": "ITAREVO home",
        "main_nav": "Main navigation",
        "footer": "ITAREVO unites Travel and Finance in one connected product ecosystem.",
        "copyright": "© 2026 ITAREVO LTD. All rights reserved.",
        "contact": "Contact",
        "availability": "Availability in progress",
        "legal_note": "",
    },
    "fr": {
        "nav": ["Voyage", "Finance", "À propos", "Assistance", "Confidentialité", "Conditions", "Disponibilité"],
        "language": "Langue",
        "brand_home": "Accueil ITAREVO",
        "main_nav": "Navigation principale",
        "footer": "ITAREVO réunit Voyage et Finance dans un écosystème produit connecté.",
        "copyright": "© 2026 ITAREVO LTD. Tous droits réservés.",
        "contact": "Contact",
        "availability": "Disponibilité en cours",
        "legal_note": "En cas d’incohérence entre cette traduction et la version anglaise, la version anglaise fait foi.",
    },
    "es": {
        "nav": ["Viajes", "Finanzas", "Acerca de", "Soporte", "Privacidad", "Términos", "Disponibilidad"],
        "language": "Idioma",
        "brand_home": "Inicio de ITAREVO",
        "main_nav": "Navegación principal",
        "footer": "ITAREVO une Viajes y Finanzas en un ecosistema de producto conectado.",
        "copyright": "© 2026 ITAREVO LTD. Todos los derechos reservados.",
        "contact": "Contacto",
        "availability": "Disponibilidad en curso",
        "legal_note": "Si esta traducción difiere de la versión inglesa, prevalece la versión inglesa.",
    },
    "it": {
        "nav": ["Viaggi", "Finanza", "Chi siamo", "Supporto", "Privacy", "Termini", "Disponibilità"],
        "language": "Lingua",
        "brand_home": "Home ITAREVO",
        "main_nav": "Navigazione principale",
        "footer": "ITAREVO unisce Viaggi e Finanza in un ecosistema di prodotto connesso.",
        "copyright": "© 2026 ITAREVO LTD. Tutti i diritti riservati.",
        "contact": "Contatto",
        "availability": "Disponibilità in corso",
        "legal_note": "In caso di incoerenza tra questa traduzione e la versione inglese, prevale la versione inglese.",
    },
    "de": {
        "nav": ["Reisen", "Finanzen", "Über uns", "Support", "Datenschutz", "Bedingungen", "Verfügbarkeit"],
        "language": "Sprache",
        "brand_home": "ITAREVO Startseite",
        "main_nav": "Hauptnavigation",
        "footer": "ITAREVO verbindet Reisen und Finanzen in einem vernetzten Produktökosystem.",
        "copyright": "© 2026 ITAREVO LTD. Alle Rechte vorbehalten.",
        "contact": "Kontakt",
        "availability": "Verfügbarkeit in Vorbereitung",
        "legal_note": "Bei Abweichungen zwischen dieser Übersetzung und der englischen Fassung ist die englische Fassung maßgeblich.",
    },
    "pt": {
        "nav": ["Viagens", "Finanças", "Sobre", "Suporte", "Privacidade", "Termos", "Disponibilidade"],
        "language": "Idioma",
        "brand_home": "Início da ITAREVO",
        "main_nav": "Navegação principal",
        "footer": "A ITAREVO une Viagens e Finanças num ecossistema de produto conectado.",
        "copyright": "© 2026 ITAREVO LTD. Todos os direitos reservados.",
        "contact": "Contacto",
        "availability": "Disponibilidade em curso",
        "legal_note": "Se esta tradução for inconsistente com a versão inglesa, prevalece a versão inglesa.",
    },
    "ja": {
        "nav": ["旅行", "ファイナンス", "概要", "サポート", "プライバシー", "利用規約", "提供状況"],
        "language": "言語",
        "brand_home": "ITAREVO ホーム",
        "main_nav": "メインナビゲーション",
        "footer": "ITAREVO は、旅行とファイナンスを一つの連携した製品エコシステムにまとめます。",
        "copyright": "© 2026 ITAREVO LTD. All rights reserved.",
        "contact": "お問い合わせ",
        "availability": "提供準備中",
        "legal_note": "この翻訳と英語版に相違がある場合は、英語版が優先されます。",
    },
    "ar": {
        "nav": ["السفر", "المالية", "من نحن", "الدعم", "الخصوصية", "الشروط", "التوفر"],
        "language": "اللغة",
        "brand_home": "صفحة ITAREVO الرئيسية",
        "main_nav": "التنقل الرئيسي",
        "footer": "تجمع ITAREVO بين السفر والمالية في منظومة منتجات مترابطة.",
        "copyright": "© 2026 ITAREVO LTD. جميع الحقوق محفوظة.",
        "contact": "اتصال",
        "availability": "التوفر قيد الإعداد",
        "legal_note": "إذا وُجد أي تعارض بين هذه الترجمة والنسخة الإنجليزية، فتكون النسخة الإنجليزية هي المعتمدة.",
    },
    "bg": {
        "nav": ["Пътуване", "Финанси", "За нас", "Поддръжка", "Поверителност", "Условия", "Наличност"],
        "language": "Език",
        "brand_home": "Начало ITAREVO",
        "main_nav": "Основна навигация",
        "footer": "ITAREVO обединява Пътуване и Финанси в една свързана продуктова екосистема.",
        "copyright": "© 2026 ITAREVO LTD. Всички права запазени.",
        "contact": "Контакт",
        "availability": "Наличността е в процес",
        "legal_note": "При несъответствие между този превод и английската версия, английската версия има предимство.",
    },
    "cs": {
        "nav": ["Cestování", "Finance", "O nás", "Podpora", "Soukromí", "Podmínky", "Dostupnost"],
        "language": "Jazyk",
        "brand_home": "Domů ITAREVO",
        "main_nav": "Hlavní navigace",
        "footer": "ITAREVO spojuje Cestování a Finance do jednoho propojeného produktového ekosystému.",
        "copyright": "© 2026 ITAREVO LTD. Všechna práva vyhrazena.",
        "contact": "Kontakt",
        "availability": "Dostupnost se připravuje",
        "legal_note": "V případě rozporu mezi tímto překladem a anglickou verzí má přednost anglická verze.",
    },
    "da": {
        "nav": ["Rejser", "Finans", "Om", "Support", "Privatliv", "Vilkår", "Tilgængelighed"],
        "language": "Sprog",
        "brand_home": "ITAREVO startside",
        "main_nav": "Hovednavigation",
        "footer": "ITAREVO samler Rejser og Finans i ét forbundet produktøkosystem.",
        "copyright": "© 2026 ITAREVO LTD. Alle rettigheder forbeholdes.",
        "contact": "Kontakt",
        "availability": "Tilgængelighed undervejs",
        "legal_note": "Hvis denne oversættelse er uforenelig med den engelske version, er den engelske version gældende.",
    },
    "el": {
        "nav": ["Ταξίδια", "Οικονομικά", "Σχετικά", "Υποστήριξη", "Απόρρητο", "Όροι", "Διαθεσιμότητα"],
        "language": "Γλώσσα",
        "brand_home": "Αρχική ITAREVO",
        "main_nav": "Κύρια πλοήγηση",
        "footer": "Το ITAREVO ενώνει Ταξίδια και Οικονομικά σε ένα συνδεδεμένο οικοσύστημα προϊόντων.",
        "copyright": "© 2026 ITAREVO LTD. Με επιφύλαξη παντός δικαιώματος.",
        "contact": "Επικοινωνία",
        "availability": "Η διαθεσιμότητα ετοιμάζεται",
        "legal_note": "Σε περίπτωση ασυμφωνίας μεταξύ αυτής της μετάφρασης και της αγγλικής έκδοσης, υπερισχύει η αγγλική έκδοση.",
    },
    "nl": {
        "nav": ["Reizen", "Financiën", "Over", "Support", "Privacy", "Voorwaarden", "Beschikbaarheid"],
        "language": "Taal",
        "brand_home": "ITAREVO startpagina",
        "main_nav": "Hoofdnavigatie",
        "footer": "ITAREVO brengt Reizen en Financiën samen in één verbonden productecosysteem.",
        "copyright": "© 2026 ITAREVO LTD. Alle rechten voorbehouden.",
        "contact": "Contact",
        "availability": "Beschikbaarheid in voorbereiding",
        "legal_note": "Als deze vertaling afwijkt van de Engelse versie, is de Engelse versie leidend.",
    },
    "pl": {
        "nav": ["Podróże", "Finanse", "O nas", "Wsparcie", "Prywatność", "Warunki", "Dostępność"],
        "language": "Język",
        "brand_home": "Strona główna ITAREVO",
        "main_nav": "Główna nawigacja",
        "footer": "ITAREVO łączy Podróże i Finanse w jednym połączonym ekosystemie produktów.",
        "copyright": "© 2026 ITAREVO LTD. Wszelkie prawa zastrzeżone.",
        "contact": "Kontakt",
        "availability": "Dostępność w przygotowaniu",
        "legal_note": "W razie niespójności między tym tłumaczeniem a wersją angielską obowiązuje wersja angielska.",
    },
    "ro": {
        "nav": ["Călătorii", "Finanțe", "Despre", "Asistență", "Confidențialitate", "Termeni", "Disponibilitate"],
        "language": "Limbă",
        "brand_home": "Pagina principală ITAREVO",
        "main_nav": "Navigare principală",
        "footer": "ITAREVO unește Călătoriile și Finanțele într-un ecosistem de produse conectat.",
        "copyright": "© 2026 ITAREVO LTD. Toate drepturile rezervate.",
        "contact": "Contact",
        "availability": "Disponibilitate în curs",
        "legal_note": "Dacă această traducere diferă de versiunea în limba engleză, versiunea engleză prevalează.",
    },
    "ru": {
        "nav": ["Путешествия", "Финансы", "О нас", "Поддержка", "Конфиденциальность", "Условия", "Доступность"],
        "language": "Язык",
        "brand_home": "Главная ITAREVO",
        "main_nav": "Основная навигация",
        "footer": "ITAREVO объединяет Путешествия и Финансы в единую связанную экосистему продуктов.",
        "copyright": "© 2026 ITAREVO LTD. Все права защищены.",
        "contact": "Контакты",
        "availability": "Доступность в процессе подготовки",
        "legal_note": "При расхождении между этим переводом и английской версией преимущественную силу имеет английская версия.",
    },
    "sv": {
        "nav": ["Resor", "Ekonomi", "Om", "Support", "Integritet", "Villkor", "Tillgänglighet"],
        "language": "Språk",
        "brand_home": "ITAREVO startsida",
        "main_nav": "Huvudnavigering",
        "footer": "ITAREVO förenar Resor och Ekonomi i ett sammanlänkat produktekosystem.",
        "copyright": "© 2026 ITAREVO LTD. Alla rättigheter förbehållna.",
        "contact": "Kontakt",
        "availability": "Tillgänglighet pågår",
        "legal_note": "Om denna översättning avviker från den engelska versionen gäller den engelska versionen.",
    },
    "tr": {
        "nav": ["Seyahat", "Finans", "Hakkında", "Destek", "Gizlilik", "Şartlar", "Kullanılabilirlik"],
        "language": "Dil",
        "brand_home": "ITAREVO ana sayfa",
        "main_nav": "Ana gezinme",
        "footer": "ITAREVO, Seyahat ve Finansı tek bir bağlı ürün ekosisteminde birleştirir.",
        "copyright": "© 2026 ITAREVO LTD. Tüm hakları saklıdır.",
        "contact": "İletişim",
        "availability": "Kullanılabilirlik hazırlanıyor",
        "legal_note": "Bu çeviri ile İngilizce sürüm arasında tutarsızlık olması halinde İngilizce sürüm geçerlidir.",
    },
    "zh": {
        "nav": ["旅行", "财务", "关于", "支持", "隐私", "条款", "可用性"],
        "language": "语言",
        "brand_home": "ITAREVO 首页",
        "main_nav": "主导航",
        "footer": "ITAREVO 将旅行和财务整合到一个互联的产品生态中。",
        "copyright": "© 2026 ITAREVO LTD. 保留所有权利。",
        "contact": "联系",
        "availability": "可用性正在推进",
        "legal_note": "如本译文与英文版本不一致，以英文版本为准。",
    },
}


def page_url(locale_code: str, slug: str) -> str:
    prefix = "" if locale_code == "en" else f"{locale_code}/"
    return f"{BASE}/{prefix}{slug}"


def selector_path(locale_code: str, slug: str) -> str:
    prefix = "" if locale_code == "en" else f"{locale_code}/"
    return f"/{prefix}{slug}"


def rel_prefix(locale_code: str, slug: str) -> str:
    depth = (0 if slug == "" else 1) + (0 if locale_code == "en" else 1)
    return "./" if depth == 0 else "../" * depth


def local_href(locale_code: str, slug: str) -> str:
    return rel_prefix(locale_code, slug) if slug == "" else f"{rel_prefix(locale_code, slug)}{slug}"


def intra_locale_href(locale_code: str, current_slug: str, target_slug: str) -> str:
    if locale_code == "en":
        prefix = rel_prefix(locale_code, current_slug)
        return prefix if target_slug == "" else f"{prefix}{target_slug}"
    up = "./" if current_slug == "" else "../"
    return up if target_slug == "" else f"{up}{target_slug}"


def language_options(locale_code: str, slug: str) -> str:
    options = []
    for code, lang, native, english in LOCALES:
        href = selector_path(code, slug)
        selected = " selected" if code == locale_code else ""
        options.append(f'<option value="{href}" lang="{lang}"{selected}>{escape(native)}</option>')
    return "\n".join(options)


def hreflang_links(slug: str) -> str:
    links = [f'  <link rel="alternate" hreflang="{lang}" href="{page_url(code, slug)}">' for code, lang, _, _ in LOCALES]
    links.append(f'  <link rel="alternate" hreflang="x-default" href="{page_url("en", slug)}">')
    return "\n".join(links)


def header(locale: str, slug: str, current: str) -> str:
    c = COMMON[locale]
    prefix = rel_prefix(locale, slug)
    nav = c["nav"]
    nav_slugs = ["features/", "finance/", "about/", "support/", "privacy/", "terms/"]
    nav_keys = ["features", "finance", "about", "support", "privacy", "terms"]
    links = []
    for label, nav_slug, key in zip(nav[:6], nav_slugs, nav_keys):
        current_attr = ' aria-current="page"' if current == key else ""
        links.append(f'<a href="{intra_locale_href(locale, slug, nav_slug)}"{current_attr}>{escape(label)}</a>')
    launch = f"{intra_locale_href(locale, slug, '')}#launch"
    links.append(f'<a class="nav-cta" href="{launch}">{escape(nav[6])}</a>')
    selector = (
        f'<label class="language-selector"><span>{escape(c["language"])}</span>'
        f'<select aria-label="{escape(c["language"])}" onchange="if (this.value) window.location.href = this.value">'
        f'{language_options(locale, slug)}</select></label>'
    )
    return (
        f'<header class="site-header">\n'
        f'    <nav class="nav" aria-label="{escape(c["main_nav"])}">\n'
        f'      <a class="brand" href="{intra_locale_href(locale, slug, "")}" aria-label="{escape(c["brand_home"])}"><img class="brand-logo" src="{prefix}assets/itarevo-ecosystem-logo.png" alt="ITAREVO"></a>\n'
        f'      <div class="nav-links">{"".join(links)}{selector}</div>\n'
        f'    </nav>\n'
        f'  </header>'
    )


def footer(locale: str, slug: str) -> str:
    c = COMMON[locale]
    prefix = rel_prefix(locale, slug)
    nav = c["nav"]
    hrefs = ["features/", "finance/", "about/", "support/", "privacy/", "terms/"]
    links = "".join(f'<a href="{intra_locale_href(locale, slug, href)}">{escape(label)}</a>' for label, href in zip(nav[:6], hrefs))
    if slug == "":
        links += f'<a href="mailto:lml@itarevo.com">{escape(c["contact"])}</a>'
    return (
        f'<footer class="site-footer"><div class="site-footer-inner"><div><img class="footer-logo" src="{prefix}assets/itarevo-ecosystem-logo.png" alt="ITAREVO"><p class="footer-note">{escape(c["footer"])}</p></div>'
        f'<div class="footer-links">{links}</div><div class="copyright">{escape(c["copyright"])}</div></div></footer>'
    )


BASE_CONTENT = {
    "home": {
        "title": "ITAREVO | Travel and Finance in one ecosystem",
        "description": "ITAREVO is one connected ecosystem for ITAREVO Travel and ITAREVO Finance: journey planning, travel context and personal finance organisation.",
        "og": "Plan journeys with ITAREVO Travel and organise everyday money context with ITAREVO Finance.",
        "headline": "ITAREVO Travel and ITAREVO Finance, built as one ecosystem.",
        "lead": "Plan the journey, keep the practical details together and understand the money context around it. ITAREVO Travel and ITAREVO Finance are distinct products designed to work naturally within one connected ecosystem.",
    },
    "features": {
        "title": "Features | ITAREVO Travel",
        "description": "Explore the ITAREVO Travel toolkit: trip planning, AI assistance, Live Trip, maps, translator, readiness and expenses.",
        "og": "A connected toolkit for the practical moments of travel.",
        "headline": "A complete toolkit for a more capable journey.",
        "lead": "The travel product inside the ITAREVO ecosystem: one trip-aware place for planning before you leave, navigating while you travel and keeping the details together afterwards.",
    },
    "finance": {
        "title": "ITAREVO Finance | Organise your financial picture",
        "description": "ITAREVO Finance helps you organise accounts, activity, budgets, goals, insights and currency context.",
        "og": "A focused personal-finance workspace for accounts, activity, budgets, goals and insights.",
        "headline": "Organise your financial picture.",
        "lead": "The finance product inside the ITAREVO ecosystem: a focused workspace for understanding the money you manage yourself, from everyday activity to longer-term goals and travel planning.",
    },
    "about": {
        "title": "About ITAREVO | Travel and Finance ecosystem",
        "description": "Learn about ITAREVO, the company building connected Travel and Finance products with clear purpose and practical value.",
        "og": "The thinking behind the ITAREVO Travel and ITAREVO Finance ecosystem.",
        "headline": "One ecosystem for journeys and the money context around them.",
        "lead": "ITAREVO is building connected Travel and Finance products that keep planning, organisation and practical decisions clear.",
    },
    "support": {
        "title": "Support | ITAREVO",
        "description": "Contact ITAREVO support for Travel, Finance, account and planning questions.",
        "og": "Get help with ITAREVO Travel and ITAREVO Finance.",
        "headline": "Support for Travel and Finance.",
        "lead": "For product, account, travel-planning or finance-organisation support, contact the ITAREVO team.",
    },
    "privacy": {
        "title": "Privacy | ITAREVO",
        "description": "Read the ITAREVO Privacy page for Travel and Finance product data.",
        "og": "How ITAREVO approaches privacy for Travel and Finance product data.",
        "headline": "Privacy",
        "lead": "ITAREVO respects your privacy and is committed to protecting the personal information used to provide and improve ITAREVO Travel and ITAREVO Finance.",
    },
    "terms": {
        "title": "Terms of Service | ITAREVO",
        "description": "Read the ITAREVO Terms of Service for Travel and Finance.",
        "og": "The terms for using ITAREVO Travel and ITAREVO Finance.",
        "headline": "Terms of Service",
        "lead": "These Terms of Service describe the basic terms for using ITAREVO Travel and ITAREVO Finance. By using the service, you agree to use it lawfully and responsibly.",
    },
}

LOCALIZED = {
    "fr": {
        "home": ("ITAREVO | Voyage et Finance dans un même écosystème", "ITAREVO est un écosystème connecté pour ITAREVO Travel et ITAREVO Finance.", "ITAREVO Travel et ITAREVO Finance, conçus comme un seul écosystème.", "Planifiez le voyage, gardez les détails pratiques ensemble et comprenez le contexte financier qui l’entoure."),
        "features": ("Fonctionnalités | ITAREVO Travel", "Découvrez la boîte à outils ITAREVO Travel.", "Une boîte à outils complète pour un voyage plus maîtrisé.", "Le produit voyage de l’écosystème ITAREVO réunit planification, navigation et détails pratiques."),
        "finance": ("ITAREVO Finance | Organiser votre vue financière", "ITAREVO Finance aide à organiser comptes, budgets, objectifs, informations et devises.", "Organisez votre vue financière.", "Un espace ciblé pour comprendre l’argent que vous gérez vous-même, du quotidien aux objectifs et aux voyages."),
        "about": ("À propos d’ITAREVO | Écosystème Voyage et Finance", "Découvrez ITAREVO et ses produits connectés.", "Un écosystème pour les voyages et leur contexte financier.", "ITAREVO construit des produits Voyage et Finance connectés pour rendre les décisions pratiques plus claires."),
        "support": ("Assistance | ITAREVO", "Contactez l’assistance ITAREVO.", "Assistance pour Travel et Finance.", "Pour toute question produit, compte, planification de voyage ou organisation financière, contactez l’équipe ITAREVO."),
        "privacy": ("Confidentialité | ITAREVO", "Lisez la page Confidentialité d’ITAREVO.", "Confidentialité", "ITAREVO respecte votre vie privée et s’engage à protéger les informations personnelles utilisées pour fournir et améliorer ses produits."),
        "terms": ("Conditions d’utilisation | ITAREVO", "Lisez les Conditions d’utilisation d’ITAREVO.", "Conditions d’utilisation", "Ces Conditions décrivent les règles de base d’utilisation d’ITAREVO Travel et d’ITAREVO Finance."),
    },
    "es": {
        "home": ("ITAREVO | Viajes y Finanzas en un ecosistema", "ITAREVO es un ecosistema conectado para ITAREVO Travel e ITAREVO Finance.", "ITAREVO Travel e ITAREVO Finance, creados como un solo ecosistema.", "Planifica el viaje, reúne los detalles prácticos y entiende el contexto financiero que lo rodea."),
        "features": ("Funciones | ITAREVO Travel", "Explora la caja de herramientas de ITAREVO Travel.", "Un conjunto completo de herramientas para un viaje más capaz.", "El producto de viajes de ITAREVO reúne planificación, navegación y detalles prácticos."),
        "finance": ("ITAREVO Finance | Organiza tu panorama financiero", "ITAREVO Finance ayuda a organizar cuentas, presupuestos, objetivos, análisis y divisas.", "Organiza tu panorama financiero.", "Un espacio centrado para entender el dinero que gestionas, desde la actividad diaria hasta objetivos y viajes."),
        "about": ("Acerca de ITAREVO | Ecosistema de Viajes y Finanzas", "Conoce ITAREVO y sus productos conectados.", "Un ecosistema para los viajes y el contexto financiero que los rodea.", "ITAREVO crea productos conectados de Viajes y Finanzas para aclarar la organización y las decisiones prácticas."),
        "support": ("Soporte | ITAREVO", "Contacta con el soporte de ITAREVO.", "Soporte para Travel y Finance.", "Para preguntas sobre producto, cuenta, planificación de viajes u organización financiera, contacta con ITAREVO."),
        "privacy": ("Privacidad | ITAREVO", "Lee la página de Privacidad de ITAREVO.", "Privacidad", "ITAREVO respeta tu privacidad y se compromete a proteger la información personal usada para prestar y mejorar sus productos."),
        "terms": ("Términos de servicio | ITAREVO", "Lee los Términos de servicio de ITAREVO.", "Términos de servicio", "Estos Términos describen las reglas básicas para usar ITAREVO Travel e ITAREVO Finance."),
    },
    "ru": {
        "home": ("ITAREVO | Путешествия и финансы в одной экосистеме", "ITAREVO — связанная экосистема для ITAREVO Travel и ITAREVO Finance.", "ITAREVO Travel и ITAREVO Finance в единой экосистеме.", "Планируйте поездку, держите практические детали вместе и понимайте финансовый контекст вокруг нее."),
        "features": ("Возможности | ITAREVO Travel", "Изучите инструменты ITAREVO Travel.", "Полный набор инструментов для более уверенного путешествия.", "Туристический продукт ITAREVO объединяет планирование, навигацию и важные детали поездки."),
        "finance": ("ITAREVO Finance | Организуйте свою финансовую картину", "ITAREVO Finance помогает организовать счета, бюджеты, цели, аналитику и валютный контекст.", "Организуйте свою финансовую картину.", "Фокусированное пространство для понимания денег, которыми вы управляете сами: от ежедневных операций до целей и поездок."),
        "about": ("О ITAREVO | Экосистема путешествий и финансов", "Узнайте об ITAREVO и связанных продуктах.", "Одна экосистема для поездок и финансового контекста вокруг них.", "ITAREVO создает связанные продукты Travel и Finance, чтобы планирование, организация и практические решения были понятнее."),
        "support": ("Поддержка | ITAREVO", "Свяжитесь с поддержкой ITAREVO.", "Поддержка Travel и Finance.", "По вопросам продукта, аккаунта, планирования поездок или финансовой организации свяжитесь с командой ITAREVO."),
        "privacy": ("Конфиденциальность | ITAREVO", "Прочитайте страницу конфиденциальности ITAREVO.", "Конфиденциальность", "ITAREVO уважает вашу конфиденциальность и стремится защищать персональную информацию, используемую для предоставления и улучшения продуктов."),
        "terms": ("Условия обслуживания | ITAREVO", "Прочитайте Условия обслуживания ITAREVO.", "Условия обслуживания", "Эти Условия описывают основные правила использования ITAREVO Travel и ITAREVO Finance."),
    },
    "zh": {
        "home": ("ITAREVO | 旅行与财务在同一生态中", "ITAREVO 是连接 ITAREVO Travel 和 ITAREVO Finance 的产品生态。", "ITAREVO Travel 与 ITAREVO Finance，作为一个生态构建。", "规划旅程，集中管理实用细节，并理解其背后的资金背景。"),
        "features": ("功能 | ITAREVO Travel", "探索 ITAREVO Travel 工具集。", "让旅程更从容的完整工具集。", "ITAREVO 生态中的旅行产品，将出发前规划、旅途中导航和实用细节整合在一起。"),
        "finance": ("ITAREVO Finance | 整理你的财务全貌", "ITAREVO Finance 帮助整理账户、预算、目标、洞察和货币背景。", "整理你的财务全貌。", "一个专注的空间，帮助你理解自己管理的资金，从日常活动到长期目标和旅行计划。"),
        "about": ("关于 ITAREVO | 旅行与财务生态", "了解 ITAREVO 及其互联产品。", "为旅程及其资金背景打造的一个生态。", "ITAREVO 正在打造互联的 Travel 和 Finance 产品，让计划、组织和实际决策更清晰。"),
        "support": ("支持 | ITAREVO", "联系 ITAREVO 支持。", "Travel 和 Finance 支持。", "如有产品、账户、旅行规划或财务整理问题，请联系 ITAREVO 团队。"),
        "privacy": ("隐私 | ITAREVO", "阅读 ITAREVO 隐私页面。", "隐私", "ITAREVO 尊重你的隐私，并致力于保护用于提供和改进产品的个人信息。"),
        "terms": ("服务条款 | ITAREVO", "阅读 ITAREVO 服务条款。", "服务条款", "本服务条款说明使用 ITAREVO Travel 和 ITAREVO Finance 的基本规则。"),
    },
}

FALLBACK_PHRASES = {
    "it": ("ITAREVO | Viaggi e Finanza in un ecosistema", "ITAREVO è un ecosistema connesso per ITAREVO Travel e ITAREVO Finance.", "ITAREVO Travel e ITAREVO Finance, costruiti come un unico ecosistema.", "Pianifica il viaggio, tieni insieme i dettagli pratici e comprendi il contesto finanziario che lo circonda."),
    "de": ("ITAREVO | Reisen und Finanzen in einem Ökosystem", "ITAREVO ist ein verbundenes Ökosystem für ITAREVO Travel und ITAREVO Finance.", "ITAREVO Travel und ITAREVO Finance, als ein Ökosystem aufgebaut.", "Planen Sie die Reise, halten Sie praktische Details zusammen und verstehen Sie den finanziellen Kontext darum herum."),
    "pt": ("ITAREVO | Viagens e Finanças num só ecossistema", "A ITAREVO é um ecossistema conectado para ITAREVO Travel e ITAREVO Finance.", "ITAREVO Travel e ITAREVO Finance, criados como um só ecossistema.", "Planeie a viagem, mantenha os detalhes práticos juntos e compreenda o contexto financeiro à sua volta."),
    "ja": ("ITAREVO | 旅行とファイナンスを一つのエコシステムに", "ITAREVO は ITAREVO Travel と ITAREVO Finance の連携エコシステムです。", "ITAREVO Travel と ITAREVO Finance は一つのエコシステムとして設計されています。", "旅を計画し、実用的な詳細をまとめ、その周りの資金面の文脈を理解できます。"),
    "ar": ("ITAREVO | السفر والمالية في منظومة واحدة", "ITAREVO منظومة مترابطة لـ ITAREVO Travel وITAREVO Finance.", "منظومة واحدة تجمع ITAREVO Travel وITAREVO Finance.", "خطط للرحلة، واجمع التفاصيل العملية، وافهم السياق المالي المحيط بها."),
    "bg": ("ITAREVO | Пътуване и финанси в една екосистема", "ITAREVO е свързана екосистема за ITAREVO Travel и ITAREVO Finance.", "ITAREVO Travel и ITAREVO Finance, изградени като една екосистема.", "Планирайте пътуването, съберете практичните детайли и разберете финансовия контекст около него."),
    "cs": ("ITAREVO | Cestování a finance v jednom ekosystému", "ITAREVO je propojený ekosystém pro ITAREVO Travel a ITAREVO Finance.", "ITAREVO Travel a ITAREVO Finance, vytvořené jako jeden ekosystém.", "Plánujte cestu, mějte praktické detaily pohromadě a chápejte finanční kontext okolo ní."),
    "da": ("ITAREVO | Rejser og finans i ét økosystem", "ITAREVO er et forbundet økosystem for ITAREVO Travel og ITAREVO Finance.", "ITAREVO Travel og ITAREVO Finance, bygget som ét økosystem.", "Planlæg rejsen, hold praktiske detaljer samlet og forstå den økonomiske kontekst omkring den."),
    "el": ("ITAREVO | Ταξίδια και οικονομικά σε ένα οικοσύστημα", "Το ITAREVO είναι ένα συνδεδεμένο οικοσύστημα για ITAREVO Travel και ITAREVO Finance.", "ITAREVO Travel και ITAREVO Finance, σχεδιασμένα ως ένα οικοσύστημα.", "Σχεδιάστε το ταξίδι, κρατήστε μαζί τις πρακτικές λεπτομέρειες και κατανοήστε το οικονομικό πλαίσιο γύρω του."),
    "nl": ("ITAREVO | Reizen en financiën in één ecosysteem", "ITAREVO is een verbonden ecosysteem voor ITAREVO Travel en ITAREVO Finance.", "ITAREVO Travel en ITAREVO Finance, gebouwd als één ecosysteem.", "Plan de reis, houd praktische details bij elkaar en begrijp de financiële context eromheen."),
    "pl": ("ITAREVO | Podróże i finanse w jednym ekosystemie", "ITAREVO to połączony ekosystem dla ITAREVO Travel i ITAREVO Finance.", "ITAREVO Travel i ITAREVO Finance, zbudowane jako jeden ekosystem.", "Planuj podróż, trzymaj praktyczne szczegóły razem i rozumiej kontekst finansowy wokół niej."),
    "ro": ("ITAREVO | Călătorii și finanțe într-un singur ecosistem", "ITAREVO este un ecosistem conectat pentru ITAREVO Travel și ITAREVO Finance.", "ITAREVO Travel și ITAREVO Finance, construite ca un singur ecosistem.", "Planifică călătoria, păstrează detaliile practice împreună și înțelege contextul financiar din jurul ei."),
    "sv": ("ITAREVO | Resor och ekonomi i ett ekosystem", "ITAREVO är ett sammankopplat ekosystem för ITAREVO Travel och ITAREVO Finance.", "ITAREVO Travel och ITAREVO Finance, byggda som ett ekosystem.", "Planera resan, håll praktiska detaljer samlade och förstå den ekonomiska kontexten runt den."),
    "tr": ("ITAREVO | Seyahat ve Finans tek ekosistemde", "ITAREVO, ITAREVO Travel ve ITAREVO Finance için bağlı bir ekosistemdir.", "ITAREVO Travel ve ITAREVO Finance, tek bir ekosistem olarak tasarlandı.", "Yolculuğu planlayın, pratik ayrıntıları bir arada tutun ve çevresindeki finansal bağlamı anlayın."),
}


def localized_content(locale: str, page: str) -> dict[str, str]:
    if locale == "en":
        return BASE_CONTENT[page]
    if locale in LOCALIZED and page in LOCALIZED[locale]:
        title, description, headline, lead = LOCALIZED[locale][page]
    else:
        base_title, base_desc, base_head, base_lead = FALLBACK_PHRASES[locale]
        page_nav = COMMON[locale]["nav"]
        labels = {
            "home": (base_title, base_desc, base_head, base_lead),
            "features": (f"{page_nav[0]} | ITAREVO Travel", base_desc, base_head, base_lead),
            "finance": (f"ITAREVO Finance | {page_nav[1]}", base_desc, base_head, base_lead),
            "about": (f"{page_nav[2]} | ITAREVO", base_desc, base_head, base_lead),
            "support": (f"{page_nav[3]} | ITAREVO", base_desc, base_head, base_lead),
            "privacy": (f"{page_nav[4]} | ITAREVO", base_desc, page_nav[4], base_lead),
            "terms": (f"{page_nav[5]} | ITAREVO", base_desc, page_nav[5], base_lead),
        }
        title, description, headline, lead = labels[page]
    return {"title": title, "description": description, "og": description, "headline": headline, "lead": lead}


def head(locale: str, slug: str, page: str) -> str:
    content = localized_content(locale, page)
    prefix = rel_prefix(locale, slug)
    return f"""<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="{escape(content['description'])}">
  <link rel="canonical" href="{page_url(locale, slug)}">
{hreflang_links(slug)}
  <meta property="og:type" content="website">
  <meta property="og:url" content="{page_url(locale, slug)}">
  <meta property="og:title" content="{escape(content['title'])}">
  <meta property="og:description" content="{escape(content['og'])}">
  <meta property="og:site_name" content="ITAREVO">
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="{escape(content['title'])}">
  <meta name="twitter:description" content="{escape(content['og'])}">
  <link rel="icon" href="{prefix}favicon.svg" type="image/svg+xml">
  <title>{escape(content['title'])}</title>
  <link rel="stylesheet" href="{prefix}site.css">
</head>"""


def panel(title: str, text: str, index: str | None = None) -> str:
    lead = f'<div class="panel-icon">{index}</div>' if index else ""
    return f'<article class="panel">{lead}<h3>{escape(title)}</h3><p>{escape(text)}</p></article>'


def hero_headline(locale: str, page: str, text: str) -> str:
    if locale == "ar" and page == "home":
        return 'منظومة واحدة تجمع <bdi dir="ltr">ITAREVO&nbsp;Travel</bdi><bdi dir="rtl">&nbsp;و&nbsp;</bdi><bdi dir="ltr">ITAREVO&nbsp;Finance</bdi>'
    return escape(text)


def hero_headline_class(locale: str, page: str) -> str:
    if locale == "ar" and page == "home":
        return ' class="arabic-home-headline"'
    return ""


def main_content(locale: str, page: str, slug: str) -> str:
    c = COMMON[locale]
    l = localized_content(locale, page)
    prefix = rel_prefix(locale, slug)
    travel = localized_content(locale, "features")
    finance = localized_content(locale, "finance")
    home = localized_content(locale, "home")
    if page == "home":
        return f"""<main>
    <section class="hero"><div class="container hero-grid"><div><p class="eyebrow">ITAREVO</p><h1{hero_headline_class(locale, page)}>{hero_headline(locale, page, l['headline'])}</h1><p class="lead">{escape(l['lead'])}</p><div class="hero-products" aria-label="ITAREVO"><a class="product-pill product-pill-travel" href="{intra_locale_href(locale, slug, 'features/')}"><span>ITAREVO Travel</span><strong>{escape(travel['lead'])}</strong></a><a class="product-pill product-pill-finance" href="{intra_locale_href(locale, slug, 'finance/')}"><span>ITAREVO Finance</span><strong>{escape(finance['lead'])}</strong></a></div><div class="button-row"><a class="button button-primary" href="{intra_locale_href(locale, slug, 'features/')}">{escape(c['nav'][0])}</a><a class="button button-secondary" href="{intra_locale_href(locale, slug, 'finance/')}">{escape(c['nav'][1])}</a></div><p class="microcopy">{escape(c['availability'])}</p></div><div class="hero-media" aria-label="ITAREVO Travel"><img class="hero-media-image" src="{prefix}assets/itarevo-travel-website-hero.jpg" alt="ITAREVO Travel" width="1536" height="1024"></div></div></section>
    <section class="section" id="overview"><div class="container"><div class="section-heading"><p class="eyebrow">ITAREVO</p><h2>{escape(travel['headline'])}</h2><p class="section-intro">{escape(travel['lead'])}</p></div><div class="grid">{panel(c['nav'][0], travel['lead'], '01')}{panel(c['nav'][1], finance['lead'], '02')}{panel(c['nav'][6], c['availability'], '03')}</div></div></section>
    <section class="section destination-section" id="destinations"><div class="container"><div class="section-heading"><p class="eyebrow">ITAREVO</p><h2>{escape(travel['headline'])}</h2><p class="section-intro">{escape(l['description'])}</p></div>{destination_grid(prefix)}</div></section>
    <section class="section section-tint ecosystem" id="ecosystem"><div class="container"><div class="section-heading"><p class="eyebrow">ITAREVO</p><h2>{escape(l['headline'])}</h2><p class="section-intro">{escape(l['lead'])}</p></div><div class="product-grid"><article class="product-panel product-panel-travel"><div class="product-panel-heading"><img class="product-icon" src="{prefix}assets/itarevo-travel-icon.png" alt=""><span class="product-kicker">ITAREVO Travel</span></div><h3>{escape(travel['headline'])}</h3><p>{escape(travel['lead'])}</p><a class="button button-secondary" href="{intra_locale_href(locale, slug, 'features/')}">{escape(c['nav'][0])}</a></article><article class="product-panel product-panel-finance"><div class="product-panel-heading"><img class="product-icon" src="{prefix}assets/itarevo-finance-icon.png" alt=""><span class="product-kicker">ITAREVO Finance</span></div><h3>{escape(finance['headline'])}</h3><p>{escape(finance['lead'])}</p><a class="button button-secondary" href="{intra_locale_href(locale, slug, 'finance/')}">{escape(c['nav'][1])}</a></article></div></div></section>
    <section class="section section-blue" id="live-trip"><div class="container split"><div class="journey-board"><div class="journey-top"><strong>ITAREVO Travel</strong><span>{escape(c['availability'])}</span></div><div class="timeline"><div class="timeline-item"><span class="timeline-time">01</span><span class="timeline-dot"></span><div class="timeline-content"><strong>{escape(c['nav'][0])}</strong><span>{escape(travel['lead'])}</span></div></div><div class="timeline-item"><span class="timeline-time">02</span><span class="timeline-dot"></span><div class="timeline-content"><strong>{escape(c['nav'][1])}</strong><span>{escape(finance['lead'])}</span></div></div></div></div><div class="split-copy"><p class="eyebrow">ITAREVO</p><h2>{escape(travel['headline'])}</h2><p>{escape(travel['lead'])}</p></div></div></section>
    <section class="section" id="launch"><div class="container callout"><p class="eyebrow">{escape(c['nav'][6])}</p><h2>{escape(c['availability'])}</h2><p>{escape(l['lead'])}</p><div class="button-row"><span class="status-pill">{escape(c['availability'])}</span><a class="button button-secondary" href="mailto:lml@itarevo.com">{escape(c['contact'])}</a></div></div></section>
  </main>"""
    if page in {"features", "finance"}:
        cards = [
            ("01", c["nav"][0], travel["lead"]),
            ("02", c["nav"][1], finance["lead"]),
            ("03", c["nav"][2], home["lead"]),
            ("04", c["nav"][3], localized_content(locale, "support")["lead"]),
            ("05", c["nav"][4], localized_content(locale, "privacy")["lead"]),
            ("06", c["nav"][5], localized_content(locale, "terms")["lead"]),
        ]
        image = "itarevo-travel-website-hero.jpg" if page == "features" else "itarevo-finance-website-hero.jpg"
        other_slug = "finance/" if page == "features" else "features/"
        other_label = c["nav"][1] if page == "features" else c["nav"][0]
        return f"""<main>
    <section class="hero {'finance-hero' if page == 'finance' else ''}"><div class="container hero-grid"><div><p class="eyebrow">ITAREVO {'Finance' if page == 'finance' else 'Travel'}</p><h1>{escape(l['headline'])}</h1><p class="lead">{escape(l['lead'])}</p><div class="button-row"><span class="status-pill">{escape(c['availability'])}</span><a class="button button-secondary" href="{intra_locale_href(locale, slug, other_slug)}">{escape(other_label)}</a></div></div><div class="hero-media"><img class="hero-media-image" src="{prefix}assets/{image}" alt="{escape(l['headline'])}" width="1536" height="1024"></div></div></section>
    <section class="section"><div class="container"><div class="grid">{''.join(panel(t, x, i) for i, t, x in cards)}</div></div></section>
    <section class="section section-tint"><div class="container split"><div class="split-copy"><p class="eyebrow">ITAREVO</p><h2>{escape(l['headline'])}</h2><p>{escape(l['lead'])}</p></div><div class="callout"><h3>{escape(localized_content(locale, 'home')['headline'])}</h3><ul class="check-list"><li>{escape(localized_content(locale, 'features')['lead'])}</li><li>{escape(localized_content(locale, 'finance')['lead'])}</li><li>{escape(c['availability'])}</li></ul></div></div></section>
    <section class="section"><div class="container callout"><p class="eyebrow">{escape(c['nav'][6])}</p><h2>{escape(c['availability'])}</h2><p>{escape(l['description'])}</p><div class="button-row"><span class="status-pill">{escape(c['availability'])}</span><a class="button button-secondary" href="mailto:lml@itarevo.com">{escape(c['contact'])}</a></div></div></section>
  </main>"""
    if page == "about":
        return f"""<main class="container prose"><p class="eyebrow">ITAREVO</p><h1>{escape(l['headline'])}</h1><p class="lead">{escape(l['lead'])}</p><h2>ITAREVO Travel</h2><p>{escape(travel['lead'])}</p><h2>ITAREVO Finance</h2><p>{escape(finance['lead'])}</p><h2>{escape(c['nav'][6])}</h2><p>{escape(c['availability'])}</p><h2>{escape(c['contact'])}</h2><p><a href="mailto:lml@itarevo.com">lml@itarevo.com</a></p></main>"""
    if page == "support":
        return f"""<main class="container prose"><p class="eyebrow">ITAREVO</p><h1>{escape(l['headline'])}</h1><p class="lead">{escape(l['lead'])}</p><p><a class="button button-primary" href="mailto:lml@itarevo.com">lml@itarevo.com</a></p><h2>{escape(c['nav'][3])}</h2><p>{escape(l['description'])}</p><h2>{escape(c['nav'][4])} / {escape(c['nav'][5])}</h2><p><a href="{intra_locale_href(locale, slug, 'privacy/')}">{escape(c['nav'][4])}</a> · <a href="{intra_locale_href(locale, slug, 'terms/')}">{escape(c['nav'][5])}</a></p></main>"""
    if page == "privacy":
        note = f'<p class="legal-note">{escape(c["legal_note"])}</p>' if locale != "en" else ""
        return f"""<main class="container prose"><p class="eyebrow">ITAREVO</p><h1>{escape(l['headline'])}</h1><p class="updated">August 21, 2026</p>{note}<p>{escape(l['lead'])}</p><h2>1. {escape(c['nav'][4])}</h2><p>{escape(l['description'])}</p><h2>2. ITAREVO Travel</h2><p>{escape(travel['lead'])}</p><h2>3. ITAREVO Finance</h2><p>{escape(finance['lead'])}</p><h2>4. {escape(c['contact'])}</h2><p><a href="mailto:lml@itarevo.com">lml@itarevo.com</a></p></main>"""
    note = f'<p class="legal-note">{escape(c["legal_note"])}</p>' if locale != "en" else ""
    return f"""<main class="container prose"><p class="eyebrow">ITAREVO</p><h1>{escape(l['headline'])}</h1><p class="updated">August 21, 2026</p>{note}<p>{escape(l['lead'])}</p><h2>1. ITAREVO</h2><p>{escape(home['lead'])}</p><h2>2. ITAREVO Travel</h2><p>{escape(travel['lead'])}</p><h2>3. ITAREVO Finance</h2><p>{escape(finance['lead'])}</p><h2>4. {escape(c['contact'])}</h2><p><a href="mailto:lml@itarevo.com">lml@itarevo.com</a></p></main>"""


def destination_grid(prefix: str) -> str:
    cities = [
        ("london.jpg", "London"),
        ("paris.jpg", "Paris"),
        ("new-york.jpg", "New York"),
        ("rome.jpg", "Rome"),
        ("madrid.jpg", "Madrid"),
        ("dubai.jpg", "Dubai"),
        ("beijing.jpg", "Beijing"),
        ("tokyo.jpg", "Tokyo"),
        ("destination-istanbul-blue-mosque.png", "Istanbul"),
        ("destination-stockholm.png", "Stockholm"),
        ("destination-sydney.png", "Sydney"),
        ("destination-rio-de-janeiro.png", "Rio de Janeiro"),
    ]
    cards = [
        f'<article class="destination-card"><img src="{prefix}assets/destinations/{file}" alt="{city}" loading="lazy" decoding="async" width="1200" height="800"><div class="destination-card-label">{city}</div></article>'
        for file, city in cities
    ]
    return f'<div class="destination-grid">{"".join(cards)}</div>'


def render(locale: str, lang: str, page: str, slug: str) -> str:
    dir_attr = ' dir="rtl"' if locale == "ar" else ""
    if locale == "en":
        original = ORIGINAL_HTML[page]
        start = original.index("<main")
        end = original.index("</main>") + len("</main>")
        main = original[start:end]
    else:
        main = main_content(locale, page, slug)
    return f"""<!DOCTYPE html>
<html lang="{lang}"{dir_attr}>
{head(locale, slug, page)}
<body>
  {header(locale, slug, page)}
  {main}
  {footer(locale, slug)}
</body>
</html>
"""


def write_locale_pages() -> None:
    for locale, lang, _, _ in LOCALES:
        for page, slug, output in PAGES:
            html = render(locale, lang, page, slug)
            if locale == "en":
                path = DOCS / output
            else:
                path = DOCS / locale / output
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(html, encoding="utf-8")


def write_sitemap() -> None:
    lines = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for locale, _, _, _ in LOCALES:
        for _, slug, _ in PAGES:
            lines.append(f"  <url><loc>{page_url(locale, slug)}</loc></url>")
    lines.append("</urlset>")
    (DOCS / "sitemap.xml").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    write_locale_pages()
    write_sitemap()
    print(f"Generated {len(LOCALES) * len(PAGES)} pages and sitemap.xml")


if __name__ == "__main__":
    main()
