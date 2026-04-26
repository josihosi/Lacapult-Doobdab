# Lacapult release quarantine / CAOL-content investigation (2026-04-26)

Status: active incident note.

## Trigger

Josef reported that the 2026-04-26 Lacapult / “Leckerpult” release was completely faulty and should be taken off the website because it looked like “there's CAOL in there, there's not Leckerpult in there.”

Immediate response: quarantine first, then investigate. Public confidence loses the argument. Na, obviously.

## Quarantine state

The public 2026-04-26 Lacapult prerelease family has been converted to **Draft** on GitHub:

- `lacapult-post-mod-ui-retest-2026-04-26`
- `lacapult-test-2026-04-26-2`
- `lacapult-test-2026-04-26`

Verification after quarantine:

- Authenticated `gh release list --repo josihosi/Lacapult-Doobdab --limit 20 --json name,tagName,isDraft,isPrerelease,createdAt,publishedAt` shows all three releases with `isDraft: true`.
- Unauthenticated GitHub releases API check to `https://api.github.com/repos/josihosi/Lacapult-Doobdab/releases?per_page=10` returns `count 0`, so there are no public API-listed releases.
- Unauthenticated `HEAD` on the latest Windows asset URL returns `404`, so the release asset is not publicly downloadable through the old asset URL.
- Tag/source pages can still return HTTP `200`; that is not the same as a public release/download asset.

## Artifact inspected

Local artifact inspected:

- `.proof-cache/lacapult-export/packages/Lacapult-Doobdab-windows-unsigned.zip`
- Remote latest asset digest recorded by GitHub: `sha256:694823044d89f091257ce6dedbf3cd92d0ba3b13ba0014ee3264146dae29dc42`
- Local zip hash matched: `694823044d89f091257ce6dedbf3cd92d0ba3b13ba0014ee3264146dae29dc42`
- Local executable hash: `562379719413ad88d2a8d93ddc72ed296b8e227b8db9df73c7f89d8113ec19d6`

Zip contents:

```text
Lacapult-Doobdab.exe
utils/7-ZIP_LICENSE
utils/7za.exe
```

Initial conclusion: the Windows zip is not literally a bundled C-AOL game package. It contains the Lacapult executable plus the 7-Zip helper sidecar.

## Why it still looks CAOL-heavy

The executable is a Godot export of the Lacapult project, and Lacapult is currently a C-AOL-specific installer/backend/mod/Summarizer helper. Its embedded project strings include many C-AOL names and paths by design:

- `project.godot` says `config/name="Lacapult Doobdab"`.
- `project.godot` says `config/description="A C-AOL release installer and backend setup helper derived from Dabdoob/Catapult"`.
- The app embeds UI strings such as `Cataclysm: Arsenic and Old Lace`, `C-AOL LLM backend setup`, `Save C-AOL backend setup`, `View C-AOL release page`, C-AOL release URLs, C-AOL executable names, C-AOL mod/Summarizer status, and macOS C-AOL repair copy.
- The app still carries inherited Catapult/Dabdoob path names and nodes, e.g. `res://scenes/Catapult.tscn`, `/root/Catapult`, `Dabdoob`, and `CatapultGodotApp`, some of which are internal/inherited rather than user-facing.
- The app bundles C-AOL macOS repair helper resources (`resources/caol_macos_repair/...`) so the launcher can repair the known v0.2.0 Mac package dependency problem after install.

So the first inspected package is “Lacapult executable, C-AOL-specific product,” not “C-AOL game archive mislabeled as Lacapult.” But Josef's report still stands as a product failure if the downloadable app/page reads as CAOL instead of clearly reading as the Lacapult launcher. The launcher identity and release copy can be technically truthful and still be a mess. Bureaucracy would call that nuance; users call it broken.

## Current suspected failure class

Most likely from current evidence:

1. **Public-release confidence failure:** the prerelease was published externally before the launcher identity/website/download story had enough user-facing clarity.
2. **Product-positioning/identity failure:** Lacapult is meant to be a launcher, but its current UI and release copy strongly center C-AOL because C-AOL is the only game target. That can feel like “this is CAOL, not Lacapult.”
3. **Inherited-name leakage:** Catapult/Dabdoob internal names and some visible lineage strings remain; even when licensed/credited correctly, they can blur identity in a downloadable Windows artifact.
4. **Not yet proven from current evidence:** the latest Windows zip is not currently proven to contain a full C-AOL game payload or to have been built from the Cataclysm-AOL repo by mistake.

## Mac-side identity surface pass - 2026-04-26

A bounded non-mutating pass inspected the surfaces available from macOS and added the smallest obvious launcher-facing correction before any republish:

- Local Windows package shape is still Lacapult-shaped: `Lacapult-Doobdab.exe`, `utils/7-ZIP_LICENSE`, and `utils/7za.exe`.
- The quarantined release body already says this is a **Lacapult launcher** prerelease and not a new C-AOL game release.
- The first Game-tab surface was too easy to read as just “C-AOL” because it jumped straight into the C-AOL target/release controls. It now starts with `Lacapult Doobdab launcher` and explicit copy saying the download is the launcher, not a C-AOL game archive, and that it fetches/installs existing C-AOL releases.
- The visible About-tab GitHub link still pointed at upstream Dabdoob/Catapult as if it were the product repo. It now points to `https://github.com/josihosi/Lacapult-Doobdab/`; upstream credit remains in attribution/credit copy.
- Proof: `python3 tools/prove_lacapult_identity_surface.py`; evidence JSON: `.proof-cache/lacapult-identity-surface/latest.json`.

This reduces obvious user-facing identity leakage, but it is not a Windows runtime reproduction. Real Windows first-launch click-through remains required before confidence/republish.

## Open investigation steps

- Run a real Windows first-launch click-through: package extraction shape, first-launch window, first visible tab, release row wording, and any “wrong app” impression.
- Decide whether the next identity/product correction packet should also include:
  - a stronger launcher-first welcome/start page;
  - release-row copy that treats C-AOL as the target game, not the artifact identity;
  - fewer inherited Catapult internal names in visible places;
  - release notes/download-page framing that stays Lacapult-first;
  - maybe rename user-facing windows/buttons before the next retest.
- Keep all Lacapult release assets draft/private until the investigation is closed and Josef/Schani explicitly re-greenlight publication.

## Do not conclude yet

Do **not** republish any Lacapult release from this family while this note is open.

Do **not** claim “fixed” merely because the package contains `Lacapult-Doobdab.exe`. Josef's complaint is about the downloaded product experience, not just archive anatomy.