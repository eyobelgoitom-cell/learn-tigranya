# Fidel Learn — UI/UX Guide

**Mandate:** Stunning, premium, user-friendly. Every screen must feel polished and delightful.

---

## Design Pillars

1. **Premium aesthetic** — Refined, not generic. Distinctive character.
2. **User-friendly** — Intuitive, forgiving, obvious next steps.
3. **Cultural respect** — Honor Tigrinya/Amharic heritage in visuals and tone.

---

## Visual System

### Color Palette

- **Primary accent** — Warm, inviting (e.g., amber/gold for learning, culture)
- **Backgrounds** — Light: soft off-white; Dark: deep, comfortable
- **Text** — High contrast, readable; secondary text for hierarchy
- **Success/Error** — Clear, accessible feedback colors

### Typography

- **Fidel (Ge'ez)** — Large, clear. Noto Sans Ethiopic or Abyssinica SIL.
- **Latin** — Clean sans-serif for UI; readable for transliterations.
- **Hierarchy** — Title → Headline → Body → Caption.

### Spacing & Layout

- **8pt grid** — Consistent spacing (8, 16, 24, 32)
- **Generous padding** — Avoid cramped layouts
- **Touch targets** — Minimum 44×44pt for interactive elements

---

## Component Guidelines

### Cards

- Rounded corners (12–16pt)
- Subtle shadow or border for depth
- Clear content hierarchy

### Buttons

- Primary: filled, prominent
- Secondary: outlined or subtle
- Adequate padding, clear label

### Lists & Rows

- Consistent row height
- Clear tap affordance
- Progress indicators where relevant (checkmarks, progress rings)

---

## Micro-Interactions

- **Tap feedback** — Immediate visual response (scale, highlight)
- **Transitions** — Smooth, purposeful (0.2–0.3s)
- **Loading** — Skeleton or spinner; never blank
- **Success** — Brief confirmation (checkmark, haptic)

---

## Accessibility

- VoiceOver labels on all interactive elements
- Dynamic Type support
- Sufficient color contrast (WCAG AA)
- Reduce motion option respected

---

## Screens to Apply

| Screen | Focus |
|--------|-------|
| Home | Welcoming, clear CTAs, streak/goal visibility |
| Lessons | Scannable list, progress at a glance |
| Lesson detail | Large Fidel, uncluttered, play buttons obvious |
| Practice | Engaging cards, clear quiz layout |
| Progress | Celebratory stats, achievement clarity |
| Settings | Clean toggles, logical grouping |

---

## Anti-Patterns to Avoid

- Cluttered layouts
- Tiny touch targets
- Generic "AI slop" aesthetics
- Inconsistent spacing or typography
- Missing loading/error states
