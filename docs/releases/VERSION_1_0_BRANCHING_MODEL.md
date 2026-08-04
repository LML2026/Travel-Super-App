# Version 1.0 Branching Model

Date: 2026-08-04
Status: Proposed for immediate adoption

## Branches
- main
- release/1.0
- develop

## Purpose
- main: latest stable public release only
- release/1.0: release candidate hardening, bug fixes, and release-critical changes only
- develop: Version 1.1 and post-launch feature development

## Rules
1. Freeze Version 1.0 feature scope on release/1.0.
2. Allow only bug fixes and release-critical updates into release/1.0.
3. Merge release/1.0 into main only after checklist sign-off.
4. Keep develop open for Version 1.1 features.
5. Backport only critical fixes from develop to release/1.0 when required.
6. Require CI green before any merge.

## Pull Request Policy
- PR target for 1.0 fixes: release/1.0
- PR target for new feature work: develop
- PR target for public release promotion: main (from release/1.0)

## Hotfix Policy
- Critical production hotfixes branch from main
- Merge hotfix to main, then cherry-pick to release/1.0 and develop as needed

## Suggested Setup Commands
Run from repository root:

```bash
git checkout -b release/1.0
git checkout -b develop
git checkout main
```

If branches already exist:

```bash
git checkout main
git branch --list
```

## Protection Recommendations
- Protect main and release/1.0 from direct pushes
- Require at least one review approval
- Require CI checks: analyze, tests, build
- Require linear history or squash merge policy

## Exit Criteria for Releasing 1.0 to main
- Version 1.0 checklist complete
- No open P0/P1 defects
- Crash-free sessions above 99%
- Signed release artifacts available
