class Claudeman < Formula
  desc "Run Claude Code in devcontainers with profiles"
  homepage "https://github.com/scottrigby/claudeman"
  url "https://github.com/scottrigby/claudeman/archive/refs/tags/v2.1.0.tar.gz"
  sha256 "8ac1299ec6fbab71310828c688b2a4ac54771fbebbabf58b18e250bfc138b54a"
  license "Apache-2.0"
  head "https://github.com/scottrigby/claudeman.git", branch: "main"

  depends_on "node"
  depends_on "podman"
  depends_on "jq"

  def install
    libexec.install Dir["*"]
    cd libexec do
      system "npm", "install", "--production", "--ignore-scripts"
    end

    (bin/"claudeman").write_env_script libexec/"claudeman",
      PATH: "#{Formula["node"].opt_bin}:$PATH"
  end

  def post_install
    # Restore portable shebangs on scripts that get copied into Linux
    # containers at runtime. Homebrew rewrites #!/usr/bin/env node to
    # the Homebrew node path during install, but that path doesn't
    # exist inside containers.
    [libexec/"lib/notify.js", libexec/"lib/browser-open.js"].each do |f|
      content = File.read(f)
      content.sub!(%r{^#!.*$}, "#!/usr/bin/env node")
      File.write(f, content)
    end
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
