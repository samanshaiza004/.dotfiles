# Pre-Phase-3 Prior-Art Audit

Date: 2026-08-22

Scope: the shell at commit `4271b42` before this audit, plus the small hardening
changes recorded below. Phase 3 features are intentionally excluded.

Runtime baseline:

- Quickshell `0.3.0` from the pinned nixpkgs input.
- Mango `0.16.1`, revision `813acaf41a921d9a417ea039635b4bda78473c7e`.
- Qt and Wayland behavior is therefore the pinned NixOS stack, not current
  upstream behavior by assumption.

Prior-art snapshots:

- DankMaterialShell source snapshot `4447d77` (v1.6-beta), MIT-licensed root
  source. Its December 2025 license-change note was checked before using it as
  a source of ideas.
- Noctalia Shell v4.7.7, commit `3abfa1fc`, MIT-licensed shell source. The
  related `noctalia-qs` runtime is a separate LGPL-3.0-only project and was
  not treated as ordinary Quickshell.
- KDE `plasma-workspace/libtaskmanager`, `plasma-pa`, and `plasma-nm` were
  consulted as behavioral authorities. Their implementation licenses vary;
  no KDE source was copied.

## Executive Findings

The current foundation is still the right one to build today. The important
architectural decisions survive the audit:

- Wayland `ToplevelManager` owns generic windows; Mango IPC owns tags only.
- PipeWire and Quickshell Networking remain native service boundaries.
- The popup dismissal overlay is the correct stack-specific workaround for
  the pinned Mango/Qt failure of `PopupWindow.grabFocus`.
- Oxygen remains the shell icon language while desktop entries own application
  identity.
- There is no reason to import DMS's daemon, Noctalia's custom runtime, or
  KDE's larger state machines into this shell.

The audit did identify concrete lifecycle issues that could infect Phase 3.
This phase fixes them:

- all current output nodes are bound by `PwObjectTracker`;
- unavailable audio is distinct from zero volume;
- network passwords and stale errors are cleared on popup close, success, and
  network destruction;
- supported PSK security types are separated from enterprise/OWE/unknown
  security instead of sending every protected network through `connectWithPsk`;
- clicking an already-connected Wi-Fi network requests disconnect rather than
  retrying an already active connection;
- title/app-id changes no longer rebuild the entire task model;
- malformed or non-object Mango JSON cannot throw from the tag handler;
- Mango open/close animation defaults are now 400ms/300ms.

The audit does not add grouping, pinning, launchers, notifications, recent
apps, settings storage, tag inference, or multi-monitor panel architecture.

### Follow-up runtime evaluation

After this audit baseline, upstream Quickshell `v0.3.1` was evaluated because
its changelog fixes crashes from freed objects laundered through `ScriptModel`,
crashes when `ScriptModel.values` changes during processing, Wi-Fi network
disappearance, child IPC calls after process relaunch, and
`Toplevel.unsetRectangle`. The current launcher uses a `Repeater` rather than
`ScriptModel`, but the runtime fixes are directly relevant to future filtered
launcher/model work.

Nixpkgs still exposes `0.3.0`, so the shell now uses a same-Qt `overrideAttrs`
build of the upstream `v0.3.1` tarball. The override was built successfully
against the pinned Qt 6.11.1 dependency graph, the binary reports `0.3.1`, and
the generated shell loads cleanly. This decision is recorded in
`nixos/modules/home/quickshell/quickshell.nix`.

The launcher also now handles `DesktopEntry.runInTerminal` explicitly: parsed
terminal commands are launched through the configured `ghostty -e` policy
instead of calling `DesktopEntry.execute()` and silently ignoring
`Terminal=true`.

## Current Architecture Inventory

