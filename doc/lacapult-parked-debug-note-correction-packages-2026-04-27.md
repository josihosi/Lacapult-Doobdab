# Lacapult debug-note correction packages (2026-04-27)

Status: ACTIVE CANON / Alex execution lane reopened on 2026-04-27.

Source intake: `/Users/josefhorvath/.openclaw/workspace/runtime/lacapult-debug-intake.md`; promoted from workspace draft after Josef explicitly asked on 2026-04-27 to write the Lacapult debug notes into canon under parked, then reopened later that day for Alex execution.

Repo target: `/Users/josefhorvath/Schanigarten/Lacapult-Doobdab`.

Classification: active stack for Alex. Keep it separate from C-AOL Andi work and do not republish Lacapult releases from the quarantined 2026-04-26 family until the quarantine/identity investigation is closed and Josef/Schani explicitly re-greenlight.

## Raw intake checklist preserved from Josef's notes

Source file: `/Users/josefhorvath/.openclaw/workspace/runtime/lacapult-debug-intake.md`.

Backend/API notes:
1. Rename visible `C-AOL LLM backend` tab to `LLM`.
2. Reduce top text to `Choose how C-AOL should reach an LLM backend`; delete unnecessary explanatory top text.
3. API setup needs a provider field/dropdown; current UI is too OpenAI-centric; include OpenAI, OpenRouter, and AnyLLM-supported providers.
4. API setup needs three main fields: API base URL, Provider, API model; explain base URL plainly and remove Ollama/hardware text from API mode.
5. Add `Install API backend`; it should actually install/setup AnyLLM/provider support behind explicit confirmation.
6. Keep Python venv input.
7. Keep API key env-var input, but design a safe GUI paste/set workflow that never logs/displays the key and needs security classification before implementation.
8. Replace the large unreadable API env-var text block with status lights and a `Check` button for Python availability and env-var readiness.
9. Investigate/fix oversized/messed-up close/minimize/top-bar controls, separating macOS/local and Windows evidence.
10. Correct API token copy: the `around 1000 tokens` claim is not supported by checked logs; evidence points closer to many calls around `300-400` tokens, with variation.

Ollama/setup notes:
11. Apply the same top-text cleanup to Ollama mode.
12. Use minimal selected-helper copy: `Use ollama for local LLM utilization.`
13. Remove duplicate `Ollama model` vs `Ollama model choice`; keep one model-choice control.
14. Replace model-selector prose with Mistral/Nemotron readiness lights and an `Install` button that installs Ollama/pulls models only with explicit confirmation.
15. Verify whether Python/venv is still needed for Ollama; if yes, add an install action that creates/fills the venv path.
16. Add compact Ollama/Python status lights plus `Check`; avoid dumping every diagnostic into prose.
17. Add `Save options` beside relevant install/setup actions; Install should save current options first.
18. Remove OpenVINO from the visible Lacapult installer/setup UI for now; leave it only as hidden/specialized in-game support.

Taste note: the GUI has too much senseless text, text overflows the window, and important setup states/buttons do not stand out at first sight. Fix by moving meaning into controls, lights, checks, and short copy instead of more paragraphs.

## Package 1 — LLM tab de-clutter + backend-scope correction v0

request_kind: completed-request

summary: Clean the Lacapult backend setup surface so it behaves like an installer page instead of a wall of explanatory text. Rename the visible backend tab to `LLM`, reduce top/backend-selected copy to short player-facing sentences, remove OpenVINO from the Lacapult installer UI for now, and correct the API token-cost copy using logged C-AOL evidence.

scope:
- Rename the visible `C-AOL LLM backend setup` / `C-AOL LLM backend` tab to `LLM`.
- Make the top page sentence: `Choose how C-AOL should reach an LLM backend`.
- Remove extra top explanatory text unless it earns its place as a visible state/action.
- For API-selected helper text, replace the old `around 1000 tokens` claim with evidence-based wording: recent C-AOL logs show many calls around `300-400` tokens, with variation by prompt/provider/model.
- For Ollama-selected helper text, reduce copy to: `Use ollama for local LLM utilization.`
- Remove OpenVINO from the Lacapult installer/setup UI for now.
- Leave OpenVINO only as a hidden in-game option, not as a visible installer path.
- Preserve attribution/credits and necessary security warnings, but do not let them sprawl into the setup workflow.

non_goals:
- Do not implement API/Ollama installs in this package unless it is cheaper than separating copy from behavior.
- Do not remove in-game OpenVINO support.
- Do not publish or republish a Lacapult release.
- Do not mutate real user config, models, API secrets, or Application Support data.

