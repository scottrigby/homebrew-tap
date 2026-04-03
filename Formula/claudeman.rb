class Claudeman < Formula
  desc "Run Claude Code in devcontainers with profiles"
  homepage "https://github.com/scottrigby/claudeman"
  url "https://github.com/scottrigby/claudeman/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "35c570fdffeb37a0ff9c1e7088223509a0268b83af5ecb98fbcbbedd7ae5995b"
  license "Apache-2.0"
  head "https://github.com/scottrigby/claudeman.git", branch: "main"

  depends_on "node"
  depends_on "podman"
  depends_on "jq"

  def install
    # Install all files to libexec
    libexec.install Dir["*"]

    # Install npm dependencies inside libexec
    cd libexec do
      system "npm", "install", "--production", "--ignore-scripts"
    end

    # Restore portable shebangs on scripts that get copied into containers.
    # Homebrew rewrites #!/usr/bin/env node to the Homebrew node path, but
    # these scripts run inside Linux containers where that path doesn't exist.
    [libexec/"lib/notify.js", libexec/"lib/browser-open.js"].each do |f|
      inreplace f, %r{^#!.*node.*$}, "#!/usr/bin/env node"
    end

    # Create wrapper script that runs from libexec with node on PATH
    (bin/"claudeman").write_env_script libexec/"claudeman",
      PATH: "#{Formula["node"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      To use claudeman, run from any project directory:

        claudeman listen    # Start notification listener (separate tab)
        claudeman init      # Set up hooks in your project
        claudeman run       # Run Claude in a devcontainer

      Use built-in or custom profiles to bundle features, firewall
      domains, caches, and hooks into reusable configurations:

        claudeman profile list
        claudeman run --profile=go

      Run `claudeman -h` for full command reference.
    EOS
  end

  test do
    assert_match "claudeman", shell_output("#{bin}/claudeman -h")
    assert_match version.to_s, shell_output("#{bin}/claudeman -v").strip
  end
end
