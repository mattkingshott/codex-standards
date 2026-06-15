#!/usr/bin/env bash
set -euo pipefail

##
# Installs or updates Codex standards inside the project where this script is run.
#
# Expected result in the consuming project:
#   .agents/standards/  A gitignored checkout of mattkingshott/codex-standards.
#   .agents/skills/     A Codex-discoverable skills location.
#   AGENTS.md           A small router block pointing Codex at the standards.
#
# The script is designed to be run from a project root via a package/composer
# script, curl/bootstrap command, or a temporary clone of this standards repo.
##

DEFAULT_REPO="https://github.com/mattkingshott/codex-standards.git"

##
# Configuration.
#
# Each value can be overridden by an environment variable when a project needs
# a fork, custom install directory, or non-standard AGENTS.md filename.
##
STANDARDS_REPO="${AGENT_STANDARDS_REPO:-}"
STANDARDS_DIR="${AGENT_STANDARDS_DIR:-.agents/standards}"
SKILLS_DIR="${AGENT_SKILLS_DIR:-.agents/skills}"
PROJECT_AGENTS_FILE="${AGENT_PROJECT_FILE:-AGENTS.md}"
PROJECT_STACK="${AGENT_PROJECT_STACK:-}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

##
# Work out which repository should be cloned into .agents/standards.
#
# Priority:
#   1. AGENT_STANDARDS_REPO, when explicitly provided.
#   2. The origin remote of this script's git checkout, useful for forks.
#   3. DEFAULT_REPO, the canonical standards repository.
##
if [ -z "$STANDARDS_REPO" ]; then
    if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        STANDARDS_REPO="$(git -C "$SCRIPT_DIR" config --get remote.origin.url || true)"
    fi
fi

if [ -z "$STANDARDS_REPO" ]; then
    STANDARDS_REPO="$DEFAULT_REPO"
fi

##
# Add a single line to a file only when it is not already present.
#
# The line is inserted with the file's other leading ignore entries, sorted
# alphabetically. Any existing comments or later sections are kept below those
# generated entries.
##
add_sorted_once() {
    local file="$1"
    local line="$2"
    local rest_file
    local tmp_file

    touch "$file"

    if grep -qxF "$line" "$file"; then
        return
    fi

    rest_file="$(mktemp)"
    tmp_file="$(mktemp)"

    grep -vxE '[.]agents/.*' "$file" > "$rest_file" || true

    {
        {
            printf "%s\n" "$line"
            grep -xE '[.]agents/.*' "$file" || true
        } | awk 'NF && !seen[$0]++' | sort

        if [ -s "$rest_file" ]; then
            printf '\n'
            cat "$rest_file"
        fi
    } > "$tmp_file"

    mv "$tmp_file" "$file"
    rm -f "$rest_file"
}

##
# Return true when the project AGENTS.md already contains the standards router.
#
# Re-running the installer should update standards, not append duplicate router
# instructions or repeatedly ask for the project stack.
##
project_has_stack_reference() {
    [ -f "$PROJECT_AGENTS_FILE" ] && grep -qF "Before doing anything, read" "$PROJECT_AGENTS_FILE"
}

##
# Clone the standards repository on first run, then fast-forward it on later runs.
#
# The checkout lives inside the consuming project, but is intended to be
# gitignored so projects do not fight over standards repo contents.
##
install_or_update_standards() {
    mkdir -p "$(dirname "$STANDARDS_DIR")"

    if [ -d "$STANDARDS_DIR/.git" ]; then
        git -C "$STANDARDS_DIR" pull --ff-only
        return
    fi

    if [ -e "$STANDARDS_DIR" ]; then
        cat >&2 <<EOF
Cannot install standards because '$STANDARDS_DIR' already exists and is not a Git checkout.
Move it away, remove it, or set AGENT_STANDARDS_DIR to another location.
EOF
        exit 1
    fi

    git clone "$STANDARDS_REPO" "$STANDARDS_DIR"
}

##
# Ensure the standards checkout is ignored by the consuming project.
#
# Projects should commit their local router and project-specific skills, but not
# the pulled standards repository itself.
##
install_gitignore_entry() {
    add_sorted_once ".gitignore" "$STANDARDS_DIR/"
}