success_state:
- The tab label reads `LLM` in the visible UI.
- The top sentence and backend-selected helper text match the short copy above.
- API cost copy no longer says `1000 tokens`; it uses the checked `llm_intent.log` estimate.
- OpenVINO is absent from the visible Lacapult installer/setup choices but remains available only where deliberately hidden in-game.
- Static/Godot proof verifies the visible copy and absence/presence boundaries.

testing_impact:
  needed: yes
  notes:
  - Static scan for old tab/title/helper text, old `1000 tokens`, and visible OpenVINO installer choices.
  - Godot scene/load or UI smoke proving the LLM tab and selected-helper text render.
  - No external installs/downloads/API calls.

classification: completed
aux_doc_needed: yes
handoff_needed: yes
completion_evidence:
- `scripts/Catapult.gd` and `scenes/Catapult.tscn` now expose tab `LLM`.
- `scripts/BackendSetupUI.gd` renders the short top sentence, API `300-400 tokens`-with-variation note, and Ollama helper `Use ollama for local LLM utilization.`
- `scripts/BackendSetupUI.gd` exposes only API / AnyLLM and Ollama local setup choices; hidden OpenVINO config/readiness support remains in `scripts/BackendConfigManager.gd` and sandbox proof tooling.
- `tools/godot_llm_tab_declutter_smoke.gd` renders the actual BackendSetupUI labels/options under isolated `HOME` and loads `scenes/Catapult.tscn` with `Main/Tabs/LLM`.

open_questions:
- Exact hidden in-game OpenVINO option path remains a future C-AOL/game-side verification item; Lacapult visible setup removal is complete.

## Package 2 — Setup save/check action pattern v0

request_kind: completed

summary: Apply a consistent setup-form behavior across Lacapult backend setup: manual field edits can be saved without installing, and every install action saves current options before doing work. Replace long explanatory blocks with compact status lights and explicit Check actions.

scope:
- Add `Save options` next to relevant backend/setup `Install` actions.
- Make `Install` call the same save path before attempting install/setup.
- Add or standardize `Check` actions that refresh readiness lights without installing.
- Define a small shared status-light vocabulary: green ready, yellow partial/needs action, red missing/error.
- Ensure status lights communicate setup state without overflowing text.
- Apply the pattern to API and Ollama setup, and leave hooks for future backend pages.

non_goals:
- Do not implement every backend installer inside this cross-cutting package unless paired with the API/Ollama packages.
- Do not store secrets unsafely as part of generic save behavior.
- Do not turn the UI into a giant diagnostics dashboard; only expose user-actionable lights.

success_state:
- Users can save manually-entered options without installing.
- Install buttons persist current fields before doing install/setup.
- Check buttons update readiness state without side effects beyond local detection.
- The backend setup page uses controls/status instead of unreadable explanatory text.

testing_impact:
  needed: yes
  notes:
  - UI/static proof for Save options, Install-save ordering, and Check behavior.
  - Sandboxed config/options round-trip proof.
  - Non-mutating readiness check proof.

classification: complete
aux_doc_needed: no
handoff_needed: no
completion_note:
- Landed 2026-04-27 with local BackendSetupUI helpers plus reusable BackendConfigManager status/check helpers. Evidence: `tools/godot_backend_setup_save_check_smoke.gd`, LLM tab smoke, backend triad smoke, and focused source scans.

## Package 3 — API / AnyLLM real setup workflow v0

request_kind: active-request

summary: Turn the API setup path from OpenAI-centric config clutter into a provider-aware AnyLLM installer workflow. The UI should expose API base URL, provider, and model; explain base URL plainly; install AnyLLM/provider support when asked; and provide a carefully designed safe API-key environment-variable workflow.

scope:
- Add a provider field, preferably a dropdown, covering OpenAI, OpenRouter, and extensible AnyLLM-supported providers.
- Present three main API fields: `API base URL`, `Provider`, and `API model`.
- Add concise tooltip/help text explaining API base URL as the server endpoint the backend sends API requests to, usually left at the provider default unless using a compatible proxy/router.
- Remove Ollama/hardware-specific text from API mode.
- Add `Install API backend` action beneath the API fields.
- Make `Install API backend` actually install/setup the API/AnyLLM backend for the selected provider in the configured Python environment, with explicit confirmation and non-mutating proof gates.
- Keep Python venv path input.
- Keep API key env-var name input.
- Design a safe optional API-key paste/set workflow: user pastes key into a secret field, presses a clear action, Lacapult stores/sets only what is necessary, never logs or displays the key, and explains persistence scope.
- Replace the large text beneath API env-var setup with status lights and a `Check` button: Python available, backend importable, env var configured/set, and API setup ready.