| Subsystem | State owner | External boundary | Async/process boundary | Persistence | Main assumption or gap |
| --- | --- | --- | --- | --- | --- |
| Deployment/session | NixOS, Home Manager, Mango | Flake outputs, generated autostart | Mango starts Quickshell and swaybg | Flake locks only | Quickshell has no separate restart supervisor; wallpaper and monitor names are host-specific |
| Mango adapter | Mango; QML caches `monitors` | `mmsg watch all-tags`, `mmsg dispatch` | One persistent `WatchStream` and one-shot dispatch `Process` | None | Initial state is empty; dispatch has no completion/error model |
| Windows/tasks | Wayland compositor; `WindowService` facade | `ToplevelManager`, `DesktopEntries` | Native Wayland events and async desktop-entry scan | None | Requests are advisory; Mango does not currently publish parent relationships |
| Audio | PipeWire; `AudioService` derives UI state | `Pipewire`, `PwObjectTracker` | Native PipeWire model/signals | External WirePlumber/PipeWire preference | Nodes must be bound before audio properties are valid; device loss is asynchronous |
| Network | NetworkManager; `NetworkService` derives UI state | `Quickshell.Networking` | Native device/network signals | NetworkManager profiles | Link, activation, authentication, DHCP, and Internet connectivity are separate states |
| Popup/focus | `PopupWindow`, `PopupController`, panel | xdg popup, layer shell, `Region` mask | Native anchor/update turns and keyboard/mouse events | None | The dismissal overlay depends on screen-local geometry and pinned compositor input ordering |
| Calendar | `SystemClock`, `CalendarModel` | Quickshell `SystemClock` | Minute signal | None | Sunday-first and locale/timezone behavior are not configurable |
| Desktop identity/icons | `DesktopEntries`, Oxygen theme | XDG desktop entries and `Quickshell.iconPath` | Async desktop-entry scan | Nix package and XDG data dirs | App IDs can be inconsistent or absent; fallback is required |
| Panel/tray | Panel QML and SystemTray model | `PanelWindow`, StatusNotifier/Qt application menus | Native model and mouse events | None | Only the largest screen has a panel; tray menu focus is a separate path |
| Visual primitives | Local QML components | QtQuick/QtQuick.Effects | Property bindings and mouse signals | Theme constants in QML | No automated geometry/render tests exist |
| Settings/state | Nix declarations only | Home Manager and Mango config | Nix evaluation/build | No mutable shell state | This is intentionally deferred until there is a concrete preference requirement |

## Prior-Art Matrix

| Subsystem | Our implementation | DMS equivalent | Noctalia v4.7.7 equivalent | KDE/API authority | Important difference and edge case | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| Mango/session IPC | `WatchStream` plus `MangoBackend` for tags and dispatch | Capability-aware daemon/socket and subscriptions | Custom compositor/runtime services | Mango IPC and JSON process semantics | DMS's daemon is broader than our scope; our process boundary needs null/schema guards, not a daemon | **KEEP + HARDEN** |
| Window/task model | Native `ToplevelManager`, one task per native object, desktop-entry lookup | Task model with grouping, pinned apps, compositor-specific ordering | Taskbar with stable tile handling and later fixes beyond v4.7.7 | Plasma `libtaskmanager`, foreign-toplevel protocol | Native objects are the correct identity; requests have no acknowledgement and Mango lacks parent events | **KEEP + HARDEN** |
| Audio | Direct PipeWire facade and custom drag slider | Mature PipeWire facade with all-node tracking, ports, limits, and fallbacks | Audio service with tracker and later runtime fixes | `plasma-pa` state model and PipeWire/WirePlumber state | We do not need ports, stream routing, or wpctl fallback yet, but untracked output nodes were a real correctness gap | **ADAPT** |
| Network | Native NetworkManager devices/networks and compact menu | Defensive backend with capabilities, profiles, VPN/802.1x, and operation generations | Large `nmcli` service with scan/connect monitoring | `plasma-nm` and NetworkManager state machine | Native API is better here; PSK-only prompt and device-order summary are intentionally narrower | **KEEP + HARDEN** |
| Popups/focus | Native PopupWindow plus shared layer-shell dismissal overlay | `PopoutManager` with stale cleanup, focus policy, and per-screen state | Persistent full-screen click catcher and popout lifecycle | xdg popup/layer-shell focus and input-region protocols | DMS/Noctalia solve broader multi-screen/runtime cases; our overlay is the correct local adaptation | **KEEP + HARDEN** |
| Calendar | Small `SystemClock`-driven month model | Calendar surface with larger locale/settings scope | Locale-aware first-day and richer calendar cards | Qt locale/date APIs | A locale setting is not required by Phase 2 and would add state without a user need | **KEEP** |
| Desktop entries/icons | Exact ID, heuristic, startup-class fallback, Oxygen/application icon separation | Normalized/cached XDG and Flatpak-aware lookup | `NIcon`/custom icon runtime | Freedesktop desktop-entry/icon specifications | Our deterministic Oxygen policy is simpler; do not import custom icon fonts or shell filesystem scans | **KEEP** |
| Panel/tray | One primary panel, native SystemTray, shared visual primitives | Multi-screen and settings-heavy panels | Multi-screen panel services and custom runtime | PanelWindow, StatusNotifier, layer shell | Multi-monitor and tray focus are future scope; current panel is coherent and useful | **KEEP** |
| Settings/persistence | Declarative Nix only | Versioned settings/session/cache split | Settings and runtime state services | KDE config/state conventions | No current feature requires mutable state; adding it now would create Phase 3 surface area | **DEFER** |