##
# Expose standards skills through a location Codex actually scans.
#
# Codex does not discover skills from arbitrary folders like
# .agents/standards/skills. It discovers repo skills from .agents/skills.
#
# Keep .agents/skills as a real directory so projects can add their own skills
# later. Each standards skill is exposed as an individual generated symlink
# inside it, and each generated symlink is ignored individually.
##
install_skill_links() {
    local standards_skills="$STANDARDS_DIR/skills"

    if [ ! -d "$standards_skills" ]; then
        return
    fi

    if [ -L "$SKILLS_DIR" ]; then
        cat >&2 <<EOF
Cannot expose skills because '$SKILLS_DIR' is a symlink.
Replace it with a real directory so project-specific skills can live alongside standards skills.
EOF
        exit 1
    fi

    mkdir -p "$SKILLS_DIR"

    if [ ! -d "$SKILLS_DIR" ]; then
        cat >&2 <<EOF
Cannot expose skills because '$SKILLS_DIR' exists and is not a directory.
EOF
        exit 1
    fi

    for skill in "$standards_skills"/*; do
        [ -d "$skill" ] || continue

        local skill_name
        skill_name="$(basename "$skill")"

        if [ ! -e "$SKILLS_DIR/$skill_name" ]; then
            ln -s "../standards/skills/$skill_name" "$SKILLS_DIR/$skill_name"
        fi

        add_sorted_once ".gitignore" "$SKILLS_DIR/$skill_name"
    done
}

##
# Ask which stack applies to the consuming project.
#
# The valid options are discovered from .agents/standards/stacks/*.md after the
# standards repo has been installed or updated. For non-interactive scripts,
# AGENT_PROJECT_STACK can be set to either a stack slug like "nuxt-spa" or a
# filename like "nuxt-spa.md".
##
select_project_stack() {
    local stacks_dir="$STANDARDS_DIR/stacks"
    local stack_paths=()
    local stack_names=()
    local stack_path
    local stack_name
    local index

    SELECTED_STACK_PATH=""

    if project_has_stack_reference; then
        return
    fi

    if [ ! -d "$stacks_dir" ]; then
        return
    fi

    for stack_path in "$stacks_dir"/*.md; do
        [ -f "$stack_path" ] || continue

        stack_name="$(basename "$stack_path" .md)"
        stack_paths+=("$stack_path")
        stack_names+=("$stack_name")
    done

    if [ "${#stack_paths[@]}" -eq 0 ]; then
        return
    fi

    if [ -n "$PROJECT_STACK" ]; then
        PROJECT_STACK="${PROJECT_STACK%.md}"

        for index in "${!stack_names[@]}"; do
            if [ "$PROJECT_STACK" = "${stack_names[$index]}" ]; then
                SELECTED_STACK_PATH="${stack_paths[$index]}"
                return
            fi
        done

        cat >&2 <<EOF
Unknown project stack: $PROJECT_STACK

Valid stacks:
EOF
        for stack_name in "${stack_names[@]}"; do
            printf '  - %s\n' "$stack_name" >&2
        done

        exit 1
    fi

    if [ ! -t 0 ]; then
        cat >&2 <<EOF
No project stack selected because the installer is running non-interactively.
Set AGENT_PROJECT_STACK to one of the available stack names to configure it.
EOF
        return
    fi

    printf '\nWhich stack does this project use?\n'

    for index in "${!stack_names[@]}"; do
        printf '  %s) %s\n' "$((index + 1))" "${stack_names[$index]}"
    done

    while true; do
        printf 'Select a stack [1-%s]: ' "${#stack_names[@]}"
        read -r index

        if [ "$index" -ge 1 ] 2>/dev/null && [ "$index" -le "${#stack_names[@]}" ] 2>/dev/null; then
            SELECTED_STACK_PATH="${stack_paths[$((index - 1))]}"
            return
        fi

        printf 'Please enter a number from 1 to %s.\n' "${#stack_names[@]}"
    done
}

##
# Add a router sentence to the consuming project's AGENTS.md.
#
# This is not an include system. It tells Codex, in the project guidance it
# already discovers, to read the standards guidance and selected stack file
# before doing project work.
##
install_agents_router() {
    local read_targets="$STANDARDS_DIR/AGENTS.md"

    touch "$PROJECT_AGENTS_FILE"

    if grep -qF "Before doing anything, read" "$PROJECT_AGENTS_FILE"; then
        return
    fi

    if [ -n "${SELECTED_STACK_PATH:-}" ]; then
        read_targets="$read_targets and $SELECTED_STACK_PATH"
    fi

    if [ -s "$PROJECT_AGENTS_FILE" ]; then
        printf '\n' >> "$PROJECT_AGENTS_FILE"
    fi

    printf 'Before doing anything, read %s.\n' "$read_targets" >> "$PROJECT_AGENTS_FILE"
}

##
# Run the installer steps in dependency order.
##
install_or_update_standards
install_gitignore_entry
install_skill_links
select_project_stack
install_agents_router

cat <<EOF
Agent standards installed.

Standards: $STANDARDS_DIR
Skills:    $SKILLS_DIR
Router:    $PROJECT_AGENTS_FILE
EOF
