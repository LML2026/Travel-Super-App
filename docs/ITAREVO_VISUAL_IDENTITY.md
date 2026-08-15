# ITAREVO Visual Identity & Luxury Experience Blueprint

## Purpose and Status

This is the authoritative visual specification for ITAREVO. It defines how the product should feel and how future interface work should be judged. It is a design-definition document, not an implementation plan. It does not authorize changes to product data, routing, Maps, storage, backend systems, or intelligence claims.

ITAREVO is a travel companion with the composure of a private concierge and the clarity of a well-made travel journal. Its identity is not created by ornament. It is created by proportion, hierarchy, material restraint, and precise context.

## Approved Visual Direction

The approved direction is a predominantly light, Warm Ivory experience. ITAREVO Ink is used selectively for authority and orientation; Mineral Ocean expresses movement and interaction; Jade marks real readiness or completion. Champagne is rare, reserved for luxury and craft, while Terracotta is used sparingly for place and warmth when the context earns it.

Editorial destination photography is paired with elegant editorial typography and precise operational typography. Surfaces remain restrained. The Journey Line is a major connective visual signature, and the Companion Surface is ITAREVO's quiet intelligent presence. The result is premium but not ostentatious, international and pan-script, with light and dark modes expressed as one identity.

The approved visual reference is a **directional reference**, not a pixel-perfect implementation specification. Future screens should inherit its visual principles rather than copy mockups blindly.

## 1. Design Philosophy

### Manifesto

Luxury in ITAREVO means that the traveller never has to fight the interface for what matters. Information arrives in a considered order; materials feel calm; details reward attention without demanding it. The product should make a trip feel more deliberate, not more complicated.

Restraint means using fewer visual gestures with greater purpose. A warm accent marks something valuable, not every call to action. A surface exists when it clarifies a task, not to decorate an empty area. Motion has a narrative reason. Empty space is active composition, not a lack of content.

Intelligence is expressed as relevant context, clear sequencing, and honest uncertainty. It appears as a quiet observation when supported by real data. It never performs certainty, urgency, personalization, or agency it does not possess.

**Intelligence defines what ITAREVO does. The companion relationship defines how ITAREVO behaves. The visual identity defines how ITAREVO feels.** Premium visual design must support product intelligence, never substitute for it.

A traveller should feel oriented, capable, anticipated, and looked after. Functional travel information and aspiration coexist through editorial ordering: a destination may inspire first, while time, location, status, and action remain immediately legible when the journey is underway.

ITAREVO must never become a generic dashboard, a booking portal, a decorative luxury parody, or an attention-seeking AI product.

### Permanent Principles

1. **Composure before novelty.** Choose the most calm, legible expression that still feels distinct.
2. **Context earns prominence.** The next relevant journey detail outranks generic navigation and decoration.
3. **Editorial emotion, operational precision.** Destinations and memories may be atmospheric; itinerary time, status, and actions must be exact.
4. **Material honesty.** Borders, depth, color, and motion communicate structure or state. They are not surface effects.
5. **Warmth without performance.** The product is considerate and concise, never chatty or anthropomorphic.
6. **International by default.** Every hierarchy, spacing choice, icon, number, and image treatment must work across supported scripts and RTL layouts.
7. **Signals, not spectacle.** Attention states are bounded, explainable, and proportionate to real conditions.
8. **Recognition through continuity.** The journey line, companion surface, destination treatment, and status language should connect the experience more strongly than a logo alone.

## 2. Final Colour World

The existing Deep Ink, Ocean, Jade, warm accent, soft neutral, and semantic-token foundation remains the correct direction. It should be refined into the following official roles. Values are design targets; future token changes require contrast and device testing.

