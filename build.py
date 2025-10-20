#!/usr/bin/env python3
"""
Build script for DTC Claude Skills
Creates downloadable ZIP files for each skill and generates the GitHub Pages site
"""

import os
import re
import yaml
import zipfile
from pathlib import Path
from jinja2 import Environment, FileSystemLoader


class Colors:
    """ANSI color codes for terminal output"""
    GREEN = '\033[0;32m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color


def parse_frontmatter(content):
    """
    Parse YAML frontmatter from markdown content

    Args:
        content: String content of markdown file

    Returns:
        Tuple of (metadata_dict, content_without_frontmatter)
    """
    # Match YAML frontmatter between --- delimiters
    pattern = r'^---\s*\n(.*?)\n---\s*\n(.*)$'
    match = re.match(pattern, content, re.DOTALL)

    if match:
        try:
            metadata = yaml.safe_load(match.group(1))
            content = match.group(2)
            return metadata, content
        except yaml.YAMLError as e:
            print(f"{Colors.YELLOW}⚠ Warning: Failed to parse frontmatter: {e}{Colors.NC}")
            return {}, content

    return {}, content


def get_skill_metadata(skill_dir):
    """
    Extract metadata from skill's README.md frontmatter

    Args:
        skill_dir: Path to skill directory

    Returns:
        Dictionary with skill metadata or None if parsing fails
    """
    readme_path = skill_dir / "README.md"

    if not readme_path.exists():
        print(f"{Colors.YELLOW}⚠ Warning: {skill_dir.name}/README.md not found{Colors.NC}")
        return None

    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()

        metadata, _ = parse_frontmatter(content)

        if not metadata:
            print(f"{Colors.YELLOW}⚠ Warning: No frontmatter found in {skill_dir.name}/README.md{Colors.NC}")
            return None

        # Validate required fields
        required_fields = ['title', 'description', 'version']
        missing_fields = [field for field in required_fields if field not in metadata]

        if missing_fields:
            print(f"{Colors.YELLOW}⚠ Warning: Missing required fields in {skill_dir.name}: {missing_fields}{Colors.NC}")
            return None

        return metadata

    except Exception as e:
        print(f"{Colors.RED}✗ Error reading {skill_dir.name}/README.md: {e}{Colors.NC}")
        return None


def create_skill_zip(skill_dir, downloads_dir):
    """
    Create a ZIP file containing entire skill directory with all files and subdirectories

    Args:
        skill_dir: Path to skill directory
        downloads_dir: Path to downloads directory

    Returns:
        Tuple of (zip_filename, file_size_str) or (None, None) if failed
    """
    zip_name = f"{skill_dir.name}.zip"
    zip_path = downloads_dir / zip_name

    # Remove old zip if exists
    if zip_path.exists():
        zip_path.unlink()

    try:
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            # Add all files and directories from the skill directory (recursively)
            for item_path in skill_dir.rglob('*'):
                # Skip hidden files and directories
                if item_path.name.startswith('.'):
                    continue

                # Create relative path for the archive (preserves directory structure)
                arcname = item_path.relative_to(skill_dir)

                if item_path.is_file():
                    # Add file with relative path
                    zf.write(item_path, arcname)
                elif item_path.is_dir():
                    # Add directory entry (for empty directories)
                    zf.write(item_path, str(arcname) + '/')

        # Get file size
        size_bytes = zip_path.stat().st_size
        if size_bytes < 1024:
            size_str = f"{size_bytes}B"
        else:
            size_kb = size_bytes / 1024
            size_str = f"{size_kb:.1f}K"

        return zip_name, size_str

    except Exception as e:
        print(f"{Colors.RED}✗ Failed to create {zip_name}: {e}{Colors.NC}")
        return None, None


def build_skills():
    """
    Main build function - finds skills, creates ZIPs, and generates download page
    """
    print(f"{Colors.GREEN}=== Building DTC Claude Skills ==={Colors.NC}\n")

    # Setup paths
    root_dir = Path(__file__).parent
    downloads_dir = root_dir / "docs" / "downloads"
    docs_dir = root_dir / "docs"
    templates_dir = root_dir / "templates"

    # Create directories
    downloads_dir.mkdir(parents=True, exist_ok=True)

    # Find all skill directories (format: ##-skill-name)
    skill_pattern = re.compile(r'^\d{2}-')
    skill_dirs = [d for d in root_dir.iterdir()
                  if d.is_dir() and skill_pattern.match(d.name)]

    if not skill_dirs:
        print(f"{Colors.YELLOW}⚠ No skill directories found{Colors.NC}")
        return

    skills = []
    skill_count = 0

    # Process each skill
    for skill_dir in sorted(skill_dirs):
        # Check for required SKILL.md file
        if not (skill_dir / "SKILL.md").exists():
            print(f"{Colors.YELLOW}⚠ Skipping {skill_dir.name} - missing SKILL.md{Colors.NC}")
            continue

        print(f"{Colors.GREEN}📦 Processing: {skill_dir.name}{Colors.NC}")

        # Get metadata from README frontmatter
        metadata = get_skill_metadata(skill_dir)
        if not metadata:
            continue

        # Create ZIP file
        zip_name, size_str = create_skill_zip(skill_dir, downloads_dir)
        if not zip_name:
            continue

        print(f"  ✓ Created {zip_name} ({size_str})")

        # Add to skills list for template
        skill_data = {
            'zip_name': zip_name,
            'title': metadata.get('title', skill_dir.name),
            'description': metadata.get('description', ''),
            'version': metadata.get('version', '1.0'),
            'author': metadata.get('author', 'Unknown'),
            'tags': metadata.get('tags', []),
            'learn_more_url': metadata.get('learn_more_url', None)
        }
        skills.append(skill_data)
        skill_count += 1
        print()

    # Generate index page from template
    print(f"{Colors.GREEN}=== Build Summary ==={Colors.NC}")
    print(f"Skills packaged: {skill_count}")
    print(f"Output directory: {downloads_dir}")
    print()

    if skill_count > 0:
        print(f"{Colors.GREEN}📄 Generating downloads page...{Colors.NC}")

        try:
            # Setup Jinja2 environment
            env = Environment(loader=FileSystemLoader(templates_dir))
            template = env.get_template('index.html.j2')

            # Render template
            html_content = template.render(skills=skills)

            # Write output
            index_path = docs_dir / "index.html"
            with open(index_path, 'w', encoding='utf-8') as f:
                f.write(html_content)

            print(f"  ✓ Created docs/index.html")
            print()
            print(f"{Colors.GREEN}✅ Build complete!{Colors.NC}")

        except Exception as e:
            print(f"{Colors.RED}✗ Failed to generate index page: {e}{Colors.NC}")
            return
    else:
        print(f"{Colors.YELLOW}⚠ No skills were processed{Colors.NC}")


if __name__ == "__main__":
    build_skills()
