#!/usr/bin/env node
/**
 * System Information MCP Server
 *
 * A Model Context Protocol (MCP) server that enables AI assistants (like Claude)
 * to retrieve detailed system information from the host machine.
 *
 * This server implements:
 * - A single tool (get_system_information) that gathers comprehensive system
 *   data in one call: CPU, memory, disk, battery, processes, network, and OS info.
 * - Prompt templates for common system information use cases such as
 *   troubleshooting, health checks, security auditing, and capacity planning.
 * - STDIO transport for communication with MCP clients.
 *
 * All system-level data collection lives in system-info-collector.ts. This
 * file only handles MCP protocol concerns: tool registration, prompt
 * definitions, transport setup, and server lifecycle.
 *
 * Built using:
 * - @modelcontextprotocol/sdk - Official MCP TypeScript SDK
 * - systeminformation - Lightweight system and OS information library
 * - zod - Runtime type validation
 *
 * @module sysinfo-mcp-server
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

// Import our system information collector function
import { getSystemInformation } from "./system-info-collector.js";

// ============================================================================
// SERVER INITIALIZATION
// ============================================================================

/**
 * Create and configure the MCP server instance.
 *
 * The server name and version are used by MCP clients to identify this server.
 * These values appear in client UIs and logs.
 */
const server = new McpServer({
  name: "sysinfo-mcp-server",
  version: "1.0.0",
});

// ============================================================================
// TOOL DEFINITIONS
// ============================================================================

/**
 * Tool: get_system_information
 *
 * Retrieves comprehensive system information in a single call, including
 * OS details, CPU, memory, disk, battery, network, and processes.
 *
 * This is intentionally a single tool rather than many granular tools.
 * The LLM receives the full snapshot and can answer any follow-up
 * question about the system without needing additional tool calls.
 */
server.registerTool(
  "get_system_information",
  {
    title: "Get System Information",
    description:
      "Retrieves a comprehensive snapshot of the host system including: " +
      "operating system details, CPU specs and current load, memory usage, " +
      "disk/filesystem sizes and usage, battery status, network interfaces " +
      "and statistics, and a list of running processes sorted by CPU usage. " +
      "All data is returned in a single human-readable text block. " +
      "Use this tool whenever the user asks anything about the system, " +
      "such as performance, resource usage, running processes, disk space, " +
      "network activity, battery life, or general system health.",
    inputSchema: {},
    outputSchema: {
      success: z.boolean().describe("Whether the data was collected successfully"),
      message: z.string().describe("Human-readable system information or error message"),
    },
  },
  async () => {
    // Log to stderr (stdout is reserved for MCP protocol communication)
    console.error("[MCP Server] Tool invoked: get_system_information");

    // Call our system information collector function
    const result = await getSystemInformation();

    // Format the response for the AI
    // The AI will use this information to formulate a response to the user
    if (result.success) {
      return {
        content: [
          {
            type: "text" as const,
            text: result.data!,
          },
        ],
        structuredContent: {
          success: true,
          message: result.data!,
        },
      };
    } else {
      // Provide detailed error information so the AI can help troubleshoot
      return {
        content: [
          {
            type: "text" as const,
            text:
              `Failed to retrieve system information: ${result.error}\n\n` +
              "Troubleshooting tips:\n" +
              "- Ensure the server process has sufficient permissions\n" +
              "- Some data (e.g. temperature) may require elevated privileges\n" +
              "- Check that the systeminformation package is installed correctly",
          },
        ],
        structuredContent: {
          success: false,
          message: `Failed to retrieve system information: ${result.error}`,
        },
        isError: true,
      };
    }
  }
);

// ============================================================================
// PROMPT DEFINITIONS
// ============================================================================

/**
 * Prompt: system_health_check
 *
 * Guides the LLM to perform a general health check and provide
 * a summary with any warnings about resource usage.
 */
server.registerPrompt(
  "system_health_check",
  {
    title: "System Health Check",
    description:
      "Perform a general health check of the system. Retrieves system " +
      "information and summarises the overall health, highlighting any " +
      "resources that are under pressure (high CPU, low memory, low disk " +
      "space, low battery, etc.).",
    argsSchema: {},
  },
  () => ({
    messages: [
      {
        role: "user" as const,
        content: {
          type: "text" as const,
          text:
            "Please perform a full system health check. Use the get_system_information tool " +
            "to gather data, then provide a clear summary of the overall system health. " +
            "Highlight any areas of concern such as high CPU load, low available memory, " +
            "disks that are nearly full, low battery, or an unusually high number of " +
            "processes. Keep the summary concise and actionable.",
        },
      },
    ],
  })
);

/**
 * Prompt: troubleshoot_performance
 *
 * Helps the user diagnose a slow or unresponsive system by gathering
 * system data and analysing resource bottlenecks.
 */
