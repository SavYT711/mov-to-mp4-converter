# MOV to MP4 Converter — Windows Explorer Right-Click

Convert `.mov` (and optionally `.avi`/`.mkv`/`.wmv`/`.flv`) files to `.mp4` straight from the right-click menu in Windows Explorer, powered by [ffmpeg](https://ffmpeg.org/).

Download the installer from the [Releases page](../../releases/latest), pick your options, and you're done — right-click a video file, choose **Convert to MP4**.

## Install

1. Grab `MovToMp4Converter-Setup.exe` from the [latest release](../../releases/latest).
2. Run it. No admin rights needed — it installs per-user.
3. Choose your options:
   - **Add "Convert to MP4" for .mov files** (on by default)
   - **Also add it for .avi, .mkv, .wmv, .flv** (off by default)
   - **Default quality**: Fast / Balanced (default) / High quality
4. If ffmpeg isn't found on your PATH, the installer will tell you at the end — see [Prerequisites](#prerequisites) below.

That's it. Right-click a video file → **Convert to MP4** → a console window shows ffmpeg running → the `.mp4` is saved next to the original.

## Prerequisites

The installer doesn't bundle ffmpeg (it's a large, separately-licensed binary), so you need it on your `PATH`:

```
winget install ffmpeg
```

or `choco install ffmpeg`, or download it manually from [ffmpeg.org](https://ffmpeg.org/download.html). Verify with `ffmpeg -version` in a new terminal.

## Uninstall

Use **Settings → Apps → MOV to MP4 Converter → Uninstall**, or find it in "Add or Remove Programs". This cleanly removes the context menu entries it added.

## Changing quality after install

The installer writes your chosen preset to `config.ini` next to `convert-to-mp4.bat` in the install folder (`%LocalAppData%\Programs\MovToMp4Converter` by default). Edit `Quality=` in that file to `fast`, `balanced`, or `high` at any time — no reinstall needed.

| Preset   | ffmpeg settings              | Notes                          |
|----------|-------------------------------|---------------------------------|
| fast     | `-preset veryfast -crf 23`    | Smaller files, faster, lower quality |
| balanced | `-preset medium -crf 18`      | Good default tradeoff           |
| high     | `-preset slow -crf 16`        | Larger files, slower, best quality |

## Manual install (no installer)

If you'd rather not run an installer, clone the repo and use the scripts in `manual/` directly:

```powershell
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>\manual
powershell -ExecutionPolicy Bypass -File install-context-menu.ps1
```

This registers the same right-click entry, using `src/convert-to-mp4.bat`, defaulting to balanced quality (no `config.ini`). Run `uninstall-context-menu.ps1` the same way to remove it.

## Project layout

```
src/            convert-to-mp4.bat — the actual conversion logic
installer/      setup.iss — Inno Setup script that builds the installer
manual/         install/uninstall PowerShell scripts for the no-installer route
.github/workflows/release.yml — builds setup.iss and publishes it to Releases on tag push
```

## Cutting a release (for maintainers)

Releases are built automatically by GitHub Actions using [Inno Setup](https://jrsoftware.org/isinfo.php). To publish a new version:

1. Bump `MyAppVersion` in `installer/setup.iss`.
2. Commit, then tag and push:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The `release.yml` workflow builds `MovToMp4Converter-Setup.exe` on a Windows runner and attaches it to a new GitHub Release automatically.

You can also trigger a build manually from the Actions tab (`workflow_dispatch`) without publishing a release, to sanity-check the build.

To build locally instead: install [Inno Setup](https://jrsoftware.org/isdl.php), then run:
```
ISCC.exe installer\setup.iss
```
The output `.exe` lands in `installer\Output\`.

## Publishing this repo to your own GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

Update the URL placeholders in this README and in `installer/setup.iss` (`MyAppURL`, `MyAppPublisher`) with your own repo/name, and the year/name in `LICENSE`.

## Notes / limitations

- Registers per-user (`HKCU`) only — no admin rights required, and it won't affect other accounts on the same PC.
- Selecting multiple files and using the context menu entry launches one conversion window per file.
- Video is re-encoded with H.264 (`libx264`) and audio with AAC — a broadly compatible, high-quality combination.

## License

MIT — see [LICENSE](LICENSE).
