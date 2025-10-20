# DTC Claude Skills

A curated collection of Claude skills designed specifically for Fulfil merchants. These skills leverage the Fulfil MCP (Model Context Protocol) connector to analyze data, generate insights, and automate workflows directly within Claude.

## 📚 Documentation

For complete documentation, installation guides, and examples, visit:

**[https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills](https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills)**

## 📥 Downloads

Download ready-to-use skills from our GitHub Pages:

**[https://fulfilio.github.io/dtc-claude-skills/](https://fulfilio.github.io/dtc-claude-skills/)**

## Available Skills

### 1. Free Shipping Threshold Analysis
**[Download](https://fulfilio.github.io/dtc-claude-skills/downloads/01-free-shipping-threshold.zip)** | [Details](./01-free-shipping-threshold/README.md)

Determine your most profitable free shipping threshold using data-driven analysis of your order patterns.

---

## Quick Start

1. **Download a skill** from the link above
2. **Extract the ZIP file**
3. **Upload the files to Claude** in a new conversation
4. **Ask Claude to run the analysis**

For detailed instructions, see the [full documentation](https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills).

## Development

### Building Skill Packages

Skill packages are automatically built and deployed via GitHub Actions on every push to the `master` branch.

To build manually:

```bash
./build.sh
```

This will:
- Create ZIP files for each skill in `docs/downloads/`
- Generate the download index page at `docs/index.html`
- Display build summary and next steps

The build process runs automatically when:
- Any skill folder (`##-skill-name/`) is modified
- The build script is updated
- The workflow file is changed

### Skill Structure

Each skill folder follows this structure:

```
##-skill-name/
├── SKILL.md           # Comprehensive guide for Claude
├── README.md          # User-facing documentation
└── QUICK_REFERENCE.md # Quick reference card
```

### Contributing

We welcome contributions! To add a new skill:

1. Fork this repository
2. Create a new skill folder: `##-skill-name/`
3. Include all three markdown files
4. Run `./build.sh` to generate packages
5. Submit a pull request

For contribution guidelines, see the [documentation](https://fulfil-website-b7a103a9a1c8.herokuapp.com/resources/claude-skills).

## License

MIT License