## Failure History and Edge-Case Ledger

| Area | Upstream lesson or failure history | Can ours hit it? | Current response |
| --- | --- | --- | --- |
| Popup focus | DMS commit `0b526d9` fixed focus restoration pulling users back to a changed workspace; DMS issue `#2963` records the class of bug | Partly. Our overlay intentionally avoids grabFocus and does not restore focus | Keep no focus restoration; close on a real non-null app focus change, ignore the overlay's transient null focus |
| Popup geometry | DMS commit `1128745` fixed content-sized popouts opening clipped | Yes if menu size changes after open | `Popup.qml` updates the controller rectangle on width/height changes; monitor-edge and resize tests remain a gap |
| Popup reconnect | DMS commit `4a021a7` added layer-surface reconnect recovery | Possible on compositor restart | No local recovery yet; Quickshell reload/restart is the current recovery path and is documented as a remaining risk |
| PipeWire binding | DMS and Noctalia bind all relevant nodes; Noctalia runtime fixes `587f531` and `ecdc0b1` address QPointer/tracker teardown | Yes during USB/HDMI/Bluetooth churn | All current output nodes are tracked; runtime C++ fixes are not portable QML changes |
| Slider feedback | Noctalia fix `43fe1e194` addresses volume feedback behavior | Yes during external volume changes | Local slider emits only user drag events and displays later server state; rapid-drag integration remains a test gap |
| Network scanning | Noctalia fix `a62442104` prevents duplicate scan triggers | Not yet with one caller, but future callers could race | Current visibility ownership is retained; reference-counted scanning is deferred until a second scanner exists |
| Network credentials | Plasma-nm and Noctalia handle secret agents, cancellation, retries, and profiles | Yes for the current PSK prompt | Password is cleared on popup close; enterprise/OWE/unknown security is not falsely sent through PSK; a real secret agent is deferred |
| Network errors | DMS issues `#1921`, `#2460`, `#3068` show multi-adapter and selection/routing problems | Multiple active devices can still make summary order-sensitive | No fragile routing preference was added; primary-connection modeling is a later hardening item |
| Task identity | Plasma preserves task identity through title/activation changes; Noctalia later fixed task tile retention in `51576e3c4` | Yes if title changes while a task is hovered | Window model rebuild now depends on parent changes only; title/app-id bindings update delegates in place |
| Toplevel requests | Foreign-toplevel activate/minimize/close requests can be ignored | Yes | UI treats native properties as observed state; no acknowledgement or optimistic state is cached |
| Transient tasks | Protocol supports parent, but Mango's foreign-toplevel implementation currently does not set parent | Yes for dialogs under Mango | Parent filtering remains best effort and its compositor limitation is explicit; no title/app-id guessing was added |
| Object model mutation | Noctalia-qs fix `3f2f200` addressed reorder duplication | Not with current JS-array replacement models | No new ObjectModel was introduced; stable native object identity remains the task identity |
| Mango JSON | Valid JSON `null` or a primitive could reach `obj.all_tags` and throw | Yes after compositor restart or malformed output | Non-object values are ignored; missing/non-array `all_tags` becomes an empty tag state |
| Calendar rollover | Locale, leap-year, DST, timezone, and month-boundary cases are covered by mature calendar implementations | Yes, especially Sunday-first and timezone changes | Current minute clock is retained; locale-first-day and timezone test coverage are deferred |
| Icon discovery | DMS reports local/Flatpak icon edge cases; Noctalia uses runtime-specific caching | Yes when an entry disappears or icon is absent | `Quickshell.iconPath(name, fallback)` remains the fallback; no manual desktop-file scan was added |

