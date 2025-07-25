#!/usr/bin/env python3
"""
Weather MCP Server - A Model Context Protocol server that provides weather information.
This server implements:
- A weather tool that returns hardcoded temperature data (45F)
- MCP prompt templates for weather-related interactions
- STDIO transport for communication with Claude Desktop

Built using FastMCP (included in the official MCP Python SDK).
"""

import sys
from datetime import datetime

from mcp.server.fastmcp import FastMCP
from mcp.server.fastmcp.prompts import base

# Create the FastMCP server
mcp = FastMCP("weather-server")


@mcp.tool()
def get_weather(city: str) -> str:
    """
    Get current weather information for a specified city.
    Returns temperature data for the requested location.
    
    Args:
        city: Name of the city to get weather for (e.g., 'New York', 'London', 'Tokyo')
    
    Returns:
        Formatted weather information string
    """
    # Validate city parameter
    if not city or not city.strip():
        raise ValueError("City parameter cannot be empty")
    
    city = city.strip()
    
    # Log the request for debugging (to stderr to avoid interfering with STDIO)
    print(f"Processing weather request for city: {city}", file=sys.stderr)
    
    # Get current timestamp for the response
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create formatted weather response
    # NOTE: This is hardcoded for now - will be replaced with actual API calls
    weather_report = (
        f"Weather Report for {city}\n"
        "========================\n"
        f"Current Temperature: 83F\n"
        "Conditions: Clear\n"
        "Humidity: 65%\n"
        "Wind: Light breeze\n"
        f"Last Updated: {timestamp}\n"
        "\n"
    )
    
    # Log the response for debugging
    print(f"Returning weather data for {city}", file=sys.stderr)
    
    return weather_report


@mcp.prompt()
def weather_inquiry(location: str) -> str:
    """
    Template for asking about weather conditions in a specific location.
    
    Args:
        location: The city or location to inquire about
    
    Returns:
        Formatted prompt for weather inquiries
    """
    return (
        f"I need current weather information for {location}. "
        "Please provide the temperature and any relevant weather conditions. "
        "If you need to use a tool to get this information, please do so."
    )


@mcp.prompt()
def weather_travel_advice(destination: str, travel_date: str = None) -> list[base.Message]:
    """
    Template for getting weather-based travel advice for a destination.
    
    Args:
        destination: Travel destination city
        travel_date: Planned travel date (optional)
    
    Returns:
        List of messages for travel weather advice
    """
    date_info = f" for travel on {travel_date}" if travel_date else " for current conditions"
    
    prompt_text = (
        f"I'm planning to travel to {destination}{date_info}. "
        "Please check the current weather conditions and provide advice on "
        "what to pack and any weather-related considerations for my trip. "
        "Use the weather tool to get current temperature data."
    )
    
    return [
        base.UserMessage(prompt_text)
    ]


def main():
    """
    Main entry point for the Weather MCP Server.
    Sets up STDIO transport and starts the server to listen for MCP requests.
    """
    try:
        # Start the server with STDIO transport
        print("Starting Weather MCP Server...", file=sys.stderr)
        print("Server ready to accept connections via STDIO", file=sys.stderr)
        
        # Run the server - FastMCP handles all the transport details
        mcp.run()
        
    except Exception as e:
        # Log error to stderr (stdout is used for MCP communication)
        print(f"Failed to start Weather MCP Server: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()