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

Skill packages are automatically built and deployed via GitHub Actions on every push to the `master` branch.

**How it works**:
1. You push changes to `master` branch
2. GitHub Action runs `build.py` (Python + Jinja2)
3. Generated files are committed to `gh-pages` branch
4. GitHub Pages deploys from `gh-pages` branch

This keeps `master` clean with only source files, while `gh-pages` contains the built artifacts.

To build manually (for testing):

```bash
pip install -r requirements.txt
python build.py
```

This will:
- Parse frontmatter from each skill's README.md
- Create ZIP files for each skill in `docs/downloads/`
- Generate the download index page at `docs/index.html` using Jinja2 templates
- Display build summary

The build process runs automatically when:
- Any skill folder (`##-skill-name/`) is modified
- Build script or templates are updated
- The workflow file is changed

### Skill Structure

Each skill folder follows this structure:

```
##-skill-name/
├── SKILL.md           # Comprehensive guide for Claude
├── README.md          # User-facing documentation with frontmatter
└── QUICK_REFERENCE.md # Quick reference card
```

**README.md Frontmatter**:
```yaml
---
title: Skill Title
description: Short description shown on download page
author: Your Name
version: 1.0
tags: [tag1, tag2, tag3]
learn_more_url: https://fulfil-website.com/resources/claude-skills/your-skill
---
```

**Frontmatter Fields**:
- `title` (required): Display name of the skill
- `description` (required): Brief description shown on download page
- `version` (required): Version number (e.g., 1.0, 1.1)
- `author`: Author or organization name
- `tags`: List of categorization tags
- `learn_more_url`: URL to detailed documentation (opens in new tab)

### Contributing

We welcome contributions! To add a new skill:

1. Fork this repository
2. Create a new skill folder: `##-skill-name/`
3. Include all three markdown files (SKILL.md, README.md, QUICK_REFERENCE.md)
4. Add frontmatter to README.md with title, description, version, author, and tags
5. Run `python build.py` to test locally
6. Submit a pull request

The GitHub Action will automatically build and deploy your skill once merged.

For contribution guidelines, see the [documentation](https://fulfil.io/resources/claude-skills).

## License

MIT License
