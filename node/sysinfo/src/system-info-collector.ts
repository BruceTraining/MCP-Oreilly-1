/**
 * System Information Collector
 *
 * This module is responsible for gathering system information from the host
 * machine using the "systeminformation" npm package. It is intentionally
 * separated from the MCP server layer so that:
 *
 *   1. The MCP server (index.ts) only deals with protocol concerns —
 *      tool registration, prompt definitions, transport, and lifecycle.
 *   2. This module only deals with data collection and formatting —
 *      calling OS-level APIs and assembling human-readable output.
 *
 * This mirrors the pattern used in the smart-home MCP template where
 * matter-controller.ts owns all Matter protocol logic and index.ts owns
 * all MCP logic.
 *
 * The main export is `getSystemInformation()`, which collects all data in
 * a single call and returns a result object with either a formatted string
 * or an error message.
 *
 * @module system-info-collector
 */

import si from "systeminformation";

// ============================================================================
// TYPES
// ============================================================================

/**
 * Result type returned by getSystemInformation().
 *
 * Follows the same success/error pattern as the smart-home template's
 * controller functions, making it easy for the MCP tool handler to
 * branch on `success`.
 */
export interface SystemInfoResult {
  success: boolean;
  /** The formatted system information string, present when success is true. */
  data?: string;
  /** An error message, present when success is false. */
  error?: string;
}

// ============================================================================
// FORMATTING HELPERS
// ============================================================================

/**
 * Format bytes into a human-readable string (KB, MB, GB, TB).
 */
function formatBytes(bytes: number): string {
  if (bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB", "TB"];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  const value = bytes / Math.pow(1024, i);
  return `${value.toFixed(2)} ${units[i]}`;
}

/**
 * Format seconds into a human-readable uptime string.
 */
function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);
  const parts: string[] = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0) parts.push(`${minutes}m`);
  if (secs > 0 || parts.length === 0) parts.push(`${secs}s`);
  return parts.join(" ");
}

// ============================================================================
// SECTION BUILDERS
// ============================================================================
// Each function below builds one labelled section of the output string.
// They are kept as separate functions for readability and testability.

function buildOsSection(
  osInfo: Awaited<ReturnType<typeof si.osInfo>>,
  time: Awaited<ReturnType<typeof si.time>>
): string {
  return [
    "=== Operating System ===",
    `Platform: ${osInfo.platform}`,
    `Distribution: ${osInfo.distro} ${osInfo.release}`,
    `Architecture: ${osInfo.arch}`,
    `Hostname: ${osInfo.hostname}`,
    `Kernel: ${osInfo.kernel}`,
    `Uptime: ${formatUptime(time.uptime)}`,
  ].join("\n");
}

function buildCpuSection(
  cpu: Awaited<ReturnType<typeof si.cpu>>,
  cpuSpeed: Awaited<ReturnType<typeof si.cpuCurrentSpeed>>,
  currentLoad: Awaited<ReturnType<typeof si.currentLoad>>,
  cpuTemp: Awaited<ReturnType<typeof si.cpuTemperature>>
): string {
  const lines = [
    "=== CPU ===",
    `Manufacturer: ${cpu.manufacturer}`,
    `Brand: ${cpu.brand}`,
    `Base Speed: ${cpu.speed} GHz`,
    `Current Speed (avg): ${cpuSpeed.avg} GHz`,
    `Cores: ${cpu.cores} (Physical: ${cpu.physicalCores})`,
    `Overall Load: ${currentLoad.currentLoad?.toFixed(2) ?? "N/A"}%`,
  ];

  if (cpuTemp.main !== null && cpuTemp.main !== -1) {
    lines.push(`Temperature: ${cpuTemp.main} C`);
  }

  if (currentLoad.cpus && currentLoad.cpus.length > 0) {
    lines.push("Per-Core Load:");
    currentLoad.cpus.forEach((core, idx) => {
      lines.push(`  Core ${idx}: ${core.load?.toFixed(2) ?? "N/A"}%`);
    });
  }

  return lines.join("\n");
}

function buildMemorySection(
  mem: Awaited<ReturnType<typeof si.mem>>
): string {
  const memUsedPercent = ((mem.used / mem.total) * 100).toFixed(2);
  const lines = [
    "=== Memory ===",
    `Total: ${formatBytes(mem.total)}`,
    `Used: ${formatBytes(mem.used)} (${memUsedPercent}%)`,
    `Free: ${formatBytes(mem.free)}`,
    `Available: ${formatBytes(mem.available)}`,
  ];

  if (mem.swaptotal > 0) {
    const swapUsedPercent = ((mem.swapused / mem.swaptotal) * 100).toFixed(2);
    lines.push(
      `Swap Total: ${formatBytes(mem.swaptotal)}`,
      `Swap Used: ${formatBytes(mem.swapused)} (${swapUsedPercent}%)`,
      `Swap Free: ${formatBytes(mem.swapfree)}`
    );
  }

  return lines.join("\n");
}

function buildDiskSection(
  fsSize: Awaited<ReturnType<typeof si.fsSize>>
): string {
  const lines = ["=== Disk / Filesystem ==="];

  if (Array.isArray(fsSize)) {
    for (const fs of fsSize) {
      lines.push(
        `  Mount: ${fs.mount}`,
        `    Filesystem: ${fs.fs}`,
        `    Type: ${fs.type}`,
        `    Size: ${formatBytes(fs.size)}`,
        `    Used: ${formatBytes(fs.used)} (${fs.use?.toFixed(2) ?? "N/A"}%)`,
        `    Available: ${formatBytes(fs.available)}`,
        ""
      );
    }
  }

  return lines.join("\n");
}