| Role | Suggested HEX | Emotional purpose | Light-theme use | Dark-theme equivalent | Never use for |
| --- | --- | --- | --- | --- | --- |
| **ITAREVO Ink** | `#14243A` | Authority, orientation, architecture | Primary text, navigation, major headers, restrained iconography | `#DCE7F2` on deep surfaces | Large decorative fields or every card background |
| **Porcelain** | `#F7F6F2` | Light, calm, hospitality | Base canvas and large page fields | `#111A27` base canvas | High-contrast critical text |
| **Warm Ivory** | `#EEEAE2` | Tactile softness, separation | Alternate bands and quiet cards | `#1A2635` elevated surfaces | Alert states or prominent controls |
| **Mineral Ocean** | `#167E9B` | Movement, confidence, interaction | Primary interactive accent, selected route/controls | `#4CB8D1` | Decorative gradients, generic links, or dense text blocks |
| **Jade** | `#27866E` | Completion, readiness, healthy status | Positive state and confirmed booking signals | `#55B69B` | Primary brand color or non-status decoration |
| **Champagne** | `#B89458` | Rarity, occasion, craft | Sparing highlights, premium milestones, selected editorial details | `#D6B778` | Default buttons, body copy, or broad backgrounds |
| **Terracotta** | `#B8614C` | Place, warmth, sunset only when context warrants it | Small destination/memory accents | `#D98570` | Error, destructive actions, or a second primary accent |
| **Stone** | `#6E7580` | Quiet support and metadata | Supporting labels, borders, disabled states | `#A7B0BC` | Primary text or strong interactive states |
| **Warning Amber** | `#A96F16` | Bounded attention | Deterministic review-needed states | `#E1AA4A` | Fake urgency or decoration |
| **Error Red** | `#B43B45` | Destructive or failed actions | Errors and destructive controls only | `#F0777B` | General emphasis or standard attention states |

### Palette Proportions

- Sophisticated neutrals: 70–80% of the visual field.
- Ink and ocean family: 15–20%, concentrated in typography, interaction, navigation, and route context.
- Jade, champagne, terracotta, amber, and red: small, earned signals only.

### Current Foundation Assessment

- **Deep Ink / navy:** remain; refine toward a quieter architectural blue rather than near-black.
- **Ocean interactive accent:** remain; keep it mineral and precise rather than electric.
- **Jade positive state:** remain; reserve it for actual success, readiness, and confirmed state.
- **Warm accent:** refine into rare Champagne and optional Terracotta roles; never spread it across ordinary controls.
- **Soft light neutrals:** remain; introduce subtle Porcelain/Warm Ivory separation instead of gray card accumulation.
- **Semantic tokens, spacing, radius, elevation:** remain as the implementation foundation. New raw colors must not bypass semantic roles.

## 3. Typography Personality

ITAREVO typography balances **editorial emotion** with **operational precision**. It should feel considered in a destination title and decisive in a departure time.

### Hierarchy

| Use | Personality | Treatment |
| --- | --- | --- |
| Destination and hero | Editorial, spacious, place-specific | Distinct display scale, measured line length, restrained weight; never compress or over-track |
| Page titles | Architectural and calm | Clear title hierarchy with stable rhythm and strong contrast |
| Operational itinerary | Precise and scanable | Time and title lead; location/status/cost follow in compact structure |
| Numerical and time data | Deliberate and tabular where practical | Stable figures, clear alignment, no decorative glyph substitution |
| Labels | Quiet utility | Smaller, high contrast, sentence case where appropriate |
| Supporting copy | Warm but brief | Comfortable reading measure, no dense gray microcopy |
| Companion messages | Human, concise, evidence-based | One thought at a time; never chatbot-like |

Example contrast:

> Firenze
> 12–17 September

is editorial and inviting. By contrast:

> 10:30
> Uffizi Gallery
> 18 min

is operational, immediate, and unambiguous.

### International Script Requirement

A future font choice must support Latin, Cyrillic, Arabic, Persian, Chinese, Japanese, Korean, Hindi, Georgian, and Armenian with strong native rendering. Do not introduce a Latin-only display font as a global default.

Future candidates are candidates only and require script, fallback, weight, numeral, RTL, truncation, and low-end-device rendering tests:

- A broad sans family with pan-script coverage for UI and operations.
- A restrained editorial companion only when it has an acceptable fallback strategy and is limited to non-critical Latin display contexts.
- Native system/CJK/Arabic fallbacks must remain intentional rather than accidental.

## 4. Signature ITAREVO Visual Elements

### The Journey Line

- **Purpose:** a refined thread that makes a trip feel continuous across itinerary, maps, daily progress, and memories.
- **Appearance:** a thin Ink/Stone line with an Ocean active segment; key stops use small precise markers, not oversized pins.
- **Interaction:** it responds to selection and progress, never competes with stop content.
- **Where:** itinerary connectors, map routes, day summaries, and eventual memories chronology.
- **Uniquely ITAREVO:** the same visual grammar links planning and lived travel rather than treating each screen as a separate tool.
- **Guardrail:** do not turn it into a decorative timeline, animated path, or progress bar without real journey context.

