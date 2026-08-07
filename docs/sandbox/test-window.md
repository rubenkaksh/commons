# L3 Test Window — commons

- **Grant**: `.opencode/opencode.json` (all 14 tools allow, NO `external_directory` key — the global deny-list stays authoritative).
- **Status**: TRANSITION grant (user decision 2026-08-07, C.2). commons is a path-dependency of khelam; migration into `sandbox/workspaces/commons` deferred (would require rebasing path deps across consumers).
- **revoke_at**: `2026-08-21`
- **Purpose**: keep the shared package usable during the sandbox transition.
- **Auto-flag**: the weekly review checks `revoke_at` and surfaces expired test grants for user sign-off.
