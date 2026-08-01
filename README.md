# commons

Shared atomic widgets and design-system pieces for forkable-derived apps.

## Usage

```dart
import "package:commons/commons.dart";
```

> **Name collisions with material:** `buttons.dart` exports `FilledButton`,
> `IconButton`, `OutlineButton`; `typography.dart` exports `Title` — these shadow
> the material classes. Follow the codebase convention of importing material
> with a prefix (`import "package:flutter/material.dart" as m;`), or use
> `hide FilledButton, IconButton, OutlineButton, Title` on the commons import.

## Content

- `src/widgets/` — atomic widget catalog (buttons, inputs, feedback, typography,
  stat cards, badges, bottom sheet, phone input, section header).