### The Companion Surface

- **Purpose:** a reserved region for concise, supported context.
- **Appearance:** an inset operational surface with a calm heading, one useful detail, and an optional existing action. Its final form must develop a subtle, recognizably ITAREVO-specific signature related to the Journey Line through restrained line continuity, edge treatment, spatial alignment, marker language, or typography relationship.
- **Interaction:** it can be opened, reviewed, or dismissed only when those behaviors are real; it never starts a fake conversation.
- **Where:** Home, Trip Overview, itinerary, map, and day completion.
- **Uniquely ITAREVO:** it feels like a considered margin note from an attentive travel companion.
- **Guardrail:** it must not become a generic information card, chatbot bubble, AI sparkle panel, avatar surface, decorative gimmick, simulated typing treatment, or constant interruption. The final component implementation remains intentionally undefined here.

### Destination Hero

- **Purpose:** make the place, not the app chrome, the first emotional signal.
- **Appearance:** destination-specific editorial image or atmosphere, restrained overlay, title, dates, and one relevant journey state.
- **Interaction:** transitions into trip context; imagery does not conceal primary actions.
- **Where:** Trip Overview and selected Home trip state.
- **Uniquely ITAREVO:** combines hospitality-level visual confidence with explicit trip data.
- **Guardrail:** no generic full-page banner, dark unreadable crop, or marketing copy block.

### Journey Moment

- **Purpose:** a compact unit for what is current, next, or just completed.
- **Appearance:** time/status marker, title, supporting location or route detail, and one clear action.
- **Interaction:** opens the existing relevant detail rather than a generic activity feed.
- **Where:** Home, itinerary, map floating information, and trip overview.
- **Uniquely ITAREVO:** operational data feels like part of a personal journey rather than a task list.
- **Guardrail:** do not fabricate current state, live ETA, reservation status, or recommendations.

### Travel Status and Attention Language

- **Purpose:** distinguish ready, review-needed, and destructive/failure conditions without anxiety.
- **Appearance:** Jade for real positive confirmation; Amber for deterministic attention; Red only for destructive/failure state. Pair every color with icon and text.
- **Interaction:** attention links only to an existing resolution path.
- **Where:** itinerary, map, booking-related surfaces, and companion context.
- **Guardrail:** no red alert card for incomplete optional data and no generic “urgent” wording.

## 5. Companion Visual Identity

The companion is calm, observant, concise, warm, and reassuring. It is a visual posture, not a character.

| Mode | Visual treatment | Appropriate use |
| --- | --- | --- |
| Silent | No standalone surface; only the consistent journey line and ordered interface | Most screens and routine planning |
| Helpful | Small companion surface with one fact and one existing action | Missing map details, an existing review state, or a directly actionable journey fact |
| Proactive | A restrained priority surface, still evidence-based | Only when real system data supports a meaningful action |

### Journey Phases

- **Preparing:** surface confirmed plans, incomplete details, and upcoming structure only when current data supports them.
- **Travelling today:** emphasize the next real itinerary moment, route data already loaded, and explicit attention state.
- **Needs attention:** explain the deterministic condition, use Amber rather than alarm, and offer only an existing action.
- **Day complete:** present calm closure using actual completed-state data when that capability exists; otherwise do not imply completion.
- **Journey over:** foreground memories and reflection only if stored content supports it.

The companion must not claim awareness, monitor the traveller, use first-person emotional performance, or suggest hidden background intelligence.

## 6. Imagery Direction

Photography should be editorial, architectural, naturally lit, destination-specific, culturally respectful, and clear enough to preserve interface usability. It should look observed, not staged.

### Image Roles

| Surface | Image role |
| --- | --- |
| Home | A selected trip’s place and mood, used sparingly behind current journey context |
| Trip Overview | Primary destination hero with real geographic or cultural specificity |
| Destination hero | High-quality establishing view, architecture, landscape, or authentic urban texture |
| Memories | Personal trip chronology; prioritize user-owned imagery where available |
| Empty states | Use a small purposeful destination/object image only when it helps create desire or orientation |
| Onboarding | A limited narrative sequence about travel preparation, never a stock-photo carousel |

