# Accessibility Standards & Rules

This document defines the accessibility rules used in Campus Buddy.
It serves as a reference for UI development and testing.

---

## General Principles

- Accessibility is treated as a core UI requirement
- Features must remain usable with large text sizes
- Visual clarity is prioritized over compact layouts
- Accessibility should not break navigation or core flows

---

## Text & Typography

- All text must respect system text scaling
- Minimum readable font size: 12sp
- Titles and headings must scale proportionally
- Truncation should be avoided where possible
- Long text should wrap instead of shrinking

---

## Touch Targets

- Minimum touch target size: 48x48 dp
- Buttons must not be too close together
- Icon-only buttons must still meet size requirements
- Tappable areas should include padding, not just icons

---

## Color & Contrast

- Text must be readable on all backgrounds
- Important information must not rely on color alone
- High-contrast theme must be supported
- Color combinations should be color-blind friendly
- Error and success states must be visually distinct

---

## Icons & Semantics

- All icons with meaning must have semantic labels
- Decorative icons do not require labels
- Buttons must expose their purpose to screen readers
- Form fields must have clear labels or hints

---

## Screen Reader Behavior

- Logical reading order must match visual order
- Important UI changes should be announced
- Hidden elements must not be read
- Dialogs must trap focus correctly

---

## Layout & Responsiveness

- Layouts must handle large text without overflow
- Content should scroll instead of clipping
- Fixed-height containers should be avoided
- RTL layouts must not break alignment

---

## Error & Feedback Messages

- Errors must be clearly worded
- Messages must be readable by screen readers
- Error indicators must not rely on color alone
- Feedback should be immediate and clear

---

## Testing Guidelines

- Test with maximum text scaling enabled
- Test with screen reader enabled
- Test high-contrast mode where applicable
- Verify touch targets manually

---

## Phase Notes

- These rules apply to all UI phases
- Existing screens are updated gradually
- Full verification happens in Phase 13