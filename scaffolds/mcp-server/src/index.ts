#!/usr/bin/env node
/**
 * {{PROJECT_NAME}} - {{DESCRIPTION}}
 * @author {{AUTHOR}}
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({
  name: "{{PROJECT_NAME}}",
  version: "0.1.0",
});

// TODO: Add tools, resources, or prompts here

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Server error:", err);
  process.exit(1);
});
