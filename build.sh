#!/bin/bash

# Build script for DTC Claude Skills
# This script creates downloadable ZIP files for each skill and generates the GitHub Pages site

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Building DTC Claude Skills ===${NC}\n"

# Create downloads directory
DOWNLOADS_DIR="docs/downloads"
mkdir -p "$DOWNLOADS_DIR"

# Counter for skills processed
SKILL_COUNT=0

# Array to store skill information for index page generation
declare -a SKILLS

# Find all skill directories (format: ##-skill-name)
for skill_dir in [0-9][0-9]-*/; do
    # Remove trailing slash
    skill_dir=${skill_dir%/}

    # Check if directory exists and contains required files
    if [ ! -d "$skill_dir" ]; then
        continue
    fi

    # Check for required files
    if [ ! -f "$skill_dir/SKILL.md" ]; then
        echo -e "${YELLOW}⚠ Skipping $skill_dir - missing SKILL.md${NC}"
        continue
    fi

    echo -e "${GREEN}📦 Processing: $skill_dir${NC}"

    # Create ZIP file
    ZIP_NAME="${skill_dir}.zip"
    ZIP_PATH="$DOWNLOADS_DIR/$ZIP_NAME"

    # Remove old zip if exists
    rm -f "$ZIP_PATH"

    # Create zip with all markdown files in the skill directory
    cd "$skill_dir"
    zip -q "../$ZIP_PATH" *.md 2>/dev/null || true
    cd ..

    if [ -f "$ZIP_PATH" ]; then
        # Get file size
        SIZE=$(du -h "$ZIP_PATH" | cut -f1)
        echo -e "  ✓ Created $ZIP_NAME (${SIZE})"

        # Extract skill name from directory (remove number prefix)
        SKILL_NAME=$(echo "$skill_dir" | sed 's/^[0-9][0-9]-//' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

        # Store skill info
        SKILLS+=("$ZIP_NAME|$SKILL_NAME")
        SKILL_COUNT=$((SKILL_COUNT + 1))
    else
        echo -e "${RED}  ✗ Failed to create $ZIP_NAME${NC}"
    fi

    echo ""
done

echo -e "${GREEN}=== Build Summary ===${NC}"
echo -e "Skills packaged: ${SKILL_COUNT}"
echo -e "Output directory: ${DOWNLOADS_DIR}"
echo ""

# Generate downloads page
echo -e "${GREEN}📄 Generating downloads page...${NC}"

cat > docs/index.html << 'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DTC Claude Skills - Downloads</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f5f5;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 60px 40px;
            text-align: center;
            border-radius: 12px;
            margin-bottom: 40px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        header h1 {
            font-size: 2.5em;
            margin-bottom: 15px;
            font-weight: 700;
        }

        header p {
            font-size: 1.2em;
            opacity: 0.95;
            margin-bottom: 20px;
        }

        .learn-more {
            display: inline-block;
            background: white;
            color: #667eea;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            transition: transform 0.2s;
        }

        .learn-more:hover {
            transform: translateY(-2px);
        }

        .downloads {
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .downloads h2 {
            color: #333;
            margin-bottom: 30px;
            font-size: 1.8em;
        }

        .skill-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: background 0.2s;
        }

        .skill-item:last-child {
            border-bottom: none;
        }

        .skill-item:hover {
            background: #f8f9fa;
        }

        .skill-name {
            font-size: 1.1em;
            font-weight: 500;
            color: #333;
        }

        .download-btn {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            transition: opacity 0.2s;
        }

        .download-btn:hover {
            opacity: 0.9;
        }

        footer {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }

        footer a {
            color: #667eea;
            text-decoration: none;
        }

        footer a:hover {
            text-decoration: underline;
        }

        @media (max-width: 768px) {
            header h1 {
                font-size: 2em;
            }

            header p {
                font-size: 1em;
            }

            .skill-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }

            .downloads {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>DTC Claude Skills</h1>
            <p>Data-driven analysis skills for Fulfil merchants</p>
            <a href="https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills" class="learn-more">Learn More</a>
        </header>

        <div class="downloads">
            <h2>Download Skills</h2>
HEADER

# Add skill download links
for skill_info in "${SKILLS[@]}"; do
    IFS='|' read -r zip_name skill_name <<< "$skill_info"
    cat >> docs/index.html << SKILL
            <div class="skill-item">
                <span class="skill-name">$skill_name</span>
                <a href="downloads/$zip_name" class="download-btn">📥 Download</a>
            </div>
SKILL
done

cat >> docs/index.html << 'FOOTER'
        </div>

        <footer>
            <p>
                <a href="https://github.com/fulfilio/dtc-claude-skills" target="_blank">View on GitHub</a> •
                <a href="https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills">Documentation</a> •
                <a href="https://github.com/fulfilio/mcp-server-fulfil">Fulfil MCP Connector</a>
            </p>
        </footer>
    </div>
</body>
</html>
FOOTER

echo -e "  ✓ Created docs/index.html"
echo ""

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Commit the changes: ${YELLOW}git add docs/ && git commit -m 'Build skill packages'${NC}"
echo -e "  2. Push to GitHub: ${YELLOW}git push origin master${NC}"
echo -e "  3. Enable GitHub Pages in repository settings (source: master branch, /docs folder)"
echo -e "  4. Site will be available at: ${YELLOW}https://fulfilio.github.io/dtc-claude-skills/${NC}"
echo ""
