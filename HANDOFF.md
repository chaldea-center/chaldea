# Session Handoff

Use this file to resume work from another computer after `git pull`.
Update it at the end of each working session.

## Current Purpose
- This fork tracks upstream `chaldea` and adds automation-focused features:
  - Laplace Auto 3T team identification/search
  - Shared Teams "My Box" compatibility and batch simulation tools
- Design constraint: keep upstream-core changes minimal and keep custom logic in
  `lib/custom/...` whenever possible.

## Quick Resume Checklist
1. `git fetch --all --prune`
2. `git checkout main`
3. `git pull origin main`
4. If needed, sync with upstream:
   - `./scripts/sync_fork_pr.sh --open-pr`
   - legacy (if needed): `./scripts/sync_fork.sh`
5. Install deps if needed:
   - `flutter pub get` (or `fvm flutter pub get`)
6. Launch app:
   - `fvm flutter run -d macos`

## Last Session Snapshot
- Date: 2026-03-10
- Branch: automation/upstream-sync-2026-03-10
- Last commit: 5fa5c2f0c
- Working tree status: clean after sync + validation (before handoff commit)
- Active feature(s): upstream sync maintenance; custom Laplace Team Search 3T + My Box verification
- What is done: merged upstream/main into a new sync branch; only upstream delta is `lib/models/userdata/battle.dart` (+11). Verified custom wiring remains in `lib/app/modules/battle/simulation_preview.dart`, `lib/custom/team_search/auto_three_turn_solver.dart`, `lib/custom/team_search/auto_three_turn_team_search.dart`, and `lib/custom/shared_teams/my_box_compatibility.dart`. Validation run: `fvm flutter pub get` passed, `fvm flutter analyze` reported existing 15 info-level lints, `fvm flutter test` failed due missing `APP_PATH` in `test/test_init.dart`.
- What is next: push `automation/upstream-sync-2026-03-10`, open PR to `main`, and run full tests in an environment with `APP_PATH` test data configured.
- Known blockers: sandbox run cannot provide required `APP_PATH` harness data, so full test suite cannot complete here.
## Files Touched In Current Workstream
- `lib/custom/team_search/...`
- `lib/custom/shared_teams/...`
- Thin integration points in:
  - `lib/app/modules/battle/...`

## Validation Commands
- `fvm flutter analyze`
- `fvm flutter test`
- `fvm flutter build macos --debug`

## Notes For Safe Upstream Updates
- Prefer `./scripts/sync_fork_pr.sh --open-pr` for protected-main syncs; use `./scripts/sync_fork.sh` only for manual/non-protected flows.
- Resolve conflicts by preserving upstream behavior first, then re-apply custom
  integration hooks.
- Re-check custom module wiring after any upstream UI changes in battle modules.
