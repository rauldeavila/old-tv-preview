# Old TV Preview

Aseprite extension that renders a static LIGHTWARD-style Old TV CRT preview from the active sprite/frame.

This is a CPU/Lua preview tool, not a live GPU shader. It creates a new preview sprite so the original art remains untouched.

## Features

- Render the active frame through an Old TV CRT approximation.
- Uses the LIGHTWARD `july_teste_01` preset as the default.
- Includes `Reference Match` and `Color Leak` preset variants.
- Optional side-by-side comparison with nearest-neighbor raw upscale.
- Crop transparent bounds or preview the full canvas.
- Preserves settings between Aseprite sessions.
- Checks GitHub Releases for updates from inside Aseprite.

## Commands

After installing and restarting Aseprite:

- `View > Old TV Preview: Render...`
- `View > Old TV Preview: Quick Render`
- `View > Old TV Preview: Check for Updates...`

Default shortcut:

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
git tag v0.1.0
git push origin main --tags
```

GitHub Actions will build the extension and attach `old-tv-preview.aseprite-extension` to the release.
