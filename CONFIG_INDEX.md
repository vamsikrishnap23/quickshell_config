# Quickshell Config Index

Last indexed: 2026-05-10
Root: `/home/vamsi/.config/quickshell`

## 1) High-level architecture

- Entry point: `shell.qml`
- Main UI surface: `modules/TopBar.qml` (`PanelWindow` anchored top-left-right)
- Overlay surface: `modules/Powermenu.qml` (`PanelWindow` full-screen, toggled by global state)
- Shared styling/state singletons: `styles/Theme.qml`, `styles/GlobalState.qml` via `styles/qmldir`
- Reusable primitive: `components/Pill.qml`
- Widgets used by top bar:
  - `widgets/LeftSection.qml` -> `Workspaces.qml` + `Time.qml`
  - `widgets/MediaInfo.qml`
  - `widgets/SystemInfo.qml`

## 2) Composition tree

```text
shell.qml
├── TopBar (modules/TopBar.qml)
│   ├── LeftSection (widgets/LeftSection.qml)
│   │   ├── Workspaces (widgets/Workspaces.qml)
│   │   └── Time (widgets/Time.qml)
│   ├── MediaInfo (widgets/MediaInfo.qml)
│   └── SystemInfo (widgets/SystemInfo.qml)
└── Powermenu (modules/Powermenu.qml)
```

## 3) File-by-file index

### `shell.qml`
- Creates `ShellRoot` with `TopBar {}` and `Powermenu {}`.
- No logic beyond module composition.

### `modules/TopBar.qml`
- Transparent `PanelWindow`, implicit height `48`.
- Layout:
  - Left: `LeftSection` (margin left 18, top 8)
  - Center: `MediaInfo`
  - Right: `SystemInfo` (margin right 18, top 8)

### `modules/Powermenu.qml`
- Full-screen overlay `PanelWindow`.
- Visibility controlled by `GlobalState.showPowermenu`.
- Background click closes menu.
- Defines `Process` commands:
  - `systemctl poweroff`
  - `systemctl reboot`
  - `hyprctl dispatch exit`
- UI: 3 `Pill` icon buttons (shutdown/reboot/logout).

### `components/Pill.qml`
- Rounded rectangle base component.
- Exposes `default property alias content: container.data`.
- Provides consistent look:
  - background from `Theme.background`
  - subtle border
  - margin-wrapped content container

### `styles/Theme.qml`
- Singleton style token source.
- Defines:
  - Colors (`background`, `surface`, `primary`, `secondary`, `text`, `textDim`, `border`)
  - Sizes (`radius`, `gap`, `padding`, `barHeight`)
  - Animation durations (`fastAnim`, `normalAnim`)

### `styles/GlobalState.qml`
- Singleton global runtime state.
- Current state:
  - `showPowermenu: bool`

### `widgets/LeftSection.qml`
- Simple `Row` composing:
  - `Workspaces {}`
  - `Time {}`

### `widgets/Workspaces.qml`
- Uses `Quickshell.Hyprland`.
- Renders workspace indicators from `Hyprland.workspaces`.
- Active workspace indicator animates width.
- Click dispatches: `Hyprland.dispatch("workspace " + modelData.id)`.

### `widgets/Time.qml`
- Displays `hh:mm` using `Qt.formatTime`.
- `Timer` refresh interval: `5000ms`.

### `widgets/MediaInfo.qml`
- Uses `Quickshell.Services.Mpris`.
- Picks current player:
  - first `Playing` player
  - fallback first player in list
- Widget visible only while selected player is `Playing`.
- Displays title/artist, elided to available width.

### `widgets/SystemInfo.qml`
- Uses:
  - `Quickshell.Networking`
  - `Quickshell.Services.UPower`
  - `Quickshell.Services.Pipewire`
  - `Quickshell.Bluetooth`
- Shows pills for:
  - Wi-Fi (`wifiLabel` via `Instantiator` over network devices/networks)
  - Volume (`volumeLabelText` via sink audio + optional connected BT audio device name)
  - Battery (`batteryLabelText` from display device)
  - Powermenu toggle button (`GlobalState.showPowermenu`)
- Tracks sink object with `PwObjectTracker`.

## 4) Service dependency map

- `Hyprland` -> `widgets/Workspaces.qml`
- `Mpris` -> `widgets/MediaInfo.qml`
- `Networking` -> `widgets/SystemInfo.qml`
- `Pipewire` -> `widgets/SystemInfo.qml`
- `UPower` -> `widgets/SystemInfo.qml`
- `Bluetooth` -> `widgets/SystemInfo.qml`
- `GlobalState` -> `widgets/SystemInfo.qml`, `modules/Powermenu.qml`
- `Theme` -> nearly all visual components

## 5) Behavior notes and likely fix hotspots

1. `widgets/SystemInfo.qml`
- Uses nested `Instantiator` to infer wifi state from networks. This can miss transitions in some setups (e.g., roaming/hidden SSIDs/device resets).
- Bluetooth label enrichment depends on icon-name matching (`audio/headset/headphone/speaker`) and may fail for unusual icon strings.
- Uses `GlobalState` without explicit module version import; works with local singleton path import, but keep this consistent everywhere.

2. `widgets/MediaInfo.qml`
- Only visible while state is `Playing`; paused media disappears entirely (might be desired or not).
- Player resolution is computed property style; if you later need richer behavior (play/pause controls), consider explicit state and Connections.

3. `widgets/Time.qml`
- Refreshes every 5s while showing minute precision. Fine, but not synchronized exactly to minute boundary.

4. `modules/Powermenu.qml`
- Hard-codes `hyprctl dispatch exit` for logout (Hyprland-specific).
- No keyboard shortcut handling (Escape to close) yet.

## 6) Fast extension points

- Add quick toggles (BT/Wi-Fi/DND): `widgets/SystemInfo.qml`
- Add calendar popup: `widgets/Time.qml`
- Add media controls/artwork: `widgets/MediaInfo.qml`
- Add workspace labels/urgent indicators: `widgets/Workspaces.qml`
- Add more global UI states (control center visibility, notifications): `styles/GlobalState.qml`
- Add theming variants: `styles/Theme.qml`

## 7) Suggested next implementation steps

1. Stabilize `SystemInfo` event handling first (wifi/volume/battery are most dynamic).
2. Decide desired media behavior for paused state and implement in `MediaInfo`.
3. Add keyboard close path to `Powermenu` (Escape) and optional animations.
4. If adding multiple panels/popups, extend `GlobalState` with named booleans and keep all visibility there.
