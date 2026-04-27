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

Lacapult is currently in release quarantine with a parked debug-note correction stack. Do not start implementation, point Andi at this repo, republish releases, or widen scope unless Josef/Schani explicitly reopens Lacapult.

If reopened, use `doc/lacapult-parked-debug-note-correction-packages-2026-04-27.md` as the parked stack source and start with the narrowest package unless reprioritized.

## External/public actions

The public repo exists at `https://github.com/josihosi/Lacapult-Doobdab`, but do not push to GitHub, publish releases, or contact upstream without fresh explicit clearance from Josef/Schani.

## Attribution

Preserve MIT license obligations and credits. Do not strip upstream names. Replace misleading public product identity, but keep honest lineage.

## Implementation bias

Prefer boring working changes over elegant refactors. The inherited Godot scene has many hardcoded node paths; do not rip out UI trees unless you are ready to prove the scene still loads.
