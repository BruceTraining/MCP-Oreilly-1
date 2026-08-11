# Weather MCP Server (Python)

A Model Context Protocol (MCP) server that provides weather information using FastMCP. This is the Python implementation - other language examples available separately.

## Features

- **Weather Tool**: Get current weather information for any city (currently returns hardcoded data)
- **MCP Prompt Templates**: Pre-built prompts for weather inquiries and travel advice
- **STDIO Transport**: Compatible with Claude Desktop and MCP Inspector

## Setup

### Prerequisites

- Python 3.10+
- uv (recommended) or pip

### Installation with uv

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Clone and setup the project**:
   ```bash
   git clone <your-repo>
   cd weather_mcp_python
   ```

3. **Create the package structure** (if not already done):
   ```bash
   # Make sure you have the weather_mcp directory with required files
   mkdir -p weather_mcp
   # Copy your original weather-mcp.py content to weather_mcp/server.py
   # Create weather_mcp/__init__.py with the provided content
   ```

4. **Install dependencies**:
   ```bash
   uv sync
   ```

   This installs the exact versions from `uv.lock`, including `mcp[cli]`
   (the CLI extra provides the `mcp` command used below). Prefer `uv sync`
   over `uv add "mcp[cli]"` — `uv add` rewrites the dependency with a bare
   `>=` constraint and drops the security floor pinned in `pyproject.toml`
   (see [Dependency security](#dependency-security)).

5. **Verify installation**:
   ```bash
   # Check that the package is installed
   uv run python -c "import weather_mcp; print('Package installed successfully')"
   
   # Check that MCP CLI is available
   uv run mcp --help
   ```

## Running the Server

### Command Line (macOS Terminal)

```bash
# Option 1: Run directly with uv
uv run python -m weather_mcp.server

# Option 2: Use the MCP CLI (recommended for development)
uv run mcp run weather_mcp/server.py

# Option 3: If installed as a package script
uv run weather-mcp
```

### VS Code

1. Open the project in VS Code
2. Use Ctrl+Shift+P → "Python: Run Python File in Terminal"
3. To run with F5, add a `.vscode/launch.json` debug configuration that runs
   the `weather_mcp.server` module (the repo does not ship one)

## Testing with MCP Inspector

### Install MCP Inspector

```bash
npx @modelcontextprotocol/inspector
```

### Connect to Your Server

1. Start the MCP Inspector in your browser
2. Add your server with one of these commands:
   ```bash
   # Recommended: Use MCP CLI
   uv run mcp run weather_mcp/server.py
   
   # Alternative: Direct Python execution
   uv run python -m weather_mcp.server
   ```
3. Test the available tools and prompts:
   - **get_weather** tool: Try with different cities
   - **weather_inquiry** prompt: Generate weather inquiry templates  
   - **weather_travel_advice** prompt: Get travel advice prompts

### Register with Claude Desktop (Optional)

If you have Claude Desktop installed, you can register your server:

```bash
# Register your server with Claude Desktop
uv run mcp install weather_mcp/server.py --name "Weather Server"
```

This will automatically add your server to Claude Desktop's configuration.

## Available Tools

### `get_weather(city: str) -> str`
Returns weather information for the specified city.

**Example**:
```json
{
  "city": "New York"
}
```

## Available Prompts

### `weather_inquiry(location: str) -> str`
Generates a prompt for weather inquiries.

### `weather_travel_advice(destination: str, travel_date: str = None) -> list[Message]`
Generates prompts for travel weather advice.

## Development

### Project Structure
```
weather_mcp_python/
├── pyproject.toml
├── uv.lock
├── weather_mcp/
│   ├── __init__.py
│   └── server.py
└── README.md
```

## Dependency security

`pyproject.toml` pins `mcp[cli]>=1.29.0,<2`. Both ends of that range matter:

- **The floor is a security floor, not a feature floor.** Releases below it
  carry published advisories against the MCP Python SDK — CVE-2025-53366
  (FastMCP validation error → DoS, fixed in 1.9.4), CVE-2025-53365 (fixed in
  1.10.0), CVE-2025-66416 (DNS rebinding protection off by default, fixed in
  1.23.0), CVE-2026-52869 (fixed in 1.27.2) and CVE-2026-59950 (fixed in
  1.28.1). This server speaks STDIO only, so the transport-layer ones are not
  reachable as written, but the floor keeps a future HTTP transport from
  silently inheriting them.
- **The `<2` cap** keeps resolution on the 1.x FastMCP API this server is
  built on; `mcp` 2.0 is a breaking change.

Avoid replacing these with a bare `>=`: an unbounded floor lets a fresh
resolve or a lock-free `pip install .` pull a version with known advisories,
and an unbounded ceiling pulls the incompatible 2.x line. The build backend
(`hatchling>=1.27.0,<2`) is bounded for the same reason — it executes at
build time.

To re-check the locked tree against the OSV database:

```bash
uvx pip-audit
```

## Notes

- Currently returns hardcoded weather data (89°F, Clear conditions)
- Real weather API integration planned for future versions
- Logging output goes to stderr to avoid interfering with MCP STDIO communication