# PNG2ASS 1.1.1

PNG2ASS converts PNG images into ASS drawing lines through the `ass-png2ass` Python package.

Menu root: `PNG2ASS`

Namespace: `kite.PNG2ASS`

## Entries

- `PNG2ASS/PNG2ASS`
- `PNG2ASS/Install or Update Package`
- `PNG2ASS/Check Package`
- `PNG2ASS/Configure Package`

## Image conversion

PNG2ASS supports single PNG conversion and multi-image frame sequences. For sequences, select one or more timed dialogue lines and the same number of PNG files as covered frames. The macro maps one image to one frame and writes frame-by-frame ASS drawing lines.

The default mode is `auto`. It can detect alpha images, white-on-black mattes, dark-on-light mattes, and color images. Use `white-matte` explicitly for Mocha-style mattes where white is the visible shape and black is transparent.

## External package

The macro can install or update the Python package from the configured source. The default package source is `git+https://github.com/kiteroww/ass-png2ass.git`.

The package is installed as `ass-png2ass` and invoked as:

```bat
python -m ass_png2ass
```

## Configuration

Settings persist in `kite.PNG2ASS.conf` in the Aegisub user directory.