server.registerPrompt(
  "troubleshoot_performance",
  {
    title: "Troubleshoot Performance",
    description:
      "Diagnose system performance problems. Retrieves system information " +
      "and analyses CPU load, memory pressure, disk I/O, and top processes " +
      "to identify likely bottlenecks.",
    argsSchema: {
      symptom: z
        .string()
        .optional()
        .describe(
          "Optional description of the symptom (e.g. 'system feels slow', " +
          "'applications are freezing', 'high fan noise')"
        ),
    },
  },
  ({ symptom }) => {
    const symptomText = symptom
      ? `The user reports the following symptom: "${symptom}". `
      : "";

    return {
      messages: [
        {
          role: "user" as const,
          content: {
            type: "text" as const,
            text:
              `${symptomText}My system seems to be having performance issues. ` +
              "Please use the get_system_information tool to collect data, then analyse " +
              "the results to identify potential bottlenecks. Look at CPU load, memory " +
              "usage, swap usage, disk utilisation, and the top processes consuming " +
              "resources. Suggest concrete steps I can take to improve performance.",
          },
        },
      ],
    };
  }
);

/**
 * Prompt: security_process_audit
 *
 * Guides the LLM to review running processes and network activity
 * for anything unusual that could indicate a security concern.
 */
server.registerPrompt(
  "security_process_audit",
  {
    title: "Security & Process Audit",
    description:
      "Audit running processes and network interfaces for potential " +
      "security concerns. Reviews process list for suspicious entries " +
      "and checks network configuration.",
    argsSchema: {},
  },
  () => ({
    messages: [
      {
        role: "user" as const,
        content: {
          type: "text" as const,
          text:
            "Please perform a security-oriented review of my system. Use the " +
            "get_system_information tool and then examine the list of running processes " +
            "for anything unusual or potentially suspicious. Also review the network " +
            "interfaces and statistics for unexpected activity. Let me know if anything " +
            "looks out of the ordinary and suggest next steps if needed. Note: this is " +
            "a basic review and is not a substitute for professional security tooling.",
        },
      },
    ],
  })
);

/**
 * Prompt: capacity_planning
 *
 * Helps the user understand current resource utilisation relative to
 * total capacity and plan for future needs.
 */
server.registerPrompt(
  "capacity_planning",
  {
    title: "Capacity Planning",
    description:
      "Analyse current resource usage against total capacity. Provides " +
      "a breakdown of CPU, memory, and disk utilisation with recommendations " +
      "for when thresholds are being approached.",
    argsSchema: {
      threshold: z
        .string()
        .optional()
        .describe(
          "Optional warning threshold percentage (e.g. '80'). " +
          "Resources above this percentage will be flagged. Defaults to 80."
        ),
    },
  },
  ({ threshold }) => {
    const pct = threshold ?? "80";
    return {
      messages: [
        {
          role: "user" as const,
          content: {
            type: "text" as const,
            text:
              "I need to understand my current system capacity. Please use the " +
              "get_system_information tool to collect data, then provide a capacity " +
              `report. Flag any resource (CPU, memory, disk) that is above ${pct}% ` +
              "utilisation. For each resource, show the current usage vs total capacity " +
              "and indicate whether I am at risk of running out. Suggest actions for " +
              "any resources that are approaching the threshold.",
          },
        },
      ],
    };
  }
);

/**
 * Prompt: battery_status
 *
 * A focused prompt for checking battery health and estimating
 * remaining usage time.
 */
server.registerPrompt(
  "battery_status",
  {
    title: "Battery Status",
    description:
      "Check the current battery status including charge level, charging " +
      "state, and estimated time remaining. Useful for laptop users.",
    argsSchema: {},
  },
  () => ({
    messages: [
      {
        role: "user" as const,
        content: {
          type: "text" as const,
          text:
            "Please check my battery status. Use the get_system_information tool and " +
            "report on the current battery percentage, whether it is charging, and " +
            "the estimated time remaining if available. If no battery is detected, " +
            "let me know that this system does not have a battery.",
        },
      },
    ],
  })
);

/**
 * Prompt: resource_usage_summary
 *
 * A quick-glance summary of current resource usage suitable for
 * dashboards or periodic check-ins.
 */
server.registerPrompt(
  "resource_usage_summary",
  {
    title: "Resource Usage Summary",
    description:
      "Provide a brief, at-a-glance summary of CPU, memory, and disk usage. " +
      "Designed for quick periodic check-ins rather than deep analysis.",
    argsSchema: {},
  },
  () => ({
    messages: [
      {
        role: "user" as const,
        content: {
          type: "text" as const,
          text:
            "Give me a quick resource usage summary. Use the get_system_information tool " +
            "and provide a brief overview of current CPU load, memory utilisation, and " +
            "disk usage. Keep it short -- just the key numbers and whether anything " +
            "looks concerning.",
        },
      },
    ],
  })
);

