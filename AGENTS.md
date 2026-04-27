# AGENTS.md - Lacapult Doobdab

This repo lives at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`.

## Role

You are working on Lacapult Doobdab: a C-AOL-specific launcher/installer derived from Dabdoob/Catapult.

## Read order

At the start of a run, read:
1. `Plan.md`
2. `TODO.md`
3. `SUCCESS.md`
4. `TESTING.md`
5. `TechnicalTome.md`
6. `ATTRIBUTION.md`
7. this file

Then inspect only the source files needed for the active target.

## Current rule

Lacapult remains in release quarantine, but Josef/Schani explicitly reopened the debug-note correction stack for Alex on 2026-04-27. Later on 2026-04-27, Josef superseded parking and explicitly cleared a bounded Lacapult Josef test release v0 so he can test the current debug-stack-complete state.

Use `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md` as the active stack source and start with Package 1 unless reprioritized. Keep Andi on C-AOL; do not point Andi at this repo.

The test-release clearance authorizes only a clearly labelled Draft/prerelease Lacapult launcher test build for Josef validation. It does **not** lift quarantine, authorize stable/latest/final confidence, announce broadly, create C-AOL releases, mutate real user data, install packages/models, or widen scope beyond the canonized debug-note stack plus test-release packaging.

## External/public actions

The public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, but do not push to GitHub, publish releases, or contact upstream without fresh explicit clearance from Josef/Schani.

## Attribution

Preserve MIT license obligations and credits. Do not strip upstream names. Replace misleading public product identity, but keep honest lineage.

## Implementation bias

Prefer boring working changes over elegant refactors. The inherited Godot scene has many hardcoded node paths; do not rip out UI trees unless you are ready to prove the scene still loads.
