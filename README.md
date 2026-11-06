# E8 for Nix

A flake that installs [E8](https://github.com/e8-editor/e8) from its releases, on Apple silicon Macs and on x86_64 Linux: `e8`, the editor in a terminal, and `e8-mcp`, and on a Mac `E8.app`, the editor in a window.

## nix-darwin

In your flake:

```nix
inputs.e8 = {
  url = "github:e8-editor/nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

and in the configuration, with `inputs` passed to it:

```nix
environment.systemPackages = [ inputs.e8.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

`darwin-rebuild switch` puts `e8` on the PATH and `E8.app` in `/Applications/Nix Apps`, where Spotlight and Launchpad find it. `nix flake update e8` brings it up to date. With home-manager, the same package goes in `home.packages`; `overlays.default` adds it to `pkgs` as `pkgs.e8`.

## Without a configuration

```bash
nix run github:e8-editor/nix -- some-file.txt
```

```bash
nix profile install github:e8-editor/nix
```

## How it follows releases

`release.json` holds the newest release's version, and the address and hash of each archive. A workflow here rewrites it each day with `update.sh`, from the checksums the release publishes, so the flake follows releases with nothing to do in E8's own repository. The package installs the archives as they are: the macOS binaries and app are signed and are not stripped, and on Linux the binaries are patched to find their libraries in the Nix store.

GPL-3.0-or-later, as E8.
