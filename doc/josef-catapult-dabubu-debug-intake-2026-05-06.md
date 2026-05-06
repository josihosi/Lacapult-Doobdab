# Josef Catapult-Dabubu debug intake — 2026-05-06

Raw intake while Josef is actively testing the Catapult-Dabubu Windows retest build v1.

Do not package these into Plan/TODO yet until Josef says the batch is done. Collect first, then ask follow-up classification questions, then patch canon.

## Note 1 — Mods catalog empty / JSON mod support wanted

Josef reports:

- No mods are added to the catalog; this is sad and does not meet the desired mod-discovery feel.
- Desired direction: add mods to the catalog, at least Magiclysm and DinoMod, possibly more.
- Product hypothesis: most mods are JSON mods, so they should probably work with a summarizer adapter.
- Initial implementation idea to investigate: create/extend a summarizer adapter so JSON mods can be cataloged/summarized instead of leaving the catalog empty.

Raw wording:

> No mods added to catalog. thats sad. i want mods, most mods are json mods so they should work fine, i think, with a summarizer adapter, no? at least lets try and get magiclysm and dinomod added here or maybe more.

Status: raw testing note, unclassified. Josef is testing further.

## Note 2 — API / AnyLLM setup failed after venv; likely wrong AnyLLM package/import name

Screenshot: `/Users/josefhorvath/.openclaw/media/inbound/image---723df623-f264-4518-9be5-7f8ab9119fd2.png`.

Josef asks whether the failure is caused by API base URL, wrong model, or empty/default background text.

Observed from screenshot/OCR:

- API base URL is already populated as `https://api.openai.com/v1`.
- Provider is OpenAI.
- Model field shows `gpt-5.4-nano`.
- Python / venv is ready.
- AnyLLM packages need action.
- API-key env var needs action.
- API setup failed with `api_setup_install_anyllm_packages_failed_1`.
- Log says: `C-AOL API backend setup command failed during venv/package setup. No API call or API-secret read was performed.`
- CLI preview shows install target as `any_llm[openai]`.

Schani live finding:

- The failure happened during package setup, before API base URL/model/key were used for a live API call.
- Initial PyPI/web lookup found a similarly named `anyllm` package, but Tavily confirmation below supersedes that as the wrong library for this repo's current import seam.
- Current code in `scripts/BackendConfigManager.gd` builds `package_spec = "any_llm"` / `any_llm[openai]` and probes import `any_llm`; the install target is likely the immediate install failure, while the import seam should remain `any_llm` for Mozilla `any-llm` / PyPI `any-llm-sdk`.
- Separate follow-up: default OpenAI model in code is `gpt-4.1-mini`; screenshot has `gpt-5.4-nano`. Model choice did not cause this install failure, but later live validation should use a real supported provider model or an explicit user-entered model with a clear warning.
- API base URL should default when empty for known providers via `_normalize_backend_fields`; blank OpenAI base URL should become `https://api.openai.com/v1`.
- If Josef means generated mod-summary `your_background`, current bridge uses `setdefault`, so an explicit empty string would not be replaced by the fallback. That should be normalized later if empty summaries appear.

Status: raw testing note, unclassified. Likely implementation fix: install/probe `anyllm` package/import according to the actual library API, improve error surfacing with captured pip stderr, and make the UI say this is package-install failure, not base/model/key failure.

### Tavily confirmation for Note 2

Tavily/web checks confirmed two similarly named libraries and the repo is currently mixing names:

- Mozilla `any-llm` / PyPI package `any-llm-sdk` is the library whose quickstart uses `from any_llm import completion` and provider/model arguments. This matches the repo's `tools/prove_caol_backend_contract.py` import contract.
- Install command for that library should be provider-extra form like `pip install 'any-llm-sdk[openai]'`, `pip install 'any-llm-sdk[anthropic]'`, `pip install 'any-llm-sdk[gemini]'`, `pip install 'any-llm-sdk[openrouter]'`, or multiple extras / `[all]` when appropriate.
- Current launcher preview/code uses `any_llm[openai]`, which is neither the Mozilla package name nor the other package's documented spelling.
- Separate PyPI package `anyllm` exists and uses `import anyllm`; it documents `pip install anyllm[openai]`, but that does not match the repo's existing `from any_llm import completion` seam.

Provider/base-url finding:

