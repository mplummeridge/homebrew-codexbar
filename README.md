# Homebrew tap for CodexBar tools

Install the CodexBar MQTT collector from source:

```bash
brew tap mplummeridge/codexbar
brew install codexbar-mqtt
```

Or directly:

```bash
brew install mplummeridge/codexbar/codexbar-mqtt
```

## Service

```bash
brew services start codexbar-mqtt
codexbar-mqtt doctor --config "$(brew --prefix)/etc/codexbar-mqtt/config.json"
```

Config is installed at:

```text
$(brew --prefix)/etc/codexbar-mqtt/config.json
$(brew --prefix)/etc/codexbar-mqtt/mqtt-password
```

## Updating the formula SHA

After tagging `mplummeridge/codexbar-mqtt`:

```bash
git tag -f v0.2.0
git push --force origin v0.2.0

./script/update-codexbar-mqtt-sha v0.2.0
brew install --build-from-source --verbose --debug ./Formula/codexbar-mqtt.rb
brew test ./Formula/codexbar-mqtt.rb
brew audit --formula ./Formula/codexbar-mqtt.rb
```
