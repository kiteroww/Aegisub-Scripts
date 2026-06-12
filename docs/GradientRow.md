# Gradient Row 1.6.0

Gradient Row creates adaptive ASS color gradients across selected lines or visible characters.

Menu root: `Gradient Row`

Namespace: `kite.GradientRow`

## Modes

- Horizontal, Vertical, and Rotated modes create clipped duplicate lines and comment the source line.
- Char Line applies a character gradient separately to each selected line.
- Char Selection distributes one character gradient across the entire selection.
- `Use colors between letters` can interpolate between usable inline color states.

## Geometry and output

Gradient Row can use rectangular clips, vector clips, ASSFoundation bounds, perspective-projected geometry, optional SubInspector bounds, and text-size fallbacks. Output uses standard ASS color and clip tags rather than VSFilterMod `vc` tags.

The macro stores its local interface state in `kite.GradientRow.conf` and registers through DependencyControl while retaining its selection validator.
