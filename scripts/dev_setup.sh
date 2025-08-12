#!/bin/bash

echo "🛠️  Quick Haiven MCP Development Setup"
echo "======================================"
echo ""

# Check if we're in the right directory
if [ ! -f "mcp_server.py" ]; then
    echo "❌ Run this script from the haiven-mcp-server directory"
    exit 1
fi

echo "1. 📦 Installing dependencies..."
poetry install

echo ""
echo "2. 🔧 Setting up environment..."
cat > .env << EOF
# Haiven MCP Development Environment
HAIVEN_API_URL=http://localhost:8080
HAIVEN_DISABLE_AUTH=true
EOF

echo "✅ Created .env file"
echo ""

echo "3. 🧪 Testing MCP server..."
export HAIVEN_API_URL=http://localhost:8080
export HAIVEN_DISABLE_AUTH=true

if poetry run python -c "from src.mcp_server import HaivenMCPServer; print('✅ MCP server imports OK')" 2>/dev/null; then
    echo "✅ MCP server test passed"
else
    echo "⚠️  MCP server test failed (but setup continues...)"
fi

echo ""
echo "4. 📋 Creating AI tool configs..."

# Current directory for config
CURRENT_DIR=$(pwd)

# Claude Desktop config (using absolute path to avoid path issues)
cat > claude-desktop-config.json << EOF
{
  "mcpServers": {
    "haiven-dev": {
      "command": "$CURRENT_DIR/.venv/bin/python",
      "args": ["$CURRENT_DIR/mcp_server.py"],
      "env": {
        "HAIVEN_API_URL": "http://localhost:8080",
        "HAIVEN_DISABLE_AUTH": "true"
      }
    }
  }
}
EOF

# Also create version with module import for tools that support it
cat > claude-desktop-config-module.json << EOF
{
  "mcpServers": {
    "haiven-dev": {
      "command": "$CURRENT_DIR/.venv/bin/python",
      "args": ["-m", "src.mcp_server"],
      "cwd": "$CURRENT_DIR",
      "env": {
        "HAIVEN_API_URL": "http://localhost:8080",
        "HAIVEN_DISABLE_AUTH": "true"
      }
    }
  }
}
EOF

echo "✅ Created claude-desktop-config.json (absolute path - recommended)"
echo "✅ Created claude-desktop-config-module.json (module import)"

echo ""
echo "🎉 Development setup complete!"
echo "=============================="
echo ""
echo "Next steps:"
echo "1. Start your Haiven backend server (ensure it's running on http://localhost:8080)"
echo "2. Copy claude-desktop-config.json to ~/Library/Application Support/Claude/claude_desktop_config.json (macOS) or ~/.config/claude/config.json (Linux)"
echo "3. Restart your AI tool"
echo "4. Ask: 'What Haiven prompts are available?'"
echo ""
echo "💡 Use claude-desktop-config.json (absolute path) for most reliable setup"
echo "   If that doesn't work, try claude-desktop-config-module.json"
echo ""
echo "Quick test: source .env && poetry run python mcp_server.py"
echo ""
echo "🛠️  Happy local development!"
