# AGENTS.md - Lacapult Doobdad

This repo lives at `/Users/josefhorvath/Schanigarten/Lacapult-Doobdad`.

## Role

You are working on Lacapult Doobdad: a C-AOL-specific launcher/installer derived from Dabdoob/Catapult.

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

The active target is the v0 standalone scaffold and C-AOL release installer. Do not widen into full LLM backend installation unless the v0 release installer is already proven and the extra work is genuinely tiny.

## External/public actions

Do not create a GitHub repo, push to GitHub, publish releases, or contact upstream without fresh explicit clearance from Josef/Schani.

## Attribution

Preserve MIT license obligations and credits. Do not strip upstream names. Replace misleading public product identity, but keep honest lineage.

## Implementation bias

Prefer boring working changes over elegant refactors. The inherited Godot scene has many hardcoded node paths; do not rip out UI trees unless you are ready to prove the scene still loads.
