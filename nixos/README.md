# NixOS Desktop Configuration

This repository contains a NixOS desktop configuration built as a flake with
Home Manager. It targets an x86_64 Wayland desktop using Mango as the
compositor, Ghostty as the terminal, Fish as the login shell, and Quickshell
for the panel and launcher.

It is a complete machine configuration rather than a hardware-independent
module. Review the machine-specific values before applying it to another
computer.

## Requirements

- NixOS on x86_64 Linux
- Flakes and the `nix-command` enabled
- A user with `sudo` access
- Git and network access for flake inputs
- A Wayland-capable graphics setup

The flake follows the unstable `nixpkgs` channel and fetches Mango and
Home Manager from GitHub. The lock file pins the exact input revisions.

## Install

Clone the repository and inspect the host files:

```sh
git clone https://github.com/samanshaiza004/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles/nixos
```

Before the first activation, customize these values:

- `hosts/desktop/hardware-configuration.nix`: replace it with the hardware
  configuration generated for the target machine.
- `hosts/desktop/configuration.nix`: change the username, description, time
  zone, keyboard, hostname, and user groups as needed.
- `home/saman/home.nix`: change `home.username` and `home.homeDirectory`.
- `flake.nix` and `modules/nixos/home-manager.nix`: change the configuration
  output and Home Manager user name if the user is not `saman`.
- `modules/home/mango.nix`: update monitor rules and the startup wallpaper.
- `modules/home/matugen.nix`: update the wallpaper used during activation.
- `modules/home/ghostty.nix`: update the absolute Ghostty config path if the
  home directory changes.

Search for remaining machine-specific paths before activation:

```sh
rg -n 'saman|/home/saman|schoolrumble1|DP-3|HDMI-A-1|America/Chicago' .
```

If `/etc/nixos` is not already linked to this checkout, preserve the existing
directory and link the flake directory:

```sh
sudo mv /etc/nixos /etc/nixos.before-dotfiles
sudo ln -s "$HOME/.dotfiles/nixos" /etc/nixos
```

Build the system before activating it:

```sh
nix build .#nixosConfigurations.saman.config.system.build.toplevel --no-link
```

Activate the configuration:

```sh
sudo nixos-rebuild switch --flake .#saman
```

Start a new login session after activation so the Fish login shell is used.

## Daily Commands

Rebuild after changing the configuration:

```sh
cd ~/.dotfiles/nixos
sudo nixos-rebuild switch --flake .#saman
```

Test a build without changing the running system:

```sh
nix build .#nixosConfigurations.saman.config.system.build.toplevel --no-link
```

Roll back to the previous system generation:

```sh
sudo nixos-rebuild switch --rollback
```

Set a new wallpaper and regenerate the derived colors:

```sh
wallpaper-set /path/to/wallpaper.jpg
```

The command updates swaybg, rewrites Ghostty's generated color file, reloads
Ghostty when its user service is available, and lets Quickshell reload its
watched palette JSON.

## How It Works

The configuration has three layers:

1. NixOS defines the host, boot settings, networking, Fish installation,
   default login shell, system packages, and Mango login entry.
2. Home Manager defines user programs and files for Fish, Mango, Ghostty,
   Matugen, Quickshell, Firefox, and OpenCode.
3. The Quickshell and Matugen modules provide the runtime wallpaper and shell
   color pipeline.

The flake entry point is `flake.nix`. It creates the `saman` system from
`hosts/desktop/configuration.nix`, adds the Mango NixOS module, and wires Home
Manager through `modules/nixos/home-manager.nix`.

## Shell

Fish is enabled at both layers:

- `programs.fish.enable` installs and registers Fish with NixOS.
- `users.users.saman.shell` makes Fish the user's login shell.
- Home Manager disables the default Fish greeting.

The Fish setup is intentionally minimal. Add aliases, functions, and prompt
customization to `home/saman/home.nix` or a dedicated Home Manager module.

## Wallpaper Color Pipeline

Matugen is used as a color extractor, not as the desktop design system.

