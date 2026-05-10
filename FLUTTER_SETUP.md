# Flutter Now-Playing Widget Setup

The CCMedia QML widget has been removed from the Control Center. Instead, use the standalone Flutter now-playing app.

## Setup Instructions

### 1. Ensure Flutter is installed
```bash
flutter --version
```

If not installed, install Flutter from https://flutter.dev/docs/get-started/install

### 2. Run the Flutter app

Navigate to the Flutter app directory and run:
```bash
cd /path/to/flutter/app
flutter run -d linux
```

Or build a release binary:
```bash
flutter build linux --release
```

Then run the binary:
```bash
./build/linux/x64/release/bundle/now_playing
```

### 3. Auto-start with your system (optional)

Create a `.desktop` file:
```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/now_playing.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Now Playing
Exec=/path/to/flutter/app/build/linux/x64/release/bundle/now_playing
StartupNotify=false
Terminal=false
EOF
```

Then add to your startup scripts or autostart folder.

### 4. Features

✅ Beautiful now-playing widget with album art
✅ Dynamic theme generation from album colors
✅ Smooth animations and transitions
✅ Full media controls (play/pause, next, previous)
✅ Progress bar with seek support
✅ Font cycling on album click
✅ Support for multiple media players (Spotify, MPD, Rhythmbox, VLC, etc.)
✅ Browser media playback (Firefox, Chrome, etc.)

## Notes

- The Flutter app runs as a standalone window (not embedded in the control center)
- Make sure `playerctl` is installed: `sudo apt install playerctl`
- The app will automatically detect and follow all media players via MPRIS
