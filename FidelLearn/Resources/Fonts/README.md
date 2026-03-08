# FidelLearn Fonts

## Noto Sans Ethiopic

This app uses **Noto Sans Ethiopic** for proper Ge'ez/Tigrinya character display.

### Setup

1. Download Noto Sans Ethiopic from [Google Fonts](https://fonts.google.com/noto/specimen/Noto+Sans+Ethiopic)
2. Extract the font package and locate `NotoSansEthiopic-Regular.ttf`
3. Add `NotoSansEthiopic-Regular.ttf` to this folder: `FidelLearn/Resources/Fonts/`
4. Ensure the font is added to the Xcode project and included in the app target's "Copy Bundle Resources" build phase

### Info.plist Registration (Tuist Projects)

This project uses **Tuist** for project generation. The Info.plist is generated at `Derived/InfoPlists/FidelLearn-Info.plist`.

To register custom fonts, add the `UIAppFonts` (Fonts provided by application) key in your Tuist `Project.swift` target's `infoPlist` configuration:

```swift
infoPlist: [
    "UIAppFonts": ["Fonts/NotoSansEthiopic-Regular.ttf"]
]
```

Alternatively, if you maintain a custom Info.plist template, add:

```xml
<key>UIAppFonts</key>
<array>
    <string>Fonts/NotoSansEthiopic-Regular.ttf</string>
</array>
```

The font path is relative to the app bundle root (e.g. `Fonts/NotoSansEthiopic-Regular.ttf` assumes the font is in a `Fonts` folder in the bundle).
