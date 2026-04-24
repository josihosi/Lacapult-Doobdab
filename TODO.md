# TODO

Short execution queue only.

## Now

Active target: `Lacapult Doobdad v0 standalone scaffold and C-AOL release installer`.

1. Confirm source/import state
   - Verify this repo is local-only and has no inherited `.git` history from Dabdoob.
   - Commit the imported source plus canon docs once attribution files are present.

2. Public identity and attribution cleanup
   - Preserve `LICENSE` MIT notice for qrrk and Dabdoob.
   - Add/update `ATTRIBUTION.md`.
   - Rewrite README top section for Lacapult Doobdad as a C-AOL-specific launcher/installer.
   - Update `project.godot` name/description.
   - Replace or disable Dabdoob self-update URL until Lacapult has its own public releases.

3. C-AOL-only release path
   - Add `caol` / C-AOL as the default and only visible game target.
   - Add release URL for `josihosi/Cataclysm-AOL`.
   - Add platform asset filters for C-AOL release assets.
   - Wire fetch/list/install path so a C-AOL release asset becomes the existing installer metadata shape.

4. Minimal validation
   - Prove release JSON parsing selects correct platform asset(s) from live C-AOL releases.
   - Run the smallest Godot/static check available on this machine.
   - If full GUI launch is possible, smoke launch to the release list; otherwise record the exact missing tool/blocker.

5. Park next slices
   - LLM backend setup tab/installer.
   - C-AOL-specific mod/soundpack/tileset recommendations.
   - Public GitHub repo creation and first push, only after explicit clearance.
