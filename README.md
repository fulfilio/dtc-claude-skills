# DTC Claude Skills

A curated collection of Claude skills designed specifically for Fulfil merchants. These skills leverage the Fulfil MCP (Model Context Protocol) connector to analyze data, generate insights, and automate workflows directly within Claude.

## 📚 Documentation

For complete documentation, installation guides, and examples, visit:

**[https://fulfil.io/resources/claude-skills](https://fulfil.io/resources/claude-skills)**

## 📥 Downloads

Download ready-to-use skills from the Fulfil website:

**[https://fulfil.io/resources/claude-skills](https://fulfil.io/resources/claude-skills)**

## Available Skills

### 1. Free Shipping Threshold Analysis
**[Download](https://fulfil.io/static/downloads/claude-skills/01-free-shipping-threshold.zip)** | [Details](./01-free-shipping-threshold/README.md)

Determine your most profitable free shipping threshold using data-driven analysis of your order patterns.

---

## Quick Start

1. **Download a skill** from the link above
2. **Extract the ZIP file**
3. **Upload the files to Claude** in a new conversation
4. **Ask Claude to run the analysis**

For detailed instructions, see the [full documentation](https://fulfil.io/resources/claude-skills).

## Development

### Building Skill Packages

Skills are built and packaged as part of the [fulfil.io website](https://github.com/fulfilio/website) deployment process.

**How it works**:
1. This repository is included as a git submodule in the website repository
2. The website's build script (`scripts/build_claude_skills.py`) scans for skill directories
3. Each skill is packaged into a ZIP file and copied to `static/downloads/claude-skills/`
4. Skills are served directly from the website at `/static/downloads/claude-skills/`

The website build process automatically creates ZIP packages from all skill directories matching the `##-skill-name` pattern.

### Skill Structure

Each skill folder follows this structure:

```
##-skill-name/
├── SKILL.md           # Comprehensive guide for Claude
├── README.md          # User-facing documentation
└── QUICK_REFERENCE.md # Quick reference card
```

The skill package (ZIP file) includes all files in the skill directory.

### Contributing

We welcome contributions! To add a new skill:

1. Fork this repository
2. Create a new skill folder: `##-skill-name/`
3. Include all three markdown files (SKILL.md, README.md, QUICK_REFERENCE.md)
4. Submit a pull request

Your skill will be automatically packaged and deployed as part of the fulfil.io website build process once merged.

For contribution guidelines and skill development best practices, see the [documentation](https://fulfil.io/resources/claude-skills) and [SKILLS_BEST_PRACTICES.md](SKILLS_BEST_PRACTICES.md).

## License

MIT License