/**
 * Prompt: network_overview
 *
 * Focuses specifically on network interfaces, connectivity, and traffic.
 */
server.registerPrompt(
  "network_overview",
  {
    title: "Network Overview",
    description:
      "Review network interfaces, IP addresses, link speeds, and current " +
      "traffic statistics. Useful for connectivity troubleshooting.",
    argsSchema: {},
  },
  () => ({
    messages: [
      {
        role: "user" as const,
        content: {
          type: "text" as const,
          text:
            "Please give me an overview of my network configuration and activity. " +
            "Use the get_system_information tool, then summarise the network interfaces " +
            "(names, IP addresses, speeds, operational state) and current traffic " +
            "statistics (bytes sent/received). Highlight any interfaces that appear " +
            "to be down or misconfigured.",
        },
      },
    ],
  })
);

/**
 * Prompt: process_investigation
 *
 * Helps the user investigate which processes are consuming the most
 * resources and decide whether any should be stopped.
 */
server.registerPrompt(
  "process_investigation",
  {
    title: "Process Investigation",
    description:
      "Investigate the top resource-consuming processes on the system. " +
      "Lists the heaviest processes by CPU and memory usage and helps " +
      "the user decide if any should be terminated.",
    argsSchema: {
      process_name: z
        .string()
        .optional()
        .describe(
          "Optional: a specific process name to look for in the process list"
        ),
    },
  },
  ({ process_name }) => {
    const extra = process_name
      ? ` In particular, look for any process named or related to "${process_name}" and report its resource usage.`
      : "";

    return {
      messages: [
        {
          role: "user" as const,
          content: {
            type: "text" as const,
            text:
              "I want to investigate which processes are using the most resources on my " +
              "system. Please use the get_system_information tool and then list the top " +
              "processes by CPU and memory usage. For each, explain what the process " +
              `likely is and whether it seems normal.${extra} If any processes look ` +
              "like they might be stuck or consuming excessive resources, suggest how " +
              "to handle them.",
          },
        },
      ],
    };
  }
);

// ============================================================================
// SERVER STARTUP
// ============================================================================

/**
 * Main entry point for the System Information MCP Server.
 *
 * This function:
 * 1. Creates the STDIO transport for MCP communication
 * 2. Connects the server to the transport
 * 3. Handles any startup errors gracefully
 *
 * The server uses STDIO (standard input/output) for communication,
 * which is the standard transport for MCP servers that run as
 * child processes of MCP clients like Claude Desktop.
 */
async function main(): Promise<void> {
  try {
    // Log startup to stderr (stdout is reserved for MCP protocol)
    console.error("========================================");
    console.error("System Information MCP Server Starting...");
    console.error("========================================");
    console.error("Server Name: sysinfo-mcp-server");
    console.error("Version: 1.0.0");
    console.error("----------------------------------------");
    console.error("Available Tools:");
    console.error("  - get_system_information");
    console.error("----------------------------------------");
    console.error("Available Prompts:");
    console.error("  - system_health_check");
    console.error("  - troubleshoot_performance");
    console.error("  - security_process_audit");
    console.error("  - capacity_planning");
    console.error("  - battery_status");
    console.error("  - resource_usage_summary");
    console.error("  - network_overview");
    console.error("  - process_investigation");
    console.error("========================================");

    // Create the STDIO transport
    // This handles reading from stdin and writing to stdout
    // in the format expected by MCP clients
    const transport = new StdioServerTransport();

    // Connect the server to the transport
    // This starts the server listening for MCP requests
    await server.connect(transport);

    console.error("Server connected and ready to receive requests");
    console.error("========================================");
  } catch (error) {
    // Log any startup errors
    console.error("Failed to start System Information MCP Server:");
    console.error(error);
    process.exit(1);
  }
}

// ============================================================================
// GRACEFUL SHUTDOWN HANDLERS
// ============================================================================

/**
 * Handle SIGINT (Ctrl+C) for graceful shutdown.
 *
 * This ensures the server can clean up resources and
 * close connections properly when terminated.
 */
process.on("SIGINT", () => {
  console.error("\nReceived SIGINT signal");
  console.error("Shutting down System Information MCP Server gracefully...");
  process.exit(0);
});

/**
 * Handle SIGTERM for graceful shutdown.
 *
 * SIGTERM is typically sent by process managers (like systemd)
 * when stopping a service.
 */
process.on("SIGTERM", () => {
  console.error("\nReceived SIGTERM signal");
  console.error("Shutting down System Information MCP Server gracefully...");
  process.exit(0);
});

// ============================================================================
// START THE SERVER
// ============================================================================

/**
 * Start the server when this file is executed directly.
 *
 * This starts the main function and handles any unhandled errors.
 */
main().catch((error) => {
  console.error("Unhandled error during server startup:");
  console.error(error);
  process.exit(1);
});
