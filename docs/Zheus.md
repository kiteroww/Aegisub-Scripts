# Zheus Colormanager 4.4.1

Zheus manages actor colors, solid ASS colors, VSFilterMod corner colors, replacement workflows, persistent color changes, and accessibility-oriented palettes.

Menu root: `Zheus Colormanager`

Namespace: `kite.Zheus`

Zheus is a standalone top-level macro.

## Main entries

- `Zheus Colormanager`
- `: Kite Hotkeys :/Zheus Colormanager/Colores`
- `: Kite Hotkeys :/Zheus Colormanager/VSF`
- `: Kite Hotkeys :/Zheus Colormanager/Actores`
- `: Kite Hotkeys :/Zheus Colormanager/Cambiar colores`
- `: Kite Hotkeys :/Zheus Colormanager/ColorRelay`
- Accessibility audit, profile application, calibration, and palette export beneath `: Kite Hotkeys :/Zheus Colormanager/Daltonismo/...`

## Current notes

- `ColorRelay` applies persistent color changes over frame events and transform windows.
- The main panel uses compact manager/change selectors and stays as a top-level macro.
- Zheus declares no additional modules; DependencyControl is used for update registration.

## Local data

Existing color-manager and accessibility settings remain local in the Aegisub user directory.
