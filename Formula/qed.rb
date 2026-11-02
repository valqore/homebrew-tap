# Homebrew formula for the `qed` single-file binary (SPEC §24.1).
#
# ## Generated, not written
#
# This file is `deploy/homebrew/qed.rb.template` in valqore/qed, rendered by
# `deploy/homebrew/render.sh 1.1.1`. Edit the template there, never this
# copy: the binary and the formula that installs it are meant to change
# together, and a hand-edit here is a second source of truth that will
# disagree with the first one at the worst possible moment.
#
# The checksums below are the ones CI wrote beside each binary in the v1.1.1
# release. They are not computed from a local build -- the point of the
# checksum is that the file Homebrew downloads is the file CI produced.
class Qed < Formula
  desc "Policy and evidence kernel for AI-agent actions"
  homepage "https://github.com/valqore/qed"
  version "1.1.1"
  license "Apache-2.0"

  # One bottle per platform, because PyInstaller freezes the interpreter it
  # runs on and there is no cross-compilation. macOS arm64 and x86_64 are
  # separate builds rather than a universal2 binary: a universal build needs
  # universal wheels for `cryptography` and `pydantic-core`, and those are not
  # what pip resolves by default.
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/valqore/qed/releases/download/v1.1.1/qed-1.1.1-macos-arm64"
      sha256 "26d1fcdfba70fdda3b9455d4338df87421b643345ba1256d5b048077332040a8"
    else
      url "https://github.com/valqore/qed/releases/download/v1.1.1/qed-1.1.1-macos-x86_64"
      sha256 "dd32951d98f8b28841bec590f547b3c95ac5603b99b54f47fe002b42be619237"
    end
  elsif OS.linux?
    url "https://github.com/valqore/qed/releases/download/v1.1.1/qed-1.1.1-linux-x86_64"
    sha256 "64e1c9ce4a078e61e71051c1db99d37f4f05e642cbba0d6a6a90a3178117948e"
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
