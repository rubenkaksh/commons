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
- **Scout research is persistent (graphify knowledge base).** Every scout result is saved as markdown in one local knowledge folder and indexed with graphify, so repeat lookups hit the local graph instead of the web. Claude also uses it to link past findings to new ideas.
- **Persistence:** user-level `~/.claude/CLAUDE.md` on the Mac (applies to every local session). Cloud sessions don't read it — optionally mirror into claude.ai personal preferences.

## Scout knowledge base (graphify)

**Goal:** research once, reuse forever. Re-lookup costs a local graph query (a few hundred tokens), not a new web search + subagent run.

**Layout (proposed default — confirm on Mac):**
```
~/knowledge/scout/
  <domain>/<topic>.md        # one file per scouted need, e.g. dashboards/queue-dashboard.md
  graphify-out/              # graph.json, GRAPH_REPORT.md, cache/ (machine-local, not committed)
```

**Entry format** (fixed headings so graphify extracts clean nodes/edges):
```md
# <need / idea>
- scouted: YYYY-MM-DD · re-validate after: YYYY-MM-DD (+90 days)
- tags: <domain>, <languages>, <stack>
## Options (passed filter)
- <name> — <url> · licence · last commit · stars · tier (M0/Fork/M1/Service) · fit/effort/risk
## Near-misses
- <name> — failed: <criteria>
## Decision
- chosen: <option/tier> · why · used in: <repo/project>
## Learnings
- gotchas, integration notes, what worked / didn't
```

**Flow:**
1. **Lookup first.** Before delegating to `scribe`, query the scout graph (and `graphify merge-graphs` with the current project's graph for cross-repo context). Hit + not stale → reuse it, skip the web.
2. **Stale or partial hit** → scribe re-checks only the stale entries/criteria.
3. **Miss** → full scout → validate → write the entry.
4. **After every scout or decision** → update the entry (Decision / Learnings) and rebuild the graph incrementally (graphify cache makes unchanged files free; same keyless python-API build used for commons — see `docs/sessions/2026-08-01.md`).
5. **Proposing solutions** → Claude pulls related nodes (same tags, past decisions, learnings) to rank options better over time.

**Honest limits:** not literally 0 tokens (reading the hit costs a little); entries go stale, hence the 90-day re-validate date.

## Next steps (on the Mac)
1. Append the rule below to `~/.claude/CLAUDE.md`.
2. Confirm the subagent's `name:` in `~/.claude/agents/` is exactly `scribe`.
3. Test in a fresh session: float a new idea and check Claude scouts before coding.
4. Confirm knowledge-base location (`~/knowledge/scout/` proposed), create it, run the first graphify build on it; verify the exact graphify query command available and put it in the rule.
5. Optional: back the folder with a private git repo for backup across machines.
6. Optional: paste the rule into claude.ai personal preferences for cloud sessions.

## Rule (copy into `~/.claude/CLAUDE.md`)

```md
## Scout-first rule (new ideas / new systems)

Trigger: whenever I discuss, float, or ask to build a new idea, feature, system, or service — in any repo or none. Do NOT write code before this is done.

0. **Lookup first.** Query the scout knowledge graph (`~/knowledge/scout/`, graphify). Fresh hit (before its re-validate date) → reuse, skip web search. Stale → re-check only stale parts.
1. **Scout (delegate to `scribe` subagent)** on a miss. Search for existing solutions in ANY language/framework/backend:
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
7. **Persist.** Write/update `~/knowledge/scout/<domain>/<topic>.md` (options, near-misses, decision, learnings, scouted + re-validate dates) and rebuild the graphify graph. Use past entries to inform future proposals.

Flutter specifics:
- M0 Flutter packages get wrapped in `commons` (apps import commons, not the package) — **ask me before wrapping**.
```