- Mozilla provider docs list provider IDs with provider-specific key env vars and optional base env vars, e.g. `openai` -> `OPENAI_API_KEY` / `OPENAI_BASE_URL`, `anthropic` -> `ANTHROPIC_API_KEY` / `ANTHROPIC_BASE_URL`, `gemini` -> `GEMINI_API_KEY` or `GOOGLE_API_KEY` / `GOOGLE_GEMINI_BASE_URL`, `openrouter` -> `OPENROUTER_API_KEY` / `OPENROUTER_API_BASE`.
- Therefore Catapult-Dabubu should treat API base URL as an advanced override derived from provider by default, not as a second required normal-user field.
- UI should likely show Provider + Model + Key first, and hide Base URL behind "advanced/proxy/router/custom endpoint" unless custom provider or provider-specific override is selected.

## Note 3 — Ollama hardware section must show model performance lights, not advisory prose

Screenshot: `/Users/josefhorvath/.openclaw/media/inbound/image---e089735f-6b1a-4b42-9266-fe40550186b4.png`.

Josef is extra explicit:

- Do **not** tell the user “VRAM is low, use a small model.”
- There are exactly two relevant local models in this UI: `mistral-v0.3` and `nemotron-9b`.
- The hardware area should show RAM and VRAM, but in GiB/Gigabytes, not raw MB-ish clutter.
- Next to RAM/VRAM, show two estimated-performance lights:
  - red/yellow/green light `mistral-v0.3`
  - red/yellow/green light `nemotron-9b`
- Light color should be determined from measured RAM + VRAM as an estimated run-performance indicator.
- Do not add extra explanatory/advisory text.

Desired UI shape:

```text
RAM: 15.6 GiB   VRAM: 1.0 GiB
● mistral-v0.3   ● nemotron-9b
```

Where each dot/light is red/yellow/green according to estimated performance from RAM/VRAM.

Status: raw testing note, unclassified. Likely implementation fix: replace hardware recommendation prose with compact model-specific performance indicators; keep thresholds in code/tests and screenshot-proof the exact sparse wording.

## Note 4 — Add runner test button for both Ollama local and API route

Josef requests:

- Add a **runner test** button to the Ollama/local route.
- Add a **runner test** button to the API call route.
- The button should test the actual C-AOL runner path, not just UI config/readiness metadata.

Initial interpretation:

- Current setup/check UI can say Python/venv/package/model/key readiness, but Josef needs an explicit “does the runner actually work?” test for each backend route.
- The Ollama button should exercise the local runner path against selected local endpoint/model without doing install/pull work.
- The API button should exercise the API runner path through the configured provider/model/key-env/session-key route, clearly gated so it does not surprise-spend or leak secrets.
- Results should be shown as the same red/yellow/green light style and concise log/status output, not a prose wall.

Status: raw testing note, unclassified.

### Addendum to Note 2 — Base URL should disappear from normal API setup

Josef clarification:

- If Provider already determines the normal endpoint, the normal setup UI should not ask for API base URL.
- Base URL should be kept only as an advanced/custom override for proxy/router/local gateway/weird endpoint cases.

Implementation read:

- Normal mode: Provider + Model + API key/env var + setup/check/test buttons.
- Advanced/custom mode: optional base URL override, with provider-specific default/env-var shown as help text if needed.
- Do not delete base URL support from backend config entirely; hide it from the ordinary path and derive defaults from provider.

## Note 5 — Ollama install/model submenu timeout wording

Josef requests a wording change in the submenu after choosing/installing Ollama/model:

- Current wording should explicitly warn that the launcher may appear to time out.
- Desired note: **"The launcher may appear to time out. Wait for Ollama installation to commence."**

Implementation read:

- This belongs near the confirmation/submenu flow after install Ollama / model selection, before or during the external installer/model setup wait.
- Keep it short; do not add a large explanatory paragraph.
- The point is to prevent Josef/users from assuming the launcher has failed while the external Ollama installation is still starting.

Status: raw testing note, unclassified.

## Note 6 — Ollama Mistral pull uses wrong model tag

Josef provided live log:

```text
[22:10:20.972] Pull the selected model after confirmation. failed after confirmation (exit 1): ollama pull mistral-v0.3. Installer/CLI/server/model-pull state is reported separately; use Check after fixing the failed step.
```

Schani check:

- Tavily/Ollama search shows the Ollama library tag is `mistral:v0.3`, not `mistral-v0.3`.
- Local Mac probe also reports `ollama show mistral-v0.3` as not found.
- Local Mac has `mistral:latest` installed, but not `mistral:v0.3`.

Implementation read:

- Catapult-Dabubu should use the exact Ollama tag `mistral:v0.3` if that specific version is intended.
- Alternatively, use/select `mistral:latest` if the product wants the locally common/default Mistral tag.
- UI display labels can be friendly, but the command must preserve Ollama tag syntax with colon.
- Runner/model readiness should check exact selected tag and show a clear "wrong tag/not found" message if the tag is invalid.

Status: raw testing note, unclassified.

## Note 7 — Ollama Nemotron pull uses non-pullable/simple wrong tag

