# Plan (deferred): tactile "hardware" theme for forkable-derived apps

Status: DEFERRED. Not scheduled. Captured 2026-10-31 so it can be picked up later.
Origin: librosa-service (audio-practice app) restyled its piano, gamification HUD, result screen and guitar chord diagram to a skeuomorphic hardware look. That work lives on branch `feature/lottie-theme-upgrade` in `rubenkaksh/audio-processor` (spec: `docs/design/lottie-theme-spec.md` there). This plan is about taking the result from "one app" to "default look for any new forkable app" and about closing the gap to the reference.

## Reference look
A LottieFiles marketing email showed a 3D-rendered device: dark soft-matte casing with a speaker grille, chunky rounded keys with amber/blue glowing presses and light bloom, round knobs and buttons, a 3x3 rounded pad grid with one lime-lit pad, dark teal/charcoal panels with a mint-teal accent, tiny mono captions, white surround. The image is third-party material and is deliberately not committed here; describe, don't copy.

It is tactile hardware with glowing accents, not neon cyberpunk. Confirm the intended direction before starting.

## Where we are
The librosa-service version is a Flutter approximation: gradients, layered shadows, glows and CustomPainter. It matches palette and mood, but reads as a flat UI that has been lit, not as a physical object. Exact match needs richer surfaces and a screenshot feedback loop.

## Goal
1. A `commons` theme layer any forked app gets by default: tokens, hardware primitives, themed components.
2. A closer match to the reference, in three tiers that can be taken separately.

## Work, cheapest first

### Tier 0: extract to commons (prerequisite)
- Move the `Hw` token class, mono text styles, light/dark ColorSchemes and component themes from librosa-service `frontend/lib/theme/app_theme.dart` into `commons/lib/src/theme/`.
- Move the primitives (`HardwareCasing`, `HardwareScreen`, `SpeakerGrille`, `LitPad`, `LedDot`; librosa-service `frontend/lib/theme/hardware.dart`) into `commons/lib/src/widgets/`, using the `App` prefix rule where names could collide with Material.
- Keep app-specific pieces (piano keyboard painter, chord diagram renderer, HUD content) in the app. Only generic pieces go to commons.
- Export from `commons.dart`; add widget tests and one golden per primitive.
- Check: a throwaway app that depends on commons renders a casing, a lit pad and a LED, light and dark, with `flutter analyze` clean.

### Tier 1: push Flutter painting further (about 90% of the look)
- Inner and outer shadow stacks, specular edge highlights, noise-grain overlay on the casing, a real perforated-grille pattern, bevelled key caps, domed knob gradients.
- Opus writes the art direction and critiques screenshots against the reference; Sonnet implements per a written spec; Haiku or a controller does builds and screenshots.
- Keep it asset-free so bundle size and forkability are unaffected.

### Tier 2: rendered assets for the hardware parts (closest to reference)
- Blender is available through MCP. Render casing, knob, key cap and pad parts to PNG/WebP with transparent backgrounds, light and dark variants.
- Flutter draws those as 9-slice or fixed-size images with live glows and states layered on top.
- Cost: bundle size, per-variant work, and a pipeline for regenerating assets. Decide whether the assets belong in commons or in each app.

### Tier 3: authored motion
- Key press, pad pulse and knob turn as Lottie or Rive animations (`lottie` Flutter package). Reduced-motion fallback required.

## Blocker: visual feedback loop
Matching a reference needs a build, screenshot, compare, adjust loop. During the librosa-service work the Claude in Chrome extension was not connected, so nothing was verified in a browser except by the user's own eyes. Connect the extension (or another screenshot path) before starting Tier 1 or above.

## Constraints to carry over
- Reduced motion: no confetti, no pad travel, no looping glow.
- Contrast and tap targets; layouts must hold at 390px and 1280px.
- Behavior stays unchanged by a theme change; themes are visual only.
- The pressed-key lesson: paint glows in layers (white-key glows under black keys), never in one pass above everything.

## Open questions
- Is the intended look hardware (as built) or neon cyberpunk?
- Tier 2: do rendered assets belong in commons, or per app?
- Light mode: should the surround be flat off-white as in the reference, or follow the app?
