class Claudeman < Formula
  desc "Run Claude Code in a Podman container with custom dependencies"
  homepage "https://github.com/scottrigby/claudeman"
  url "https://github.com/scottrigby/claudeman/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "58755d64ab347e7ec1bac49e2ca66630a4dd3c3809f246eedec3ec95e4ba2ae8"
  license "Apache-2.0"
  head "https://github.com/scottrigby/claudeman.git", branch: "main"

  depends_on "podman"
  depends_on "node" => :optional
  depends_on "jq"

  def install
    # Install main script
    bin.install "claudeman"

    # Install lib files to share directory
    (share/"claudeman/lib").install Dir["lib/*"]
  end

  def caveats
    <<~EOS
      To use claudeman, run from any project directory:
        claudeman run

      For audio notifications (macOS only), start the listener:
        node #{share}/claudeman/lib/listener.js

      First run will install Go and development tools into the container.
      Subsequent runs reuse installed tools for faster startup.

      Configuration:
        Hooks are merged into .claude/settings.json on each run.
        Customize per-project by editing .claude/settings.json.
        Your customizations are preserved during hook updates.
    EOS
  end

  test do
    system "#{bin}/claudeman", "help"
  end
end
