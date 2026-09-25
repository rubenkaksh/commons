# Handoff — Scout-first rule (2026-09-25)

## Context
Cloud session (branch `claude/opensource-mvp-strategy-sz0wul`) evaluated the idea: before building anything new, use existing open-source work / free tiers instead of reinventing the wheel. Agreed and turned into a persistent rule for Claude Code on the Mac.

## Decisions
- **Scope is cross-language, not Flutter-only.** Systems (e.g. queue_dashboard, 3D Flame game) can reuse projects from any language/framework/backend, plus free-tier services from https://free-for.dev.
- **Claude's job:** when an idea is discussed, proactively surface existing alternatives. User is often just exploring; decision (build / integrate / fork / update) is made together.
- **Tiers:** M0 Integrate (plug and play) · Fork · M1 Adapt (guide/reference repo, like the librosa service) · Service (free tier) · M2 Build.
- **Scout is delegated to the `scribe` subagent** (exists on the Mac, `~/.claude/agents/`); main session validates its findings.
- **Strict filter:** maintained (≤ ~6 months), permissive licence, healthy adoption, fits stack, small dep footprint.
- **Nothing passes:** show top 3 near-misses + which criteria each failed.
- **Flutter M0:** wrap in `commons`, but **ask before wrapping**.
- **Persistence:** user-level `~/.claude/CLAUDE.md` on the Mac (applies to every local session). Cloud sessions don't read it — optionally mirror into claude.ai personal preferences.

## Next steps (on the Mac)
1. Append the rule below to `~/.claude/CLAUDE.md`.
2. Confirm the subagent's `name:` in `~/.claude/agents/` is exactly `scribe`.
3. Test in a fresh session: float a new idea and check Claude scouts before coding.
4. Optional: paste the rule into claude.ai personal preferences for cloud sessions.

## Rule (copy into `~/.claude/CLAUDE.md`)

```md
## Scout-first rule (new ideas / new systems)

Trigger: whenever I discuss, float, or ask to build a new idea, feature, system, or service — in any repo or none. Do NOT write code before this is done.

1. **Scout (delegate to `scribe` subagent).** Search for existing solutions in ANY language/framework/backend:
   - awesome-* lists, GitHub, package registries (pub.dev, npm, PyPI, crates.io, Go, etc.)
   - https://free-for.dev for free-tier SaaS/infra
   - Guides / reference implementations
2. **Validate (main session).** Verify scribe's findings yourself — links resolve, licence, last commit, SDK/runtime support. Drop anything unverified.
3. **Strict filter.** Keep only options that pass ALL:
   - Maintained: last commit ≤ ~6 months, issues answered
   - Permissive licence (MIT / BSD / Apache / similar; no GPL/AGPL in closed code)
   - Healthy adoption (stars, downloads, pub.dev score)
   - Deployable in my stack; reasonable dependency footprint
4. **Present 2–4 options**, each with fit, effort, risk, and a recommended path:
   - **M0 Integrate** — plug and play, config tweaks only
   - **Fork** — close match; fork and update
   - **M1 Adapt** — follow guide/reference repo, rebuild in our stack (like the librosa service)
   - **Service** — free-tier SaaS (free-for.dev)
   - **M2 Build** — from scratch
5. **Nothing passes the filter?** Still show the top 3 near-misses and exactly which criteria each failed.
6. **Decide together.** Wait for my choice before building.

Flutter specifics:
- M0 Flutter packages get wrapped in `commons` (apps import commons, not the package) — **ask me before wrapping**.
```
