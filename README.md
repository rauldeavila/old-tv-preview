# Old TV Preview

Aseprite extension that renders a static LIGHTWARD-style Old TV CRT preview from the active sprite/frame.

This is a CPU/Lua preview tool, not a live GPU shader. It creates a new preview sprite so the original art remains untouched.

## Features

- Render the active frame through an Old TV CRT approximation.
- Uses the LIGHTWARD `july_teste_01` preset as the default.
- Includes `Reference Match` and `Color Leak` preset variants.
- Optional side-by-side comparison with nearest-neighbor raw upscale.
- F7 CRT preview window that draws the filtered image without creating a new sprite.
- Auto-refreshes the CRT preview window after sprite edits, frame changes, undo/redo, and other Aseprite commands.
- Display zoom controls for keeping the CRT preview small in a corner or expanding it.
- Live CRT preview uses the same Old TV glow/mask/bloom pipeline at a reduced scale, with `HQ Once` for full-scale checks.
- Crop transparent bounds or preview the full canvas.
- Preserves settings between Aseprite sessions.
- Checks GitHub Releases for updates from inside Aseprite.

## Version 0.1.5

- Changed the CRT preview window live refresh to use the full Old TV renderer at a reduced scale instead of the simplified fast renderer.
- Added direct sprite `change` event listening so brush and eraser strokes refresh the preview instead of only command-level actions like undo/redo.
- Renamed `Fast Refresh` to `Live Refresh` to reflect that it now renders the real CRT pipeline.
- Recalibrated the default preset with stronger bloom/halation and an RGB fringe pass so the preview keeps the Old TV color leak instead of a clean CRT-only look.

## Version 0.1.4

- Reworked live preview refresh to use a lightweight CRT renderer instead of the full bloom pipeline on every edit.
- Added `HQ Once` for one-off full-quality preview checks without making brush strokes slow.
- Reduced the auto-refresh debounce to 0.10s because live refresh is now intentionally cheaper.

## Version 0.1.3

- Added debounced auto-refresh to the CRT preview window through Aseprite `sitechange` and `aftercommand` events.
- Added preview display zoom controls: `-`, `+`, `Small`, and `100%`.
- Changed the default CRT preview window zoom to 55% so it behaves more like a small corner preview.

## Version 0.1.2

- Added `Old TV Preview: CRT Preview Window`.
- Bound F7 to the CRT preview window, replacing the native Preview shortcut when the extension keymap is active.
- The preview window uses Aseprite's Lua canvas API, because extensions cannot replace the native Preview window render pipeline directly.

## Version 0.1.1

- Reworked the renderer order to match the approved app/game path more closely: CRT beam first, RGB emitter mask/scanline second, screen-space bloom after that.
- Transparent/backdrop pixels are no longer treated as lit emitters, which removes the odd colored border around sprites.
- Glow now comes from the masked/beam output instead of a source-space shortcut, so the preview keeps the dark matrix while still bleeding light into the backdrop.

## Commands

After installing and restarting Aseprite:

- `View > Old TV Preview: Render...`
- `View > Old TV Preview: CRT Preview Window`
- `View > Old TV Preview: Quick Render`
- `View > Old TV Preview: Check for Updates...`

Default shortcut:

- CRT Preview Window: `F7`
- macOS: `Cmd+Alt+V`
- Other platforms: `Ctrl+Alt+V`

## Install

Build the extension:

```sh
./build.sh
```

Install the generated file:

```text
dist/old-tv-preview.aseprite-extension
```

In Aseprite, use:

```text
Edit > Preferences > Extensions > Add Extension
```

Restart Aseprite after installing or updating.

On macOS you can also run:

```sh
./install-local.sh
```

## Notes

The preview intentionally keeps animation off. It bakes a single deterministic frame with emitter cells, dark matrix/backdrop, RGB slot emission, scanlines, composite color bleed, glow, warm faded blacks, background strips, and low noise.

For very large sprites, lower the scale before rendering. Aseprite Lua is CPU-bound, so the default scale is calibrated for pixel-art sprites rather than full-screen backgrounds.

## Build

```sh
./build.sh
```

The package is generated at:

```text
dist/old-tv-preview.aseprite-extension
```

## Release

```sh
git tag v0.1.5
git push origin main --tags
```

GitHub Actions will build the extension and attach `old-tv-preview.aseprite-extension` to the release.
