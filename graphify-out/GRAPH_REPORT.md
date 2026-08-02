# Graph Report - /Users/rubenk/projects/commons  (2026-08-02)

## Corpus Check
- cluster-only mode - file stats not available

## Summary
- 401 nodes · 482 edges · 19 communities
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b49e76b0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- login_screen_test.dart
- package:flutter/material.dart
- login_screen.dart
- inputs.dart
- Session — 2026-08-01
- dio_api_client_test.dart
- google_sign_in_service_impl_test.dart
- google_sign_in_service_impl.dart
- bottom_sheet.dart
- commons.dart
- component_themes.dart
- feedback.dart
- widgets/typography.dart
- buttons.dart
- button_themes.dart
- surface_themes.dart
- status_badge.dart
- m.StatelessWidget
- section_header.dart

## God Nodes (most connected - your core abstractions)
1. `Session — 2026-08-01` - 25 edges
2. `LoginScreen` - 8 edges
3. `commons package` - 6 edges
4. `GoogleSignInService` - 5 edges
5. `GoogleSignInResult` - 4 edges
6. `GoogleSignInServiceImpl` - 4 edges
7. `ComponentThemes` - 4 edges
8. `FilledButton` - 4 edges
9. `_LoginScreenState` - 3 edges
10. `ApiClientException` - 3 edges

## Surprising Connections (you probably didn't know these)
- `Contract-driven screens (grandeur pattern)` --semantically_similar_to--> `GoogleSignInService`  [INFERRED] [semantically similar]
  docs/sessions/2026-08-01.md → lib/src/auth/google_sign_in_service.dart
- `Session — 2026-08-01` --references--> `DioApiClient`  [EXTRACTED]
  docs/sessions/2026-08-01.md → lib/src/network/dio_api_client.dart
- `LoginScreen` --shares_data_with--> `LoginAsyncData contract`  [EXTRACTED]
  lib/src/auth/login_screen.dart → docs/sessions/2026-08-01.md
- `LoginScreen` --shares_data_with--> `LoginStrings contract`  [EXTRACTED]
  lib/src/auth/login_screen.dart → docs/sessions/2026-08-01.md
- `Session — 2026-08-01` --references--> `GoogleSignInService`  [EXTRACTED]
  docs/sessions/2026-08-01.md → lib/src/auth/google_sign_in_service.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Login contract-driven screen group** — lib_src_auth_login_screen_loginscreen, lib_src_auth_login_screen_impl_loginstrings, lib_src_auth_login_screen_impl_loginasyncdata, lib_src_auth_login_screen_impl_loginservicecallbacks [INFERRED 0.95]
- **Google sign-in stack (service + plugin impl + opt-in)** — lib_src_auth_google_sign_in_service_googlesigninservice, lib_src_auth_google_sign_in_service_impl_googlesigninserviceimpl, lib_src_auth_google_sign_in_service_googlesigninresult, docs_sessions_2026_08_01_google_sign_in_opt_in [INFERRED 0.90]
- **commons extraction from forkable template family** — external_repo_khelam, external_repo_forkable, pubspec_commons [INFERRED 0.95]

## Communities (19 total, 0 thin omitted)

### Community 0 - "login_screen_test.dart"
Cohesion: 0.05
Nodes (44): Finder, FilledButton, package:commons/commons.dart, package:flutter_test/flutter_test.dart, required LoginServiceCallbacks callbacks,
  bool, String get, appBarTitle, demoEmail (+36 more)

### Community 1 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (35): decoration, dropdownMenu, InputThemes, searchBar, searchView, expansionTile, ListThemes, listTile (+27 more)

### Community 2 - "login_screen.dart"
Cohesion: 0.05
Nodes (39): FormState, GlobalKey, asyncData, build, _buildForm, callbacks, createState, dispose (+31 more)

### Community 3 - "inputs.dart"
Cohesion: 0.06
Nodes (32): FormFieldValidator, _LoginScreenState, build, controller, createState, enabled, error, hint (+24 more)

### Community 4 - "Session — 2026-08-01"
Cohesion: 0.10
Nodes (30): Analysis Options (flutter_lints), @immutable, CHANGELOG, Session — 2026-08-01, Contract-driven screens (grandeur pattern), Git dependency consumption pattern, Opt-in Google sign-in, Material name-collision convention (+22 more)

