# Homebrew formula for the `qed` single-file binary (SPEC §24.1).
#
# ## Generated, not written
#
# This file is `deploy/homebrew/qed.rb.template` in valqore/qed, rendered by
# `deploy/homebrew/render.sh 1.0.0`. Edit the template there, never this
# copy: the binary and the formula that installs it are meant to change
# together, and a hand-edit here is a second source of truth that will
# disagree with the first one at the worst possible moment.
#
# The checksums below are the ones CI wrote beside each binary in the v1.0.0
# release. They are not computed from a local build -- the point of the
# checksum is that the file Homebrew downloads is the file CI produced.
class Qed < Formula
  desc "Policy and evidence kernel for AI-agent actions"
  homepage "https://github.com/valqore/qed"
  version "1.0.0"
  license "Apache-2.0"

  # One bottle per platform, because PyInstaller freezes the interpreter it
  # runs on and there is no cross-compilation. macOS arm64 and x86_64 are
  # separate builds rather than a universal2 binary: a universal build needs
  # universal wheels for `cryptography` and `pydantic-core`, and those are not
  # what pip resolves by default.
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/valqore/qed/releases/download/v1.0.0/qed-1.0.0-macos-arm64"
      sha256 "f0c2c7a6b4195a75e881ff59709446fe024ad6e8ea4ac164f7ac4dac780de523"
    else
      url "https://github.com/valqore/qed/releases/download/v1.0.0/qed-1.0.0-macos-x86_64"
      sha256 "9bcc174b1ac3dc658b5f49133441f594b802513adc1d2154b4b07bebd4f98dd2"
    end
  elsif OS.linux?
    url "https://github.com/valqore/qed/releases/download/v1.0.0/qed-1.0.0-linux-x86_64"
    sha256 "795d8e3e0b23e8dad8f66f24ebefbeb7feb5be8a11539d4237c7f1d89d46ef17"
  end

  def install
    bin.install Dir["qed-*"].first => "qed"
  end

  # The test block is what `brew test qed` and the tap's CI run, and it is
  # deliberately more than `--version`.
  #
  # `policy lint` resolves every shipped rule's control references against the
  # compliance catalogues, so a clean lint proves both sets of bundled YAML
  # made it into the binary. A `--version` that passes on a binary missing its
  # data files is the failure this avoids -- the wheel shipped exactly that bug
  # once, and the container shipped it again.
  test do
    assert_match "Policy and evidence kernel", shell_output("#{bin}/qed --help")
    assert_match "rules", shell_output("#{bin}/qed policy lint")

    # A real chain, decided and verified, with no Python on the machine --
    # which is the entire reason this formula exists.
    system bin/"qed", "keys", "init", "--dir", testpath/"state"
    assert_match "OK", shell_output("#{bin}/qed verify --dir #{testpath}/state")
  end
end
