# Third-Party Provenance

The repository does not currently contain copied or adapted source code from
DMS, Noctalia, KDE Plasma, or their bundled assets. Those projects were
consulted for behavioral prior art during the pre-Phase-3 audit documented in
`docs/audits/pre-phase-3-prior-art.md`.

Existing runtime/package dependencies remain upstream dependencies:

- Quickshell `0.3.1` (same-Qt local nixpkgs override)
- Mango `0.16.1`
- KDE Oxygen icons from nixpkgs
- Matugen `4.1.0` from nixpkgs
- PipeWire, WirePlumber, NetworkManager, Wayland protocols, and Qt

License and revision notes for the audited projects are recorded in the audit
document. If future work copies non-trivial code or assets, add the exact
source file, revision, license, modification status, and attribution here
before merging it.
