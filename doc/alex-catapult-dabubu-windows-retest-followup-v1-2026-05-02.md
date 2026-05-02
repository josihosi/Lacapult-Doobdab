# Alex handoff — Catapult-Dabubu Windows retest follow-up v1

Classification: local proofed / Windows test build pending follow-up from Josef Windows retest.

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

4. Ollama retest fixes:
   - measured RAM/VRAM hardware check where available;
   - CLI-style serialized command previews;
   - explicit long install/download wait warning;
   - no unsafe install + pull chaining when Ollama is not ready.

5. Mods/summarizer and C-AOL Downloadable clarity:
   - replace unclear `Show Stock` wording with built-in/mod inventory wording;
   - make Mods page status-only vs Settings summary creation/apply path discoverable;
   - explain an empty C-AOL Downloadable add-on catalog.

6. Shared layout:
   - larger native-resizable default window;
   - hide the custom titlebar compatibility node and reclaim top space.

7. Fresh Josef-only Windows retest build/release after local proof.

## Non-goals

- no public/stable release;
- no quarantine lift;
- no GitHub repo rename;
- no C-AOL release work;
- no live API/secrets/model pulls/real package installs in automated gates without explicit clearance.

## Success bar

Local implementation/static/UI proof for installer plan/status, text reduction, colored dots, Ollama hardware/serialized setup, Mods/Downloadable/Summarizer clarity, and native-resizable window layout is now the immediate boundary. Next boundary is package proof + fresh Josef-only Windows Draft/prerelease, then Josef Windows confirmation.
