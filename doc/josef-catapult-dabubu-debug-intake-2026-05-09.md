# Josef Catapult-Dabubu debug intake — 2026-05-09

Raw intake while Josef is actively testing the Catapult-Dabubu Windows retest build v2 (`catapult-dabubu-josef-windows-retest-v2-2026-05-07`).

These notes supersede the repo's earlier "v2 ready / waiting for Josef Windows retest" state. Treat them as the next repair intake, not as quarantine lift clearance or public-release confidence.

## Note 1 — Mod compatibility/install procedure still feels half-done

Josef reports:

- Mods are still not good enough from the user perspective.
- The installer/procedure should stop half-detecting or half-advising and prove the relevant mods actually work.
- Suggested direction: Alex should install/test the mods until they work, then make the Catapult-Dabubu procedure reflect that reality.

Raw wording:

> mods not compatible? we need to fix procedure there, and stop half assinng it. maybe alex can install the mods, like, until they work, to make sure this is good in the installer too?

Schani live read:

- This is Lacapult/Catapult-Dabubu feedback, not Buttbanana.
- It likely needs an end-to-end proof loop for relevant mods, but automated proof must still avoid Josef's real Application Support/save data unless explicitly cleared.
- The existing v2 Magiclysm/DinoMod JSON catalog footing is not enough if the installed-mod procedure still leaves Josef unable to use the mods confidently.

## Note 2 — Save options does not apply the local/API runner setup the way Josef expects

Josef reports:

- The `Save options` button, at least for local/Ollama, does not put the selected local model into the actual local-model options; another option still says `qwen`.
- `Save options` should also enable the LLM runner.
- `Save options` should also put LLM mode into Ollama mode or API-key mode.
- The concept needs a proper product decision: is it "save draft fields" or "commit this provider/model as the active runner setup"?

Raw wording:

> the savce options buttons (at least for the local model) does not put the local model into the local model options. that one says qwen
>
> Plus the save options button should also enable the llm runner in the llm options
>
> the save options button also doesnt put the LLM mode into ollama mode, or api key mode. so in general the concept of the save optons button needs to be thoroughly thought out

Schani live read:

- The button is currently pretending to be a commit/apply action but only half-updates the runtime config.
- User expectation is closer to "commit this runner setup as usable" than "save a launcher draft".
- Implementation must decide whether to rename/split the action or make it apply the real C-AOL options, including runner enablement, backend mode, and selected local/API model.

## Note 3 — Windows Ollama CPU/iGPU local mode is painfully slow and should be shown honestly

Josef reports:

- Ollama on Windows is very slow and appears CPU-only.
- The machine uses iGPU; Mac mini local mode felt faster.
- The product should help users understand this instead of presenting CPU/iGPU fallback as a happy path.

Raw wording:

> holy moly ollama on windows is slow as heck. its using my cpu only and it takes aaages. any way to speed this up?
>
> ah yes its a iGPU. but i believe it was a lot faster on mcmini. goddamn windows underutilizing my hardwarew xD but no matter its ok.

Schani live read:

- CPU-only Ollama on Windows should be amber/red slow fallback, not a green local-LLM experience.
- If NVIDIA is present, the UI/procedure should point toward driver/CUDA detection; if AMD/iGPU-only, API mode or smaller/quantized local models may be the sane path.
- This extends the v2 RAM/VRAM performance-light work: acceleration state matters, not only memory quantity.

## Note 4 — Local Ollama reasoning output leaks raw `<think>` into C-AOL speech

Josef reports a live C-AOL NPC response where the ambient response text begins with `<think>` and the spoken `say` output is only `<think>`.

Observed shape from Josef's pasted log:

- Request succeeds (`ok: true`) through the Ollama backend.
- The model spends the full token budget on a reasoning block.
- The returned text starts with `<think>` and never reaches a usable final NPC line.
- C-AOL then speaks the raw `<think>` token.

Raw summary from Josef:

> model just said '<think>' only. this is CAOL
>
> oh, ok so the model is thinking, even though it shouldnt..... oh no. lol, on macos that worked. oh no. we dont want the model to think and we are telling it not to think

Schani live read:

- This is a real runtime/speech-path bug, not merely annoying model behavior.
- Do not rely only on prompt wording or stop tokens.
- Product fix wanted:
  1. send explicit `think: false` for local Ollama NPC speech;
  2. strip/reject any `<think>...</think>` block anyway;
  3. if output is empty or starts with `<think>`, retry once with a stricter final-only prompt / smaller non-reasoning fallback;
  4. never let raw `<think>` reach `say`.
- Prefer Ollama `/api/chat` where useful because thinking-capable models may separate `message.thinking` from `message.content`; speech should use only content.

## Note 5 — Mirror Josef's working Mac Nemotron setup without duplicating model weights

Josef clarified after the `<think>` investigation:

- `nemotron-9b-full:latest` is the local Mac alias for `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`.
- The Mac setup behaved better because Josef had a local Ollama setup with a SYSTEM no-thinking directive.
- Catapult should mirror that setup instead of just pulling the raw registry tag.
- Josef does **not** want the installer to copy/double the model weights immediately.

Raw wording:

> nemotron-9b-full:latest is mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest.
> Ok then lets mirror the setup! i do not want us to copy the model and double it immediatley, so lets implement the SYSTEM /no_think for local models in ollama set up in the installer?
>
> ok? anything unclear? or can we wrapthe catapult debug notes?
>
> it works tho, somewhat! 😄 nice!

Schani live read:

- This makes the Lacapult-side setup work clear: the Ollama installer/model path should prepare a no-thinking runtime alias from the Virtuoso source model using an Ollama Modelfile.
- The source pull remains `mirage335/NVIDIA-Nemotron-Nano-9B-v2-virtuoso:latest`; the C-AOL runtime model should be the prepared local alias, currently `nemotron-9b-dumber:latest`, with `SYSTEM /no_think`.
- `ollama create <alias> -f <Modelfile>` should reuse the source model blobs rather than pull a second full model copy. The UI/proof must say that explicitly.
- This does not remove the need for C-AOL runner hardening (`think:false`, strip/reject/retry), but it gives Catapult a concrete installer-side mitigation that mirrors Josef's known-good Mac behavior.

## Classification notes for Alex

- Notes 1-3 are clearly Catapult-Dabubu/Lacapult launcher/procedure repair scope.
- Note 5 is Catapult-Dabubu/Lacapult installer/procedure scope: prepare a local no-thinking Nemotron runtime alias from the Virtuoso source without duplicating model weights.
- Note 4 still appears to live primarily in the C-AOL runner/speech path for hard strip/reject/retry behavior. Alex must not edit the Cataclysm-AOL repo under the standing Lacapult-only role unless Schani/Josef explicitly assigns a cross-repo fix or the needed seam exists in Lacapult packaging/procedure.
- No package install, model pull, live API call, API secret readout, or real Application Support/save mutation is cleared by this intake.
