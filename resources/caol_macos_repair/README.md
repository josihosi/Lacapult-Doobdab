# C-AOL macOS v0.2.0 repair libraries

These universal macOS dylibs let Lacapult repair the C-AOL v0.2.0 macOS app
bundle that shipped with absolute `/opt/local/lib/libfreetype.6.dylib` and
`/opt/local/lib/libz.1.dylib` load commands.

Lacapult copies `libfreetype.6.dylib` and `libpng16.16.dylib` into
`Cataclysm.app/Contents/Resources`, rewrites the game binary to load freetype
through `@executable_path/libfreetype.6.dylib`, rewrites zlib to macOS' system
`/usr/lib/libz.1.dylib`, and ad-hoc signs the modified Mach-O files.

The dylibs are universal x86_64 + arm64 copies built from Homebrew bottles:

- freetype 2.14.3 — FTL license, see `LICENSE-freetype.txt`
- libpng 1.6.58 — libpng license, see `LICENSE-libpng.txt`

They are committed here so the repair does not depend on the target Mac having
MacPorts, Homebrew, or `/opt/local` installed.
