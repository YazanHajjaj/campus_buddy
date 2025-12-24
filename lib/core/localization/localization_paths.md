# Localization Paths & Ownership

This document describes where localization files live,
what each file is responsible for, and who maintains it.

This is reference documentation only.

---

## Folder Structure

lib/core/localization/
├── app_localizations.dart
├── supported_locales.dart
├── localization_keys.dart
├── localization_paths.md
└── translations/
├── en.json
├── tr.json
└── ar.json

---

## File Responsibilities

### app_localizations.dart
- Defines how UI accesses localized text
- Provides the access pattern used by widgets
- Does not contain translation data

Owner: Yazan

---

### supported_locales.dart
- Lists all supported languages
- Defines default locale order

Owner: Yazan

---

### localization_keys.dart
- Single source of truth for all localization keys
- Keys are grouped by feature
- Keys must not be duplicated or removed casually

Owner: Yazan  
Used by: All UI code

---

### translations/en.json
- English source-of-truth text
- Used as base for all translations

Owner: Yazan (initial), Mahmoud (review)

---

### translations/tr.json
- Turkish translations
- Filled after keys and English text are stable

Owner: Mahmoud  
Reviewed by: Nour

---

### translations/ar.json
- Arabic translations (optional / future)
- RTL support depends on UI readiness

Owner: Mahmoud  
Reviewed by: Nour

---

## Workflow Rules

- UI must reference keys from localization_keys.dart
- No hardcoded user-facing strings in new code
- Existing hardcoded strings are migrated later
- Translations are updated only after keys are finalized

---

## Change Policy

- Adding a new key requires:
    - Entry in localization_keys.dart
    - English text in en.json
- Renaming or removing keys should be avoided
- Translation changes do not require UI changes

---

## Phase Notes

- Phase 12 defines structure only
- Real localization loading is implemented later
- Full UI migration happens during testing & polish