non_goals:
- No live API calls requiring Josef secrets in automated tests.
- No plaintext API key storage unless Josef explicitly accepts a platform-specific secure-storage design.
- No provider-specific sprawl that blocks generic AnyLLM support.
- No OpenVINO or Ollama installation in this API package.

success_state:
- API setup is provider-aware rather than OpenAI-centric.
- API base URL/provider/model fields save and round-trip into the intended options/config path.
- `Install API backend` saves current options first, then performs or stages the backend install path with explicit confirmation.
- Secret-entry workflow is reviewed for no log/display leakage and has clear persistence semantics.
- Status lights plus `Check` replace the unreadable paragraph block.

testing_impact:
  needed: yes
  notes:
  - Static/Godot UI proof for the three fields, provider choices, helper copy, status lights, Check, Save options, and Install API backend.
  - Sandboxed Python environment proof for AnyLLM install/import path where safe.
  - Secret-handling proof should scan logs/output/state for no key echoing.
  - No real remote API call unless explicitly gated as a manual optional proof.

classification: complete
completion_note:
- Landed 2026-04-27 with provider-aware API controls for base URL/provider/model/env-var name plus a session-only secret paste action that sets the named process env var and clears the field without saving/logging the key. `Install API backend` saves first, shows a provider-specific AnyLLM pip command preview behind confirmation, and can run `python -m pip install --upgrade any_llm[...]` through `OS.execute` without shell interpolation when proof mode is off. Automated proof enables `backend_api_setup_proof_only`, records setup intent only, and performs no pip install, API call, secret read, model pull, or real user config mutation. Evidence: `tools/godot_api_anyllm_workflow_smoke.gd`, Package 2 regression smoke, LLM tab smoke, backend contract proof, and focused source scans.
remaining_manual_evidence:
- Actual package installation/import proof in a disposable Python environment remains optional/future and requires explicit package-install clearance; automated gates intentionally stay no-install.
aux_doc_needed: no
handoff_needed: no
open_questions:
- Which secure storage/persistence mechanism is acceptable for API keys per OS: process env only, shell profile, platform keychain/credential store, `.env` file, or C-AOL config indirection?
- Exact AnyLLM provider enumeration source needs source inspection.

## Package 4 — Ollama real installer + model readiness workflow v0

request_kind: greenlit-request

summary: Simplify Ollama setup into one model-choice control plus real install/readiness actions. The installer should install Ollama and pull supported models when explicitly asked, show Mistral/Nemotron readiness via lights, and set up/fill the Python venv path through an install action instead of dumping prose at the user.

scope:
- Remove duplicate `Ollama model` vs `Ollama model choice`; keep only `Ollama model choice`.
- Keep supported model choices for Mistral and Nemotron.
- Replace text beneath the model selector with status lights for Mistral and Nemotron: green/yellow/red.
- Define light meanings explicitly, e.g. green = model present/usable, yellow = Ollama reachable but model missing or needs pull, red = Ollama unavailable/error.
- Add `Install` action that installs Ollama where appropriate and pulls selected/required models with explicit confirmation.
- Keep Python/venv path if still needed for C-AOL backend bridge; verify necessity in source before retaining.
- Add Python/venv `Install` action that creates/sets up the venv and fills the path field.
- Add status lights plus `Check` for the minimal useful setup states: Ollama command/server available, selected model present, Python/venv usable, C-AOL option path saveable.
- Remove the rambling text beneath Ollama selectors.

non_goals:
- No huge model pulls in automated proof unless mocked/sandboxed or explicitly cleared.
- No silent auto-pick of model without user confirmation.
- No OpenVINO or API setup behavior in this package.
- No platform package-manager surgery without confirmation and platform-specific guardrails.

success_state:
- Ollama setup has one clear model-choice control.
- Mistral/Nemotron readiness is visible at a glance.
- `Install` saves options first and then performs/stages Ollama/model install behavior with explicit confirmation.
- Python/venv install/check path is justified by source needs and can fill the path field.
- UI text fits the window and action/state is carried by controls/lights rather than prose.

testing_impact:
  needed: yes
  notes:
  - Static/Godot UI proof for one model selector, lights, Check, Save options, and Install.
  - Mocked or fixture proof for model-present/missing/error light states.
  - Optional local proof may use already-installed Ollama/model only; no new pulls in automated default gates.

