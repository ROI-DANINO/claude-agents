---
disable: true
---

# {{PROJECT_NAME}}

{{DESCRIPTION}}

## Installation

```bash
npm install
npm run build
```

## Usage

Add to your MCP configuration:

```json
{
  "mcpServers": {
    "{{PROJECT_NAME}}": {
      "command": "node",
      "args": ["/path/to/{{PROJECT_NAME}}/dist/index.js"]
    }
  }
}
```

## Development

```bash
npm run dev  # Watch mode
```

## Author

{{AUTHOR}}
