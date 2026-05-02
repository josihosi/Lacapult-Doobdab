# Catapult-Dabubu installer-vision retest repair imagination source — 2026-05-02

The finished scene is boring in the best possible way.

Josef opens the Windows launcher, goes to LLM/API setup, and the app behaves like an installer. If the API backend needs a Python environment and AnyLLM packages, the launcher offers one clear path that creates the environment and installs the needed packages, with progress and failure messages that explain what happened. It should not create an empty venv and then leave the user to guess why the backend still cannot work. An installer that does not install the software needed for its promised path is not fulfilling the vision; it is a receptionist handing out homework.

The page should breathe. The setup screen should not look like documentation pasted behind controls. Status and primary actions come first; explanation is short, local, and collapsible or moved behind help where possible. If a sentence does not help Josef decide the next click, it probably does not belong in the visible background.

The readiness indicators must work on Windows. Do not rely on fragile Unicode/emoji traffic-light glyphs if they render incorrectly. Use simple colored dots or labels drawn with font color/theme color: red/green/yellow/gray. The exact glyph can be boring; the color and meaning must be unmistakable. A red dot that renders is better than a clever Unicode symbol wearing tofu makeup.

The next Windows test build should make the setup path feel like a product: install, check, status, done/failed with reason. Not a wall of text. Not broken lights. Not a venv-shaped shrug.

Failure smells:
- "Create venv" succeeds but API backend remains unusable because AnyLLM packages were not installed;
- primary setup action does not clearly install the dependencies needed for API/LLM use;
- the UI still contains broad explanatory background paragraphs behind the controls;
- readiness lights render as missing glyphs, wrong symbols, or ambiguous punctuation on Windows;
- local/mac smoke claims success without a new Josef/Windows visual confirmation.

Review questions:
- Can a normal user click one obvious API/LLM setup action and end with AnyLLM installed in the chosen venv?
- Are status indicators readable on Windows without relying on Unicode emoji support?
- Does the visible page show controls and status first, with much less background prose?
- Does the result feel like a launcher/installer rather than a technical essay with buttons?
