# commons

Shared atomic widgets and design-system pieces for forkable-derived apps.

## Usage

```dart
import "package:commons/commons.dart";
```

> **Name collisions with material:** widgets that would collide with material
> exports carry an `App` prefix (`AppFilledButton`, `AppIconButton`,
> `AppOutlinedButton`, `AppTitle`). No import aliases or `hide` clauses are
> needed when importing both libraries.

## Content

- `src/widgets/` — atomic widget catalog (buttons, inputs, feedback, typography,
  stat cards, badges, bottom sheet, phone input, section header).
