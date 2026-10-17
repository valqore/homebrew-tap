# valqore/homebrew-tap

The official Homebrew tap for [Valqore QED](https://github.com/valqore/qed) — a
self-hosted policy and evidence kernel for AI-agent actions.

```sh
brew tap valqore/tap
brew install qed
qed demo
```

## Nothing here works yet

`valqore/qed` is still private, so the release URLs in `Formula/qed.rb` are a
404 for everybody, including you. This repository is private for the same
reason: it reserves the tap name without publishing a formula that would fail.
Both repositories go public together.

If you are reading this after that has happened, the three commands above are
the whole install.

## The formula is generated

`Formula/qed.rb` is `deploy/homebrew/qed.rb.template` in `valqore/qed`, with the
version and the three SHA-256 checksums filled in by
`deploy/homebrew/render.sh`. Edit the template there, never this copy: the
binary and the formula that installs it are meant to change together, and a
hand-edit here is a second source of truth that will disagree with the first
one at the worst possible moment.

The checksums come from the `.sha256` files CI writes beside each binary in the
release, not from a local build. A locally computed hash proves only that you
hashed your own build; the checksum exists to prove the file Homebrew downloads
is the file CI produced.

## Platforms

One bottle per platform, because PyInstaller freezes the interpreter it runs on
and there is no cross-compilation:

| Platform | Asset |
|---|---|
| macOS arm64 | `qed-<version>-macos-arm64` |
| macOS x86_64 | `qed-<version>-macos-x86_64` |
| Linux x86_64 | `qed-<version>-linux-x86_64` |

macOS binaries are **not notarised yet**, so Gatekeeper will warn on first run.

`qed serve` works from the binary, but for a long-running process the container
(`ghcr.io/valqore/qed`) is the better artifact: it is the one that carries an
SBOM and a cosign signature.

## Licence

The formula is Apache-2.0, like QED itself.