### Art Direction Rules

- Crop to reveal the destination, object, or experience, not abstract blur.
- Maintain readable foreground contrast with a restrained Ink overlay only when necessary.
- Use square or lightly rounded media according to content; do not apply exaggerated rounded corners.
- Avoid oversaturated tourism stock, airplane-wing clichés, staged smiling tourists, and imagery that is merely decorative.
- Do not use photography where operations require immediate dense scanning, where image quality is inadequate, or where it would conceal a meaningful state.

## 7. Iconography

Use a coherent, precise outlined icon vocabulary with consistent optical weight. Filled icons are reserved for selected navigation, confirmed status, or one meaningful active state.

- Prefer direct, familiar symbols over custom drawings.
- Pair icons with text for actions where meaning is not universally obvious.
- Use compact icon containers only for an actual category or status; never create decorative badge collections.
- Keep semantic meaning stable: the same icon should not mean route, save, and attention in different contexts.
- Active state should use Ocean or Ink emphasis, not a new icon style.

## 8. Surfaces, Cards, and Materials

| Surface | Use | Radius / border / elevation | Tone and spacing |
| --- | --- | --- | --- |
| Base canvas | Page background | No card treatment | Porcelain or dark base; generous structural bands |
| Operational surface | Dense useful content | Small to medium radius, quiet border, near-flat elevation | Warm Ivory/light elevated dark surface; consistent internal spacing |
| Journey card | One journey moment or destination summary | Medium radius, subtle separation | Content-led, not decorative |
| Floating control | Map or contextual action | Compact radius, clear shadow only above map/media | High-contrast and minimal |
| Companion surface | Supported context | Medium radius, subtle semantic accent | Short content with clear action boundary |
| Attention surface | Deterministic review-needed data | Medium radius, Amber-adjacent detail rather than red field | One condition, one action when available |
| Modal/dialog | Decision or review | Medium radius, focused elevation | No nested cards; succinct decision hierarchy |

Cards should not contain cards. Full-width page bands, typographic grouping, dividers, and whitespace should handle most structural separation. Do not place simple headings, long-form reading, large map canvases, or every list section inside a card.

## 9. Motion Language

Future motion should make continuity, reordering, and context change comprehensible.

- **Duration:** short for direct feedback; measured for page or journey transitions. Avoid theatrical delays.
- **Easing:** confident deceleration and stable arrival; no elastic novelty.
- **Signature moments:** journey line progress, itinerary reorder settling into a new order, companion context entering after a real state change, route emphasis shifting to selected stop, and a trip transition moving from place image into operations.
- **Reduced motion:** every non-essential movement must respect platform reduced-motion settings; use immediate state changes or soft fades.
- **Never animate:** destructive confirmation, critical error text, repetitive loading decoration, data that is not actually updating, or every icon on screen.

## 10. Map Visual Identity

Google Maps functionality remains unchanged. Future visual work should make the map feel integrated with ITAREVO through presentation, not by changing coordinate or route logic.

- Markers should use an Ink base, Ocean selected state, Jade confirmed/ready state where true, and a single selected-stop treatment.
- Journey routes use the Journey Line grammar: quiet unselected segments and a clear selected segment.
- Day differentiation may use restrained tonal variants, never a rainbow route system.
- Floating information is a compact operational surface tied to a selected stop.
- Keep controls minimal, accessible, and familiar; map interaction remains primary.
- Companion/map relationships show only existing contextual facts and actions.

## 11. Light and Dark Experience

Light and dark are two expressions of one identity, not inversions.

### Light

Porcelain canvas, Warm Ivory operational surfaces, Ink typography, and rare Ocean/Jade/Champagne signals create a calm hospitality feel.

### Dark

Use deep blue-black base surfaces with layered blue-slate elevations rather than pure black. Text becomes pale blue-white, Ocean brightens slightly for interaction, and Champagne softens rather than glows. Imagery needs controlled overlays that preserve both subject visibility and text contrast. Maps should use matching floating surface treatments without obscuring map detail.

Warnings retain semantic distinction in both themes. Error remains reserved for actual destructive/failure state. Companion surfaces must remain quiet and legible, not luminous glass panels.

## 12. Home Evolution

Home should eventually become a living travel companion surface, not a feature dashboard. This is visual/product vision only; it does not imply new data sources or backend capabilities.