### Community 5 - "dio_api_client_test.dart"
Cohesion: 0.07
Nodes (27): dart:convert, dart:typed_data, Dio, Dio get, DioException, Exception, HttpClientAdapter, ApiClientException (+19 more)

### Community 6 - "google_sign_in_service_impl_test.dart"
Cohesion: 0.08
Nodes (24): GoogleSignInException, GoogleSignInPlatform, GoogleSignInUserData?, InitParameters?, Object?, package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart, attemptLightweightAuthentication, authenticate (+16 more)

### Community 7 - "google_sign_in_service_impl.dart"
Cohesion: 0.09
Nodes (21): Future, google_sign_in_service.dart, GoogleSignIn, int get, displayName, email, hashCode, idToken (+13 more)

### Community 8 - "bottom_sheet.dart"
Cohesion: 0.09
Nodes (20): Color?, body, build, cancelLabel, confirmEnabled, confirmLabel, FormBottomSheet, isScrollControlled (+12 more)

### Community 9 - "commons.dart"
Cohesion: 0.12
Nodes (15): src/auth/google_sign_in_service.dart, src/auth/google_sign_in_service_impl.dart, src/auth/login_screen.dart, src/network/dio_api_client.dart, src/theme/component_themes.dart, src/theme/typography.dart, src/widgets/bottom_sheet.dart, src/widgets/buttons.dart (+7 more)

### Community 10 - "component_themes.dart"
Cohesion: 0.13
Nodes (14): groups/button_themes.dart, groups/input_themes.dart, groups/list_themes.dart, groups/menu_themes.dart, groups/misc_themes.dart, groups/navigation_themes.dart, groups/picker_themes.dart, groups/selection_themes.dart (+6 more)

### Community 11 - "feedback.dart"
Cohesion: 0.15
Nodes (12): IconData?, actionLabel, build, data, empty, icon, loading, LoadState (+4 more)

### Community 12 - "widgets/typography.dart"
Cohesion: 0.17
Nodes (11): Body, BodySize, build, Headline, HeadlineSize, Label, LabelSize, size (+3 more)

### Community 13 - "buttons.dart"
Cohesion: 0.18
Nodes (10): build, GhostButton, icon, IconButton, isLoading, onPressed, OutlineButton, PrimaryButton (+2 more)

### Community 14 - "button_themes.dart"
Cohesion: 0.22
Nodes (8): ButtonThemes, elevated, fab, filled, iconButton, outlined, segmented, text

### Community 15 - "surface_themes.dart"
Cohesion: 0.22
Nodes (8): banner, bottomSheet, card, chip, dialog, drawer, snackBar, SurfaceThemes

### Community 16 - "status_badge.dart"
Cohesion: 0.25
Nodes (7): BadgeTone, build, icon, label, StatusBadge, tone, Widget?

### Community 17 - "m.StatelessWidget"
Cohesion: 0.29
Nodes (7): EmptyView, ErrorView, LoadingView, StateSwitcher, SearchInput, TextInput, m.StatelessWidget

### Community 18 - "section_header.dart"
Cohesion: 0.29
Nodes (6): build, leadingIcon, onTap, SectionHeader, title, VoidCallback?

## Knowledge Gaps
- **236 isolated node(s):** `email`, `displayName`, `idToken`, `operator`, `hashCode` (+231 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Session — 2026-08-01` connect `Session — 2026-08-01` to `commons.dart`, `dio_api_client_test.dart`?**
  _High betweenness centrality (0.203) - this node is a cross-community bridge._
- **Why does `LoginScreen` connect `Session — 2026-08-01` to `login_screen.dart`, `inputs.dart`?**
  _High betweenness centrality (0.085) - this node is a cross-community bridge._
- **Why does `GoogleSignInServiceImpl` connect `Session — 2026-08-01` to `google_sign_in_service_impl_test.dart`, `google_sign_in_service_impl.dart`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **What connects `email`, `displayName`, `idToken` to the rest of the system?**
  _236 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `login_screen_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.045328399629972246 - nodes in this community are weakly interconnected._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.046511627906976744 - nodes in this community are weakly interconnected._
- **Should `login_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._