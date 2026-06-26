class CodexbarMqtt < Formula
  desc "Publish raw CodexBar observations to MQTT"
  homepage "https://github.com/mplummeridge/codexbar-mqtt"
  url "https://github.com/mplummeridge/codexbar-mqtt/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "REPLACE_WITH_SOURCE_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/mplummeridge/codexbar-mqtt.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/mplummeridge/codexbar-mqtt/internal/version.Version=#{version}
      -X github.com/mplummeridge/codexbar-mqtt/internal/version.Commit=homebrew
      -X github.com/mplummeridge/codexbar-mqtt/internal/version.Date=homebrew
    ]

    system "go", "build",
      *std_go_args(ldflags: ldflags.join(" ")),
      "./cmd/codexbar-mqtt"

    pkgshare.install "config.example.json"
    doc.install "README.md", "CHANGELOG.md", "SECURITY.md"
    doc.install "docs" if Dir.exist?("docs")
  end

  def post_install
    (etc/"codexbar-mqtt").mkpath
    (var/"log/codexbar-mqtt").mkpath

    config = etc/"codexbar-mqtt/config.json"
    cp pkgshare/"config.example.json", config unless config.exist?

    password = etc/"codexbar-mqtt/mqtt-password"
    unless password.exist?
      touch password
      chmod 0600, password
    end
  end

  service do
    run [
      opt_bin/"codexbar-mqtt",
      "run",
      "--config",
      etc/"codexbar-mqtt/config.json",
      "--log-format",
      "json",
    ]
    keep_alive true
    log_path var/"log/codexbar-mqtt/stdout.log"
    error_log_path var/"log/codexbar-mqtt/stderr.log"
    environment_variables PATH: std_service_path_env
  end

  test do
    assert_match "codexbar-mqtt", shell_output("#{bin}/codexbar-mqtt version")
    schema = shell_output("#{bin}/codexbar-mqtt schema")
    assert_match "io.github.mplummeridge.codexbar_mqtt.observation.v1", schema
    assert_match "codexbar/discovery/v1", schema
  end

  def caveats
    <<~EOS
      Config:
        #{etc}/codexbar-mqtt/config.json

      MQTT password file:
        #{etc}/codexbar-mqtt/mqtt-password

      Edit the config, then run diagnostics:
        codexbar-mqtt doctor --config #{etc}/codexbar-mqtt/config.json

      Start the background agent:
        brew services start codexbar-mqtt
    EOS
  end
end