| Journey context | Visual hierarchy | Currently available boundary |
| --- | --- | --- |
| Before trip | Destination, dates, planning progress, clear trip entry | Existing trip and itinerary data only |
| During trip | Current/next real journey moment, journey line, concise companion context | Only where current itinerary/status data exists |
| Today | Operational time, next stop, location/route data already loaded | Do not imply live location or traffic |
| Between activities | Quiet destination atmosphere with next actionable detail | No fabricated recommendations |
| After trip | Memories, completion, reflection | Only when actual memory/completion data exists |

Visual vision may guide hierarchy, imagery, and interaction framing. It must remain separate from functionality currently available: no assumed real-time awareness, reservation feeds, weather, disruption data, or personalized recommendations.

## 13. Prestige Review Checklist

Use this checklist for every new or changed screen:

1. Is the visual hierarchy understandable in one glance?
2. Does the primary action have a clear, proportionate place?
3. Is each color carrying semantic or compositional meaning?
4. Could a surface be removed in favor of spacing, type, or a divider?
5. Is the page quiet enough for travel-time use?
6. Is luxury expressed through proportion and material restraint rather than gold, gloss, or size?
7. Does the place/trip feel specific rather than generic?
8. Are time, location, status, and action immediately readable where operationally needed?
9. Is companion context supported by actual data and stated without exaggeration?
10. Do images reveal something real and remain usable beneath text?
11. Do icon, radius, elevation, and spacing choices match the system?
12. Does the layout work with long German/French labels, CJK text, Arabic/Persian RTL, Georgian, Armenian, and mixed-direction user data?
13. Are semantics, contrast, focus, touch targets, and reduced motion addressed?
14. Could this screen plausibly belong to a generic app? If so, what journey-specific element makes it ITAREVO?
15. Is anything loud only because it lacks a stronger hierarchy?

## 14. Anti-Patterns

Future design and agent work must not:

- Add random gradients, neon accents, or arbitrary new colors.
- Use black-and-gold as shorthand for luxury.
- Turn every section into a floating rounded card or nest cards inside cards.
- Add oversized hero banners that hide the actual workflow.
- Use excessive pills, chips, badges, or icon containers.
- Introduce generic AI sparkles, chatbot bubbles, avatars, simulated typing, or fake intelligence.
- Make weather, traffic, live-location, reservation, recommendation, or disruption claims without real supporting capability.
- Mix icon families, stroke weights, or inconsistent filled/outlined states.
- Treat dark mode as color inversion.
- Use animation as decoration, loading theater, or a substitute for information architecture.
- Sacrifice readability, localization, RTL behavior, touch targets, or keyboard access for visual novelty.
- Use photography as a dark atmospheric backdrop when the traveller needs to inspect content.
- Add faux premium copy, vague superlatives, or urgency language without a factual basis.
- Bypass semantic tokens, component patterns, or the existing spacing/radius/elevation system.

## 15. Screen Examples

### Auth

A composed arrival surface: minimal identity, calm trust cues, generous whitespace, and a focused sign-in path. It feels private and secure, never like a fintech acquisition funnel.

### Home

A current-journey composition led by destination and real trip context. The Journey Moment and Companion Surface make the first useful action obvious without turning Home into a dashboard grid.

### Trips

An editorial collection of destinations and travel periods with consistent visual rhythm. Trips read as considered journeys, not booking records; density remains practical for comparison.

### Trip Overview

A destination hero establishes place, then transitions into a precise overview of dates, journey structure, cost, status, and entry points. The Journey Line can connect overview to itinerary and map.

### Itinerary

Time and title lead. Location, category, booking, cost, notes, and transfer details support the next decision. Connectors describe only real route data. Attention states are restrained and evidence-based.

### Translator

A quiet utility surface with strong source/target language hierarchy, legible text entry, and an outcome-first result area. It should feel like a refined travel tool, not an experimental AI chat.

### Map

A calm geographic canvas with ITAREVO marker and journey-line language, minimal floating controls, and a selected-stop surface. Google Maps remains the functional map engine; the visual layer adds continuity with the trip.

## Governance

This blueprint should be reviewed before new visual systems, large screen redesigns, imagery pipelines, font packages, or new companion behavior are introduced. Implementation work must preserve existing functionality, make capability claims honestly, and validate international accessibility before visual polish is considered complete.
