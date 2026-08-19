# saman's NixOS dotfiles

NixOS configuration for `desktop` (hostname `nixos`), managed as a flake with
Home Manager.

## Layout

```
nixos/
├── flake.nix                    # inputs: nixpkgs, mango, home-manager
├── flake.lock                   # committed: pins exact input revisions
├── hosts/
│   └── desktop/                 # one complete machine definition per host
│       ├── configuration.nix    # host imports + base system config
│       └── hardware-configuration.nix  # committed: detected devices/FS
├── home/
│   └── saman/
│       └── home.nix             # Home Manager config (mango, imports)
├── modules/
│   ├── nixos/                  # system-level modules (one concern each)
│   │   ├── mango.nix           # compositor enable/package
│   │   ├── home-manager.nix    # HM wiring for saman
│   │   └── networking.nix      # hostname, NetworkManager, firewall
│   └── home/                   # per-program home modules
│       ├── mango.nix           # mango settings, bindings, monitor rules
│       └── ghostty.nix
└── README.md
```

## Rebuild

`/etc/nixos` is a symlink to `~/.dotfiles/nixos`:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#saman
```

## Rules

- **Commit `flake.lock`** — it pins exact inputs so the repo rebuilds against
  the same revisions.
- **Commit `hardware-configuration.nix`** — it's this host's detected
  devices/filesystems; `hosts/desktop/` is a complete machine definition.
- **No secrets in `.nix` files** — flake contents enter the Nix store, which
  can be world-readable. No passwords, tokens, SSH keys, Wi-Fi passwords.
- **`git add` before `nix` evaluation** — git-backed flakes only see tracked
  files; new files are invisible until staged.
- **Review `git diff --cached` before pushing** — never blind `git add .`
  when secrets matter.
- **`home-manager.useGlobalPkgs = true`** and the home-manager nixpkgs input
  follows the main `nixpkgs` input, avoiding duplicate package universes.
