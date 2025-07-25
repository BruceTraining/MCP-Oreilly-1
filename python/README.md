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
   # Install MCP with CLI extras (provides the 'mcp' command)
   uv add "mcp[cli]"
   
   # Install in development mode
   uv pip install -e .
   ```

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
2. Use F5 to run with the "Run Weather MCP Server" configuration
3. Or use Ctrl+Shift+P → "Python: Run Python File in Terminal"

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
├── weather_mcp/
│   ├── __init__.py
│   └── server.py
├── .vscode/
│   └── launch.json
└── README.md
```

## Notes

- Currently returns hardcoded weather data (45°F, Clear conditions)
- Real weather API integration planned for future versions
- Logging output goes to stderr to avoid interfering with MCP STDIO communication
