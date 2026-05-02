# Alex handoff — Catapult-Dabubu Windows retest follow-up v1

Classification: active / greenlit follow-up from Josef Windows retest.

Canonical contract: `doc/catapult-dabubu-windows-retest-followup-v1-2026-05-02.md`.
Imagination source: `doc/catapult-dabubu-installer-vision-retest-imagination-source-2026-05-02.md`.
Raw intake: `doc/josef-windows-debug-intake-2026-05-02.md`.
Screenshot: `/Users/josefhorvath/.openclaw/media/inbound/2fc7eceb-c09c-4588-ae3b-dc77c74eed34.png`.

## Scope order

1. API / AnyLLM installer semantics:
   - one obvious path must create/use venv and install AnyLLM packages/deps;
   - distinguish venv creation, package install, success/failure/progress;
   - no secrets or real-user env mutation in automated proof.

2. Text density:
   - reduce visible LLM/API setup background/helper copy;
   - controls/status/actions first;
   - move nonessential explanation out of the main visible page.

3. Colored status dots:
   - replace fragile Unicode/emoji lights with explicit colored dot/label rendering;
   - red/green/yellow/gray states must be Windows-safe;
   - prove via static/UI smoke that visible status no longer depends on traffic-light glyph rendering.

4. Fresh Josef-only Windows retest build/release after fixes.

## Non-goals

- no public/stable release;
- no quarantine lift;
- no GitHub repo rename;
- no C-AOL release work;
- no live API/secrets/model pulls/real package installs in automated gates without explicit clearance.

## Success bar

Sandbox proof for installer plan/status, UI/static proof for text reduction and colored dots, package proof, then Josef Windows confirmation.
