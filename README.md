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
**[Download](https://fulfilio.github.io/dtc-claude-skills/downloads/01-free-shipping-threshold.zip)** | [Details](./01-free-shipping-threshold/README.md)

Determine your most profitable free shipping threshold using data-driven analysis of your order patterns.

### 2. Fulfillment Optimization
**[Download](https://fulfilio.github.io/dtc-claude-skills/downloads/02-fulfillment-optimization.zip)** | [Details](./02-fulfillment-optimization/README.md)

Analyze your shipment backlog and generate actionable recommendations for clearing orders efficiently.

---

## Quick Start

1. **Download a skill** from the link above
2. **Extract the ZIP file**
3. **Upload the files to Claude** in a new conversation
4. **Ask Claude to run the analysis**

For detailed instructions, see the [full documentation](https://fulfil.io/resources/claude-skills).

## Development

### Building Skill Packages

Skills are automatically built and deployed to GitHub Pages via GitHub Actions.

**How it works**:
1. When changes are pushed to the `master` branch, GitHub Actions workflow triggers
2. The workflow scans for skill directories matching the `##-skill-name` pattern
3. Each skill is packaged into a ZIP file in the `downloads/` directory
4. The downloads directory is deployed to GitHub Pages
5. Skills are available at `https://fulfilio.github.io/dtc-claude-skills/downloads/`

The build process automatically creates ZIP packages from all skill directories that contain a `SKILL.md` file.

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

Your skill will be automatically packaged and deployed to GitHub Pages via GitHub Actions once merged.

For contribution guidelines and skill development best practices, see the [documentation](https://fulfil.io/resources/claude-skills) and [SKILLS_BEST_PRACTICES.md](SKILLS_BEST_PRACTICES.md).

## License

MIT License
