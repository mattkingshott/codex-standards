# Codex Standards

Shared Codex instructions, stack guidance, rules, and skills for projects.

This is an internal standards repository that will change without warning. It is
not intended to be installed or consumed directly by other developers, because
the guidance is opinionated around personal project structure and workflows.
You are welcome to read it, copy ideas, and adapt the patterns for your own
standards repo.

This repository is intended to be pulled into a consuming project under
`.agents/standards`. The installer wires the project so Codex can discover the
standards guidance and skills without committing the standards checkout itself.

## Install

From a project root, run:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/mattkingshott/codex-standards.git "$tmp" && "$tmp/install.sh"
```

For non-interactive setup, pass the project stack:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/mattkingshott/codex-standards.git "$tmp" && AGENT_PROJECT_STACK=laravel-monolith "$tmp/install.sh"
```

Available stack names are discovered from `stacks/*.md`.

## What The Installer Does

The installer:

- clones or updates this repo into `.agents/standards`
- adds `.agents/standards/` to the consuming project's `.gitignore`
- keeps `.agents/skills` as a real directory
- symlinks each standards skill into `.agents/skills`
- adds each generated standards skill symlink to `.gitignore`
- appends a standards router sentence to the project's `AGENTS.md`
- asks which stack the project uses when one has not already been configured

Generated standards wiring is ignored. Project-specific skills under
`.agents/skills` can still be committed normally.

## Project Scripts

You can wrap the install command in a project script.

Composer:

```json
{
  "scripts": {
    "standards": "tmp=\"$(mktemp -d)\" && git clone --depth 1 https://github.com/mattkingshott/codex-standards.git \"$tmp\" && \"$tmp/install.sh\""
  }
}
```

Node Package Manager:

```json
{
  "scripts": {
    "standards": "tmp=\"$(mktemp -d)\" && git clone --depth 1 https://github.com/mattkingshott/codex-standards.git \"$tmp\" && \"$tmp/install.sh\""
  }
}
```

Then run the project command whenever you want to install or update standards.

## Configuration

The installer supports these environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `AGENT_STANDARDS_REPO` | `https://github.com/mattkingshott/codex-standards.git` | Repository to clone or update. |
| `AGENT_STANDARDS_DIR` | `.agents/standards` | Standards checkout location. |
| `AGENT_SKILLS_DIR` | `.agents/skills` | Codex-discoverable skills location. |
| `AGENT_PROJECT_FILE` | `AGENTS.md` | Project instructions file to update. |
| `AGENT_PROJECT_STACK` | empty | Stack slug, such as `nuxt-spa` or `laravel-api`. |

## Resulting Project Shape

After installation, a consuming project looks like this:

```text
.agents/
  standards/          # ignored checkout of this repository
  skills/
    task-build-feature -> ../standards/skills/task-build-feature
    task-plan-feature -> ../standards/skills/task-plan-feature
    project-skill/    # optional project-specific skill, committed normally
AGENTS.md
```

The router sentence points Codex at the standards guidance and the selected
stack file.
