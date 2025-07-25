#!/usr/bin/env node
/**
 * Weather MCP Server - A Model Context Protocol server that provides weather information.
 * This server implements:
 * - A weather tool that returns hardcoded temperature data (83F)
 * - MCP prompt templates for weather-related interactions
 * - STDIO transport for communication with Claude Desktop
 *
 * Built using the official MCP TypeScript SDK.
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";


// Create the MCP server
const server = new McpServer({
  name: "weather-mcp-server-nodejs-local",
  version: "1.0.0"
});

/**
 * Get current weather information for a specified city.
 * Returns temperature data for the requested location.
 */
server.tool(
  "get_weather",
  {
    city: z.string().describe("Name of the city to get weather for (e.g., 'New York', 'London', 'Tokyo')")
  },
  async ({ city }) => {
    // Validate city parameter
    if (!city || !city.trim()) {
      throw new Error("City parameter cannot be empty");
    }

    const cleanCity = city.trim();

    // Log the request for debugging (to stderr to avoid interfering with STDIO)
    console.error(`Processing weather request for city: ${cleanCity}`);

    // Get current timestamp for the response
    const timestamp = new Date().toLocaleString();

    // Create formatted weather response
    // NOTE: This is hardcoded for now - will be replaced with actual API calls
    const weatherReport = `Weather Report for ${cleanCity}
        ========================
        Current Temperature: 93F
        Conditions: Clear
        Humidity: 65%
        Wind: Light breeze
        Last Updated: ${timestamp}
        `;

    // Log the response for debugging
    console.error(`Returning weather data for ${cleanCity}`);

    return {
      content: [{ type: "text", text: weatherReport }]
    };
  }
);

/**
 * Template for asking about weather conditions in a specific location.
 */
server.prompt(
  "weather_inquiry",
  {
    location: z.string().describe("The city or location to inquire about")
  },
  ({ location }) => {
    const promptText = `I need current weather information for ${location}. ` +
      "Please provide the temperature and any relevant weather conditions. " +
      "If you need to use a tool to get this information, please do so.";

    return {
      description: `Template for asking about weather conditions in ${location}`,
      messages: [
        {
          role: "user",
          content: {
            type: "text",
            text: promptText
          }
        }
      ]
    };
  }
);

/**
 * Template for getting weather-based travel advice for a destination.
 */
server.prompt(
  "weather_travel_advice",
  {
    destination: z.string().describe("Travel destination city"),
    travel_date: z.string().optional().describe("Planned travel date (optional)")
  },
  ({ destination, travel_date }) => {
    const dateInfo = travel_date ? ` for travel on ${travel_date}` : " for current conditions";
    
    const promptText = `I'm planning to travel to ${destination}${dateInfo}. ` +
      "Please check the current weather conditions and provide advice on " +
      "what to pack and any weather-related considerations for my trip. " +
      "Use the weather tool to get current temperature data.";

    return {
      description: `Template for getting weather-based travel advice for ${destination}`,
      messages: [
        {
          role: "user",
          content: {
            type: "text",
            text: promptText
          }
        }
      ]
    };
  }
);

/**
 * Main entry point for the Weather MCP Server.
 * Sets up STDIO transport and starts the server to listen for MCP requests.
 */
async function main(): Promise<void> {
  try {
    // Start the server with STDIO transport
    console.error("Starting Weather MCP Server...");
    console.error("Server ready to accept connections via STDIO");

    // Create transport and connect
    const transport = new StdioServerTransport();
    await server.connect(transport);

    console.error("Weather MCP Server connected and running");

  } catch (error) {
    // Log error to stderr (stdout is used for MCP communication)
    console.error(`Failed to start Weather MCP Server: ${error}`);
    if (error instanceof Error) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.error("Received SIGINT, shutting down gracefully...");
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.error("Received SIGTERM, shutting down gracefully...");
  process.exit(0);
});

// Start the server
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error("Unhandled error:", error);
    process.exit(1);
  });
}