classification: complete
completion_note:
- Landed 2026-04-27 with one visible Ollama model-choice control (`mistral-v0.3` / `nemotron-9b`), compact command/server/model/Python/options readiness lights, detection-only Check, sandboxed Save options, confirmation-gated `Install Ollama / model`, and confirmation-gated `Install venv`. C-AOL source inspection in `TechnicalTome.md` confirms the shared Python runner path is needed for Ollama too. Automated proof records setup intents only and performs no platform install, venv creation, or model pull. Evidence: `tools/godot_ollama_workflow_smoke.gd`, Package 2/3 regression smokes, backend contract proof, and focused source scans.
remaining_manual_evidence:
- Actual platform installer/model-pull proof remains optional/future and requires explicit package/model-install clearance; automated gates intentionally stay no-install/no-pull.
aux_doc_needed: no
handoff_needed: no
open_questions:
- Which platform-specific Ollama install paths Josef wants to bless for normal users beyond Homebrew/winget/manual fallback remains a future product decision.

## Package 5 — Lacapult window chrome investigation v0

request_kind: greenlit-request

summary: Investigate and fix the oversized/messed-up close/minimize/top-bar controls. The first step is evidence: determine whether the problem reproduces in the local macOS Godot run, the Windows package, or only one platform/theme/window mode, then patch the smallest responsible UI/theme/window setting.

scope:
- Capture or inspect the current top bar/window-control appearance in the local Godot run where possible.
- Identify whether the controls are native OS chrome, Godot custom UI, theme scaling, project window settings, DPI scaling, or package/platform behavior.
- Provide a simple way for Josef to confirm/deny the Windows appearance, e.g. one screenshot request/checklist or a debug screenshot artifact if Lacapult can capture it.
- Compare macOS and Windows evidence before claiming a cross-platform fix.
- Patch the smallest UI/theme/window setting that actually owns the oversized controls.

non_goals:
- Do not republish a release just for this investigation.
- Do not redesign the whole window frame unless evidence says the frame architecture is the problem.
- Do not conflate this with backend installer copy cleanup.

success_state:
- The root cause class is named: native chrome, custom scene UI, theme/scale, DPI, package/export setting, or unknown with evidence.
- macOS/local evidence and Windows/Josef evidence are separated.
- A fix or a bounded follow-up packet exists with proof screenshots or UI-smoke artifacts.

testing_impact:
  needed: yes
  notes:
  - Screenshot or UI artifact evidence before/after where possible.
  - Godot project/window setting inspection.
  - Windows confirmation remains human/device-dependent unless a Windows runner/screenshot path exists.

classification: local-complete-windows-confirmation-pending
completion_evidence:
- Local/project inspection on 2026-04-27 names the root-cause class as custom scene chrome rather than native OS chrome: `project.godot` sets `display/window/size/borderless=true`, `scenes/Catapult.tscn` instances `scenes/CustomTitleBar.tscn`, and the custom titlebar owns TextureButton Minimize/Maximize/Close controls.
- Smallest-seam local patch tightened custom chrome metrics: titlebar `32px -> 28px`, `Main.margin_top 36px -> 32px`, app icon `24x24 -> 20x20`, close/min/max buttons `32x24 -> 28x20`, and vertical titlebar margins `4px -> 2px`.
- Evidence command: `HOME=$(mktemp -d /tmp/lacapult-window-chrome-home.XXXXXX) godot --path . --no-window -s tools/godot_window_chrome_inspection.gd`.
- Bounded handoff/checklist: `doc/lacapult-window-chrome-investigation-packet-2026-04-27.md`.
remaining_evidence:
- Windows/Josef screenshot or Windows automation is still required before a cross-platform visual-fix claim.
aux_doc_needed: done
handoff_needed: done
open_questions:
- Need Windows screenshot/confirmation from Josef or a Windows automation path before final cross-platform claim.
- Windows/Josef screenshot should confirm whether the tightened custom chrome resolves the complaint, or whether a native-chrome/product decision is still needed.

## Active order for Alex

1. COMPLETE - LLM tab de-clutter + backend-scope correction v0.
2. COMPLETE - Setup save/check action pattern v0.
3. COMPLETE - API / AnyLLM real setup workflow v0.
4. COMPLETE - Ollama real installer + model readiness workflow v0.
5. LOCAL COMPLETE / PARKED FOR WINDOWS CONFIRMATION - Lacapult window chrome investigation v0.

Reasoning: first cut the visible rot and remove misleading scope; then add the shared save/check skeleton; then wire backend-specific setup paths; then investigate the chrome bug with evidence rather than guessing. Packages 1-4 are complete under their automated no-secret/no-live-API/no-unapproved-install/no-model-pull gates; Package 5 is locally implemented/proofed with separated macOS/local versus Windows/Josef evidence. No further Alex-side unblocked debug-stack package remains unless Windows/Josef confirmation reopens the chrome seam.