Josef provided live log:

```text
[22:11:19.360] Pull the selected model after confirmation. failed after confirmation (exit 1): ollama pull nemotron-9b. Installer/CLI/server/model-pull state is reported separately; use Check after fixing the failed step.
```

Schani check:

- Local Mac has custom/local tags:
  - `nemotron-9b-full:latest` — present, 8.9B, 9.1 GB.
  - `nemotron-9b-dumber:latest` — present, 8.9B, 9.1 GB.
  - `nemotron-4b:latest` — present, 4.0B, 2.8 GB.
- Local `ollama show nemotron-9b`, `nemotron-9b:latest`, and `nemotron:9b` all fail.
- Tavily/Ollama search did not find a canonical simple `nemotron-9b` library tag.
- Public Ollama options found include:
  - official/library `nemotron` — 70B, not the desired 9B lightweight route.
  - official/library `nemotron-mini` / `nemotron-3-nano` — smaller/different models, not the same as Josef's local 9B tags.
  - third-party `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest` — 9.1 GB / 1M context, pull command shown as `ollama run mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso`.
  - GitHub issue snippet mentions custom/local style `nemotron-nano:9b-v2-q6_K_L`, but not as a confirmed official pullable library tag.

Implementation read:

- `nemotron-9b` is currently a fake/non-pullable tag for a fresh Windows user.
- Decide which product route is intended:
  1. use Josef/local custom tags only when already installed (`nemotron-9b-full:latest`, etc.) and do not offer Pull for them unless Catapult can create/import them from a Modelfile/source;
  2. switch the downloadable 9B option to a real pullable registry model, likely `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`, with an explicit third-party/source caveat;
  3. use official smaller `nemotron-mini` / `nemotron-3-nano` if the goal is official/simple pullability rather than the exact 9B model.
- UI labels can say Nemotron 9B, but the command must use a real Ollama model name/tag or a local-only installed tag with no pull button.
- Readiness should separate "installed local custom tag", "pullable registry tag", and "invalid/nonexistent tag".

Status: raw testing note, unclassified.

## Note 8 — Hardware check row says missing despite measured RAM/VRAM

Screenshot: `/Users/josefhorvath/.openclaw/media/inbound/image---9f046e10-bff9-476d-9638-bbf66b4f03e4.png`.

Josef reports:

- Hardware check says **missing**.
- But RAM and VRAM measurements are shown accurately enough, so something is inconsistent.

Observed from screenshot/OCR:

- Hardware hint line says: `Hardware check: RAM 32125 MB / VRAM 2048 MB — Measured RAM/VRAM are low for local LLMs; use API setup or the smallest local model first.`
- Status rows say: `Hardware check: missing`.
- Therefore the measurement path works, but the status-light row uses a misleading/incorrect state label.

Schani code read:

- `scripts/BackendConfigManager.gd::get_ollama_hardware_check()` returns `state = "red"` when RAM/VRAM are measured but below thresholds.
- `scripts/BackendSetupUI.gd::_ollama_status_rows()` passes that hardware state into the status row.
- The visible row rendering likely maps red to the text `missing`, which is wrong for hardware. Red hardware means "measured but poor/low estimated performance", not "missing".

Implementation read:

- Hardware status row needs separate wording from generic dependency rows.
- After Note 3, this row should probably be removed/replaced by model-specific performance lights anyway:
  - RAM/VRAM shown in GiB.
  - red/yellow/green `mistral:v0.3` or chosen Mistral label.
  - red/yellow/green Nemotron chosen label.
- If a generic hardware row remains, red should display `low` or `poor`, yellow `borderline`, green `good`, gray `unavailable`; never `missing` when measurements exist.

Status: raw testing note, unclassified.

### Josef decision for Note 7 — Nemotron tag to use

Josef confirmed the intended Nemotron pull/model tag:

```text
mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest
```

Implementation read:

- Replace the fake `nemotron-9b` pull target with this exact Ollama model tag.
- UI may display a friendlier label such as `Nemotron Nano 9B v2` / `Nemotron 9B`, but command/readiness/runner config must preserve the exact tag.
- The performance-light label can be concise, but the underlying selected model must be `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`.
- If source/caveat text is needed, keep it short and not in the main hardware-light row.

### Addendum to Note 7 — Nemotron selector label should stay short

Josef clarification:

- In the GUI model selector box, do **not** display the full `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest` tag.
- Display a short friendly label for the model, e.g. `nemotron-9b` / `Nemotron 9B`.
- Internally, the selected model must still map to the full Ollama tag:
  `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`.

Implementation read:

- Separate display label from command/model id.
- Selector labels should be human-short; command preview/log/readiness may show the exact underlying tag when useful, but not as the main dropdown label.