## License and Provenance

No non-trivial third-party source code was copied or adapted in this phase.
The hardening changes are independent QML/Nix implementations informed by
behavioral study and public APIs.

| Project/reference | Revision | License | Use in this repository |
| --- | --- | --- | --- |
| DankMaterialShell | `4447d77` / v1.6-beta snapshot | MIT root; bundled assets and submodules require their own review | Read source/history and adopted ideas only: popup lifecycle, defensive service state, node tracking |
| Noctalia Shell | v4.7.7, `3abfa1fc` | MIT shell source | Read source/history and adopted ideas only: scan/retry/state edge cases |
| noctalia-qs | `d8327a7` runtime used by v4.7.7 | LGPL-3.0-only per Nix metadata; other covered components may carry GPL text | Not imported, vendored, or copied |
| KDE Plasma taskmanager/plasma-pa/plasma-nm | Current upstream references | LGPL/GPL/KDE-accepted variants by project/file | Behavioral authority only; no KDE source copied |
| Quickshell | pinned `0.3.0` | Upstream project license | Existing runtime dependency; APIs and source docs inspected |
| Mango | `813acaf...` | Upstream project license | Existing compositor dependency; foreign-toplevel implementation inspected |

Because no source or assets were adopted, no third-party attribution notice is
required beyond this audit record. `THIRD_PARTY.md` records the same boundary.

## Implemented Changes

### Animation defaults

BEFORE: Mango open/close durations were 180ms/140ms.

PRIOR ART: Mature desktop shells favor perceptible but bounded open/close
transitions; the existing shell already had the correct curve and animation
types.

AFTER: `animation_duration_open = 400` and `animation_duration_close = 300`.

WHY: Establishes the requested desktop defaults without changing curves,
layout, or any Phase 3 behavior.

PROVENANCE: Independent Nix configuration change.

### PipeWire output tracking

BEFORE: Only default and preferred sinks were bound, while the output selector
could expose other sink nodes.

PRIOR ART: DMS and Noctalia track relevant output nodes because `PwNode.audio`
is invalid for untracked nodes.

AFTER: Every current output node is included in `PwObjectTracker`, with
duplicate suppression for default/preferred nodes.

WHY: Makes device state valid through output selection and hotplug changes.

PROVENANCE: Independently implemented from ordinary Quickshell 0.3.0 APIs; no
DMS/Noctalia code copied.

### Network operation state

BEFORE: Every protected unknown network could enter a PSK prompt, connected
rows retried `connect()`, and password/error objects could survive dismissal
or removal.

PRIOR ART: Plasma-nm and Noctalia distinguish connection states and credential
capabilities; Noctalia history records scan and teardown races.

AFTER: PSK prompts are limited to WPA-PSK/WPA2-PSK/SAE, connected rows request
disconnect, signal/known/security changes invalidate sorting, and credentials
and errors clear on close, success, and network destruction.

WHY: Prevents invalid backend calls and stale secret/error UI without adding a
secret-agent subsystem.

PROVENANCE: Independent implementation from Quickshell Networking enums and
signals.

### Task model stability

BEFORE: Title and app-id changes incremented the revision used to rebuild the
filtered task array, potentially recreating every task delegate.

PRIOR ART: Plasma taskmanager and later Noctalia taskbar fixes preserve tile
identity through title/active changes.

