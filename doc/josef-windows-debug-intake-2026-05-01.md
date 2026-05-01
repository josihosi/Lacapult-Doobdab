
## 2026-05-01 21:14-21:16 — Josef Windows/API AnyLLM debug-note intake

Raw intake only. Do not promote into Plan/TODO/final work items until Josef says the batch is done and Schani asks follow-up classification questions.

### Debug note 2 — API AnyLLM install-venv popup clipped

Under **API Any LLM**, pressing **Install venv** opens a popup window bounded by the launcher window size; content is cut off.

Initial classification: UI/dialog containment/layout sizing problem. Likely related to custom launcher window/dialog bounds rather than backend logic.

Follow-up candidates after batch:
- screenshot of clipped popup;
- exact popup title/body/buttons;
- whether any action button becomes unreachable;
- whether enlarging/maximizing the launcher avoids clipping;
- Windows display scaling/window size.

### Debug note 2b — API AnyLLM session-user tooltip clipped

Hovering over **User of this session** shows a tooltip window cut off on the left side, also bounded by launcher window size.

Initial classification: tooltip/dialog boundary/positioning bug, probably same family as install-venv popup containment.

### Debug note 3 — API AnyLLM status lights and venv semantics

Josef clarified the status lights are now actually working properly. Visible issue: he sees `?` instead of a meaningful light/indicator in at least one place, described as “like the green light.”

Also: **Install venv does not install the AnyLLM package**, which Josef called nonsensical; expected behavior is that setting up the venv should install AnyLLM/package dependencies needed for the API AnyLLM backend.

Initial classification:
- status-light display/copy issue: `?` fallback indicator is unclear or wrong when a proper readiness state should be shown;
- backend setup behavior issue: API AnyLLM `Install venv` should probably create/update venv and install AnyLLM dependency package(s), not just create an empty venv.

Follow-up candidates after batch:
- which row/control shows `?`;
- whether `?` appears before or after pressing Check/Install venv;
- expected package name/version/source for AnyLLM if canon does not already specify it;
- whether install log/output says venv created but package skipped/failed/unattempted.

### Debug note 4 — General popup/dialog sizing family

Source: Josef Discord `#allgemein`, 2026-05-01 21:18 Europe/Vienna.

Josef generalized the issue: popup windows from buttons are generally messed up. They are too wide and bounded by the launcher window, causing about half the content to be cut off.

Initial classification: broad popup/dialog layout family, not isolated to API AnyLLM Install venv. Likely needs a shared dialog/tooltip/popup sizing and placement fix rather than one-off content edits.

Follow-up candidates after batch:
- list which buttons/popups reproduce it;
- whether every popup is child-bounded by the launcher or only custom popup scenes;
- whether the expected fix should make popups narrower/wrapped, scrollable, centered within launcher, or native/free-floating;
- whether keyboard focus/buttons remain reachable despite clipping.

### Debug note 5 — Install actions appear timed out while work continues

Source: Josef Discord `#allgemein`, 2026-05-01 21:19 Europe/Vienna.

When installing something, the app times out / appears timed out, but in reality the install is still working. Josef suggested it needs some kind of wait/working indicator so the app does not look crashed.

Initial classification: long-running install progress/timeout feedback bug. Likely needs visible in-progress state, longer/streaming operation handling, non-blocking UI, and clearer timeout semantics. Do not treat this as proof the backend install failed until logs confirm failure; the user-facing problem is that the UI implies failure/crash while work continues.

Follow-up candidates after batch:
- which install action(s) reproduce it: API AnyLLM venv, Ollama/model, venv, package install, or all;
- whether the app becomes unresponsive or only the popup/status text times out;
- whether logs continue updating after the UI timeout;
- expected user-facing state: spinner/progress text/log tail/cancellable operation/retry state.

### Debug note 6 — Popup/help text lacks wrapping/newlines

Source: Josef Discord `#allgemein`, 2026-05-01 21:19 Europe/Vienna.

Josef added that Andi/Alex needs to consider adding newlines/wrapping: popup/help text is basically one very wide line. This likely contributes to the popup windows becoming too wide and then being clipped by the launcher window bounds.

Initial classification: shared copy/layout wrapping problem in popup/help/dialog text. Likely fix direction is not only resizing windows, but setting width constraints/autowrap and inserting deliberate paragraph breaks/bullets in long explanatory strings.

Follow-up candidates after batch:
- identify shared label/control class for popup text;
- inspect whether Godot Label autowrap/rect_min_size/size_flags are missing;
- collect which specific text strings are too long;
- decide whether content should be shortened, wrapped, scrollable, or split into title/body/bullets.