function buildBatterySection(
  battery: Awaited<ReturnType<typeof si.battery>>
): string {
  if (!battery.hasBattery) {
    return "=== Battery ===\nNo battery detected (desktop or VM).";
  }

  const lines = [
    "=== Battery ===",
    `Percentage: ${battery.percent}%`,
    `Charging: ${battery.isCharging ? "Yes" : "No"}`,
    `AC Connected: ${battery.acConnected ? "Yes" : "No"}`,
  ];

  if (battery.timeRemaining !== null && battery.timeRemaining > 0) {
    lines.push(`Time Remaining: ${battery.timeRemaining} minutes`);
  }
  if (battery.model) {
    lines.push(`Model: ${battery.model}`);
  }

  return lines.join("\n");
}

function buildNetworkInterfacesSection(
  networkInterfaces: Awaited<ReturnType<typeof si.networkInterfaces>>
): string {
  const lines = ["=== Network Interfaces ==="];
  const interfaces = Array.isArray(networkInterfaces)
    ? networkInterfaces
    : [networkInterfaces];

  for (const iface of interfaces) {
    if (iface.ip4 || iface.ip6) {
      lines.push(
        `  Interface: ${iface.iface}`,
        `    Type: ${iface.type}`,
        `    IPv4: ${iface.ip4 || "N/A"}`,
        `    IPv6: ${iface.ip6 || "N/A"}`,
        `    MAC: ${iface.mac || "N/A"}`,
        `    Speed: ${iface.speed !== null ? iface.speed + " Mbit/s" : "N/A"}`,
        `    State: ${iface.operstate || "N/A"}`,
        ""
      );
    }
  }

  return lines.join("\n");
}

function buildNetworkStatsSection(
  networkStats: Awaited<ReturnType<typeof si.networkStats>>
): string {
  const lines = ["=== Network Statistics ==="];
  const stats = Array.isArray(networkStats) ? networkStats : [networkStats];

  for (const stat of stats) {
    lines.push(
      `  Interface: ${stat.iface}`,
      `    Received: ${formatBytes(stat.rx_bytes)}`,
      `    Transmitted: ${formatBytes(stat.tx_bytes)}`,
      `    RX/sec: ${formatBytes(stat.rx_sec ?? 0)}/s`,
      `    TX/sec: ${formatBytes(stat.tx_sec ?? 0)}/s`,
      ""
    );
  }

  return lines.join("\n");
}

function buildProcessesSection(
  processes: Awaited<ReturnType<typeof si.processes>>
): string {
  const lines = [
    "=== Processes ===",
    `Total: ${processes.all}`,
    `Running: ${processes.running}`,
    `Sleeping: ${processes.sleeping}`,
    `Blocked: ${processes.blocked}`,
  ];

  if (processes.list && processes.list.length > 0) {
    const top = processes.list
      .sort((a, b) => (b.cpu ?? 0) - (a.cpu ?? 0))
      .slice(0, 15);

    lines.push("", "Top 15 Processes by CPU:");
    lines.push(
      `  ${"PID".padEnd(8)} ${"Name".padEnd(25)} ${"CPU%".padEnd(8)} ${"MEM%".padEnd(8)} State`
    );
    for (const p of top) {
      lines.push(
        `  ${String(p.pid).padEnd(8)} ${(p.name ?? "").padEnd(25)} ${(p.cpu?.toFixed(1) ?? "0.0").padEnd(8)} ${(p.mem?.toFixed(1) ?? "0.0").padEnd(8)} ${p.state ?? ""}`
      );
    }
  }

  return lines.join("\n");
}

// ============================================================================
// MAIN EXPORT
// ============================================================================

/**
 * Gather comprehensive system information and return it as a single
 * formatted string.
 *
 * This function calls multiple systeminformation APIs in parallel for
 * performance, then assembles the results into clearly-labelled sections.
 * The output is designed to be consumed by an LLM so that it can answer
 * a wide range of questions from a single tool invocation.
 *
 * @returns A result object with `success: true` and the formatted `data`
 *          string, or `success: false` and an `error` message.
 */
export async function getSystemInformation(): Promise<SystemInfoResult> {
  try {
    // Fetch all data concurrently for performance
    const [
      osInfo,
      cpu,
      cpuSpeed,
      currentLoad,
      mem,
      fsSize,
      battery,
      networkInterfaces,
      networkStats,
      processes,
      time,
      cpuTemp,
    ] = await Promise.all([
      si.osInfo(),
      si.cpu(),
      si.cpuCurrentSpeed(),
      si.currentLoad(),
      si.mem(),
      si.fsSize(),
      si.battery(),
      si.networkInterfaces(),
      si.networkStats(),
      si.processes(),
      si.time(),
      si.cpuTemperature(),
    ]);

    // Build each section independently
    const sections: string[] = [
      buildOsSection(osInfo, time),
      buildCpuSection(cpu, cpuSpeed, currentLoad, cpuTemp),
      buildMemorySection(mem),
      buildDiskSection(fsSize),
      buildBatterySection(battery),
      buildNetworkInterfacesSection(networkInterfaces),
      buildNetworkStatsSection(networkStats),
      buildProcessesSection(processes),
    ];

    return {
      success: true,
      data: sections.join("\n\n"),
    };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : String(error);
    return {
      success: false,
      error: errorMessage,
    };
  }
}
