# Weather MCP Server (Java SDK 2.0)

A Model Context Protocol server that provides weather information, built with
the official [MCP Java SDK](https://github.com/modelcontextprotocol/java-sdk)
**2.0.0** — plain Java, no application framework.

This is the SDK 2.0 rewrite of the original 0.10.0-based server. For a full
walkthrough of the code, the protocol, and the 0.x → 2.0 migration, see
**[tutorial.md](tutorial.md)**.

## What it provides

- **Tool** `get_weather` — returns weather for a city (hardcoded sample data,
  44°F, for course purposes)
- **Prompt** `weather_inquiry` — template for asking about conditions at a location
- **Prompt** `weather_travel_advice` — template for weather-based packing/travel advice

Transport: STDIO (launched as a child process by the client).

## Requirements

- Java 17+
- Maven 3.6+

## Build

```bash
mvn package
```

Produces the self-contained jar `target/weather-mcp-server-2.0.0.jar`.

## Quick test

```bash
npx @modelcontextprotocol/inspector java -jar target/weather-mcp-server-2.0.0.jar
```

(Or drive it with raw JSON-RPC — see [tutorial.md](tutorial.md#4-build-run-and-test).)

## Install in Claude Desktop

Add to `claude_desktop_config.json` (macOS:
`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "weather": {
      "command": "java",
      "args": [
        "-jar",
        "/absolute/path/to/weather-mcp-server-v2/target/weather-mcp-server-2.0.0.jar"
      ]
    }
  }
}
```

Restart Claude Desktop and ask about the weather in any city.

## Project layout

```
├── pom.xml                  Maven build (SDK 2.0 BOM, shade plugin for fat jar)
├── tutorial.md              Full code walkthrough + migration guide + Spring AI appendix
└── src/main/java/com/example/weather/
    └── WeatherMcpServer.java   The entire server (single class, fully documented)
```
