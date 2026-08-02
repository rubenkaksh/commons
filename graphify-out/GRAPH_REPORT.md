# Graph Report - commons  (2026-08-02)

## Corpus Check
- 37 files · ~8,740 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 406 nodes · 485 edges · 22 communities (20 shown, 2 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 3 edges (avg confidence: 0.78)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3bc955b7`
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
- navigation_themes.dart
- surface_themes.dart
- status_badge.dart
- m.StatelessWidget
- section_header.dart
- input_themes.dart
- graphify.js
- AGENTS.md

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

## Communities (22 total, 2 thin omitted)

### Community 0 - "login_screen_test.dart"
Cohesion: 0.05
Nodes (38): Finder, FilledButton, package:commons/commons.dart, package:flutter_test/flutter_test.dart, required LoginServiceCallbacks callbacks,
  bool, String get, appBarTitle, demoEmail (+30 more)

### Community 1 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (31): ButtonThemes, elevated, fab, filled, iconButton, outlined, segmented, text (+23 more)

### Community 2 - "login_screen.dart"
Cohesion: 0.04
Nodes (45): FormState, GlobalKey, asyncData, build, _buildForm, callbacks, createState, dispose (+37 more)

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

### Community 14 - "navigation_themes.dart"
Cohesion: 0.25
Nodes (7): appBar, bottomNavigationBar, navigationBar, navigationDrawer, navigationRail, NavigationThemes, tabBar

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

### Community 19 - "input_themes.dart"
Cohesion: 0.33
Nodes (5): decoration, dropdownMenu, InputThemes, searchBar, searchView

## Knowledge Gaps
- **237 isolated node(s):** `graphify`, `email`, `displayName`, `idToken`, `operator` (+232 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Session — 2026-08-01` connect `Session — 2026-08-01` to `commons.dart`, `dio_api_client_test.dart`?**
  _High betweenness centrality (0.198) - this node is a cross-community bridge._
- **Why does `LoginScreen` connect `Session — 2026-08-01` to `login_screen.dart`, `inputs.dart`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Why does `GoogleSignInServiceImpl` connect `Session — 2026-08-01` to `google_sign_in_service_impl_test.dart`, `google_sign_in_service_impl.dart`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **What connects `graphify`, `email`, `displayName` to the rest of the system?**
  _237 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `login_screen_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0524390243902439 - nodes in this community are weakly interconnected._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05263157894736842 - nodes in this community are weakly interconnected._
- **Should `login_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.043478260869565216 - nodes in this community are weakly interconnected._