### Debug note 7 — Logs: missing proof-only setting and Ollama setup ambiguity

Source: Josef Discord `#allgemein`, 2026-05-01 21:22 Europe/Vienna.

Observed launcher log excerpt during Windows test:

```text
[21:11:24.120] [warning] Can't manage fonts at this time: font config file does not exist. Make sure you've started the game at least once to create it.
[21:12:11.753] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:12:17.473] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:12:29.001] Python venv setup command finished after confirmation.
[21:17:16.037] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:17:19.566] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:17:35.057] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:17:38.722] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:21:11.290] Ollama setup failed; an installer or model pull may have been attempted after confirmation.
```

Josef asked whether the Ollama button might install the wrong Ollama, e.g. GUI Ollama instead of the intended CLI/service Ollama.

Initial classification:
- settings/default bug: release build is reading `backend_external_setup_proof_only` without an initialized default, producing repeated noisy errors;
- Ollama setup ambiguity: the UI does not clearly explain which installer path is used and whether it installs CLI/service/runtime or GUI app; this may also be a real command choice bug depending on platform installer behavior;
- install failure reporting is too vague: “installer or model pull may have been attempted” does not distinguish installer command failure from model pull failure.

Follow-up candidates after batch:
- inspect actual Windows command plan for Ollama install (`winget --id Ollama.Ollama -e` currently suspected);
- verify what `Ollama.Ollama` installs on Windows and whether it provides the expected `ollama` CLI/server behavior;
- add default/init for `backend_external_setup_proof_only` or guard missing setting reads;
- split Ollama install result into installer failure vs model pull failure and show command/log output.

### Debug note 8 — Ollama model selection/readiness lights/model pull/hardware check broken

Source: Josef Discord `#allgemein`, 2026-05-01 21:24 Europe/Vienna, with screenshot `/Users/josefhorvath/.openclaw/media/inbound/08eda29c-588e-4790-8502-815fef6f554c.png`.

Under Ollama setup, the UI says “choose a model name before using this backend” even though the intended design is one supported model-choice control for Mistral/Nemotron. Josef reports the readiness lights are not working in this view, and model pull supposedly does not work. He also asks where the hardware check is for the supported models Nemotron and Mistral.

Relevant standing product expectation from active memory: simplify Ollama setup to one model-choice control with real install/readiness actions; installer should show Mistral/Nemotron readiness via lights and pull supported models when asked.

Initial classification:
- model-choice persistence/state bug: selected Mistral/Nemotron value may not be saved/read as `backend_ollama_model`, causing “choose a model” despite visible choice;
- readiness-light bug: Ollama status lights should distinguish command/server/Mistral/Nemotron/Python/options and not collapse into missing-model-name copy;
- model-pull execution/reporting bug: install/pull action does not prove model pull succeeded or give useful failure detail;
- missing hardware suitability check: UI should include a hardware/fit/readiness check for the supported Mistral/Nemotron choices, or at least explicitly state what is checked/not checked.

Follow-up candidates after batch:
- screenshot analysis / exact visible selected model value;
- inspect `_on_OllamaModelChoice_item_selected`, settings persistence, and `_collect_backend_fields` for Ollama;
- verify whether `backend_ollama_model` is empty in Windows config after choosing a model;
- define expected hardware check dimensions: RAM/VRAM/disk/CPU/GPU? local only vs installer estimate;
- split model pull command/result output from installer result and surface it in UI.

### Debug note 9 — Repeated proof-only setting errors before Ollama failure

Source: Josef Discord `#allgemein`, 2026-05-01 21:25 Europe/Vienna.

Additional log excerpt:

```text
[21:25:01.516] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:25:03.987] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:25:09.307] [error] Attempted to read nonexistent setting "backend_external_setup_proof_only"
[21:25:10.191] Ollama setup failed; an installer or model pull may have been attempted after confirmation.
```

Initial classification: strengthens the setting-default/config-read bug and its temporal connection to the Ollama failure path. The missing `backend_external_setup_proof_only` setting is not a one-off; it is repeatedly read during user actions and may be interfering with proof/external execution mode decisions or at minimum polluting logs and hiding the real install/pull failure.

Follow-up candidates after batch:
- trace every `Settings.read("backend_external_setup_proof_only")` call;
- add default + safe read fallback before any external setup confirmation;
- prove missing setting no longer logs errors;
- then reproduce Ollama setup to expose the real installer/model-pull result separately.
