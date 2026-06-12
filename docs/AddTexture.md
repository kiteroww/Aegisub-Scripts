# AddTexture 2.0.1

AddTexture applies pasted ASS drawing textures clipped to selected text outlines.

Menu root: `AddTexture`

Namespace: `kite.AddTexture`

## Input

- Raw ASS drawings and drawing text.
- `Dialogue:` or `Comment:` lines containing drawing material.
- Vector clips or `{\pN}` drawing payloads copied from existing lines.

## Output

- Creates drawing layers above selected non-comment lines.
- Fits the full texture composition to each selected text outline.
- Uses the selected line color as fallback unless `Preserve colors` is enabled.
- Can cut the fitted texture to the text shape and add extra override tags.

## Configuration and updates

Settings persist through ConfigHandler in `kite-addtexture.json`. The script registers through DependencyControl for updates while keeping its top-level menu entry.

The interface text is English.