1. Matugen selects ranked source color `0` as the canonical wallpaper accent.
2. The palette template writes that accent to
   `~/.config/quickshell/generated/palette.json`.
3. Quickshell watches the JSON file and uses the accent only for glass tinting
   and focus glow. Graphite surfaces, text, Oxygen blue selection, and urgent
   colors remain fixed.
4. `ghostty-palette-generator` asks Matugen for ranked candidates `0..4`.
5. Candidates are classified in OKLCH by hue, chroma, and lightness.
6. Only suitable candidates replace compatible ANSI semantic slots. Red,
   green, yellow, blue, purple, and cyan each have fixed fallbacks.
7. Bright variants are lightened only when a wallpaper candidate was accepted.
8. Ghostty's generated file is written atomically to
   `~/.config/ghostty/config-colors`.

Ghostty keeps its near-black background, stable foreground, black/white
endpoints, and semantic fallback colors. Cursor and selection colors use the
canonical wallpaper accent with contrast-aware selection text.

## Quickshell

Quickshell is built from upstream version 0.3.1 against the exact Qt/private
API dependency set from the pinned nixpkgs revision. Its configuration provides
the Mango panel, task strip, launcher, start menu, calendar, audio, network,
and window services.

Generated QML palette files are not used. The runtime boundary is the watched
`palette.json` file and `ColorService.qml`.

## SDDM Login

SDDM is the system authentication and session manager. Its greeter runs on
stable X11, while the selected logged-in session is Mango on Wayland:

```text
SDDM X11 greeter -> Mango Wayland session -> Home Manager -> Quickshell
```

The login theme is packaged declaratively by `modules/nixos/sddm.nix` and
installed as the `late2000s` SDDM theme. It uses an independent Qt6 QML
runtime and does not import Quickshell modules or read user-session files.
The background is a deterministic graphite gradient rather than the user's
wallpaper, so authentication remains available before Home Manager starts.

Mango is registered through the existing NixOS Mango module, which contributes
the `mango.desktop` Wayland session. `services.displayManager.defaultSession`
preselects that session without creating a duplicate desktop entry.

Test the packaged theme without changing the active display manager:

```sh
bash tests/sddm-theme-test.sh
```

If a display-manager change prevents graphical login, switch to a TTY with
`Ctrl+Alt+F3`, log in, and roll back the last generation:

```sh
sudo nixos-rebuild switch --rollback
sudo systemctl restart display-manager
```

## Layout

```text
nixos/
├── flake.nix                         # system entry point and inputs
├── flake.lock                        # pinned input revisions
├── hosts/desktop/                    # machine definition and hardware
├── home/saman/home.nix               # Home Manager user definition
├── modules/nixos/                    # host-level modules
├── modules/home/                     # user-level program modules
├── tests/                            # shell, launcher, and palette tests
└── README.md
```

Useful implementation files include:

- `modules/home/mango.nix`: compositor settings, bindings, startup, and
  `wallpaper-set`.
- `modules/home/matugen.nix`: palette activation and generator package.
- `modules/home/matugen/ghostty-palette-generator.py`: ranked-color
  classification and atomic Ghostty palette generation.
- `modules/home/quickshell/shell/style/Theme.qml`: fixed semantic theme and
  wallpaper accent bindings.
- `modules/home/quickshell/shell/services/ColorService.qml`: watched palette
  service.

## Tests

Run the deterministic checks from the repository root:

```sh
bash tests/launcher-search-test.sh
bash tests/quickshell-smoke.sh
bash tests/color-service-test.sh
bash tests/ghostty-palette-generator-test.sh
```

Review staged changes before committing. New files must be staged before flake
evaluation because Git-backed flakes only expose tracked files:

```sh
git diff
git add -A
git diff --cached
```

## Safety

- Never commit passwords, tokens, SSH keys, Wi-Fi credentials, or other
  secrets. Flake contents can enter the world-readable Nix store.
- Keep `flake.lock` committed so builds use reproducible input revisions.
- Keep hardware configuration specific to the target machine.
- Review monitor rules, wallpaper paths, absolute home paths, and firewall
  settings before applying this configuration elsewhere.