AFTER: Only parent changes invalidate the filtered array; title and app-id
changes update existing delegates through direct bindings.

WHY: Keeps hover, tooltip, and button geometry stable while a window title
changes.

PROVENANCE: Independent QML change.

### Mango JSON guard

BEFORE: A valid JSON primitive could reach `obj.all_tags` and throw.

PRIOR ART: Mature IPC layers validate message shape before deriving model state.

AFTER: Non-object messages are ignored and non-array tag payloads become an
empty state.

WHY: Makes compositor restart/malformed-output behavior deterministic.

PROVENANCE: Independent QML change.

## Rejected or Deferred Changes

- No DMS daemon or custom IPC socket: Mango tag scope is small and the existing
  `mmsg` boundary is clear.
- No Noctalia-qs runtime or C++ code: it is not the pinned ordinary Quickshell
  runtime and carries separate licensing obligations.
- No KDE source: Plasma's richer task/audio/network requirements exceed this
  shell's current scope and its file-level licensing varies.
- No `wpctl`/`pactl` fallback: no reproduced stale PipeWire value requires the
  extra subprocess boundary.
- No NetworkManager secret agent: the current phase has a bounded PSK prompt;
  enterprise, captive portal, VPN, and profile management belong to a later
  explicit scope.
- No tag inference from toplevels: Mango does not expose a reliable generic
  join and title/app-id matching would be fragile.
- No task grouping, pinning, recent apps, launcher, settings, or per-monitor
  panel architecture.
- No locale-first-day calendar setting: there is no current user preference or
  persistence model to own it.
- No popup focus restoration or null-focus close: the dismissal overlay itself
  causes a transient focus transition on this pinned stack; closing only on a
  different non-null application is the verified safe rule.

## Test Gap Analysis

There is no existing QML unit-test, Nix check, CI, or fixture framework. This
phase adds `tests/quickshell-smoke.sh`, an integration smoke test that launches
the pinned shell for a short interval and fails on configuration-load errors,
QML reference errors, or unavailable types. It is intentionally a live
Wayland test rather than a fake screenshot test.

The following state-transition tests remain recommended before a larger future
phase:

- PipeWire unavailable, reconnect, default sink removal/re-add, external
  volume changes, Bluetooth profile changes, and rapid slider drag.
- Network device removal/re-add, scan cancellation, wrong PSK/retry, DHCP
  failure, unsupported security, disappearing password target, and multiple
  active devices.
- Toplevel add/remove/re-add, title/app-id mutation, transient dialog behavior
  under Mango, denied activation, rapid minimize clicks, monitor removal, and
  compositor restart.
- Popup repeated open/close, Escape, outside click, focus transition, popup
  resize, screen edge, screen removal, and tray-menu interaction.
- Mango initial snapshot, malformed JSON, EOF/restart, missing `mmsg`, and
  rapid dispatch.
- Calendar leap years, January/December rollover, timezone changes, and
  locale-first-day behavior.

## Remaining Risks

- Mango currently does not publish foreign-toplevel parent relationships, so
  transient filtering cannot be proven for GTK/Firefox dialogs on this
  compositor.
- Foreign-toplevel actions are advisory and have no acknowledgement channel.
- Popup input geometry remains stack-specific and is only validated on the
  current top-panel/single-primary-panel arrangement.
- Network summary still chooses connected devices in list order rather than a
  NetworkManager primary-connection model.
- Quickshell and `mmsg` are not independently supervised after Mango startup.
- The fixed host wallpaper and monitor names remain intentional host policy.

## Phase-3 Readiness Verdict

Knowing what DMS, Noctalia v4, KDE Plasma, and the underlying Linux APIs have
already learned, this is still a foundation we would choose to build today.

The evidence is that the local boundaries match the underlying authorities and
the audit improvements address concrete lifecycle gaps without importing a
larger shell architecture. The remaining risks are explicit scope decisions
or compositor/runtime limitations, not hidden duplication that Phase 3 would
immediately amplify. Phase 3 should begin only after the live state-transition
tests above are exercised for the intended target hardware.
