# Scripts

Helper utilities for the wolfram skill.

## Currently Available

- `export-manipulate-gif.wl` — Reusable high-quality GIF exporter for physics animations and Manipulate-derived demos.

  Drop it into any notebook and use:

  ```wolfram
  ExportPhysicsGIF[frameFunction, {t, tmin, tmax, step}, "output.gif",
    "Duration" -> 8, ImageResolution -> 200]
  ```

  This saves people from fighting with `Export`, frame rates, and looping options every single time.

## Future Ideas

- Batch renderer for multiple parameter sets
- Notebook → clean .wl extractor
- Simple validation linter for common physics code anti-patterns (e.g. NDSolve inside Manipulate body)
- Color map / style preset library for consistent publication figures

Contributions welcome.
