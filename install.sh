#!/usr/bin/env bash
set -euo pipefail

##
# Installs or updates AI agent foundation inside the project where this script is run.
#
# Expected result in the consuming project:
#   .agents/foundation/  A gitignored checkout of mattkingshott/agent-foundation.
#   .agents/skills/      A AI agent-discoverable skills location.
#   AGENTS.md            A small router block pointing AI agent at the foundation.
#
# The script is designed to be run from a project root via a package/composer
# script, curl/bootstrap command, or a temporary clone of this foundation repo.
##

DEFAULT_REPO="https://github.com/mattkingshott/agent-foundation.git"

##
# Configuration.
#
# Each value can be overridden by an environment variable when a project needs
# a fork, custom install directory, or non-standard AGENTS.md filename.
##
FOUNDATION_REPO="${AGENT_FOUNDATION_REPO:-}"
FOUNDATION_DIR="${AGENT_FOUNDATION_DIR:-.agents/foundation}"
SKILLS_DIR="${AGENT_SKILLS_DIR:-.agents/skills}"
PROJECT_AGENTS_FILE="${AGENT_PROJECT_FILE:-AGENTS.md}"
PROJECT_STACK="${AGENT_PROJECT_STACK:-}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

##
# Work out which repository should be cloned into .agents/foundation.
#
# Priority:
#   1. AGENT_FOUNDATION_REPO, when explicitly provided.
#   2. The origin remote of this script's git checkout, useful for forks.
#   3. DEFAULT_REPO, the canonical foundation repository.
##
if [ -z "$FOUNDATION_REPO" ]; then
    if git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        FOUNDATION_REPO="$(git -C "$SCRIPT_DIR" config --get remote.origin.url || true)"
    fi
fi

if [ -z "$FOUNDATION_REPO" ]; then
    FOUNDATION_REPO="$DEFAULT_REPO"
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

    grep -vxE '[.]agents/.*' "$file" | awk '
        seen || NF { seen = 1; lines[++count] = $0 }
        END {
            while (count > 0 && lines[count] == "") {
                count--
            }

            for (line_index = 1; line_index <= count; line_index++) {
                print lines[line_index]
            }
        }
    ' > "$rest_file" || true

    {
        {
            printf "%s\n" "$line"
            grep -xE '[.]agents/.*' "$file" || true
        } | awk 'NF && !seen[$0]++' | sort

        if [ -s "$rest_file" ]; then
            cat "$rest_file"
        fi
    } > "$tmp_file"

    mv "$tmp_file" "$file"
    rm -f "$rest_file"
}

##
# Return true when the project AGENTS.md already contains the foundation router.
#
# Re-running the installer should update foundation, not append duplicate router
# instructions or repeatedly ask for the project stack.
##
project_has_stack_reference() {
    [ -f "$PROJECT_AGENTS_FILE" ] && grep -qF "Before doing anything, read" "$PROJECT_AGENTS_FILE"
}

##
# Keep only the runtime files in the installed checkout.
#
# A sparse checkout avoids installing project-maintenance files such as this
# installer, README, LICENSE, and the repo's own .gitignore into consuming
# projects.
##
configure_foundation_checkout() {
    git -C "$FOUNDATION_DIR" sparse-checkout init --no-cone
    git -C "$FOUNDATION_DIR" sparse-checkout set --no-cone \
        /AGENTS.md \
        /rules/ \
        /skills/ \
        /stacks/
}

##
# Clone the foundation repository on first run, then fast-forward it on later runs.
#
# The checkout lives inside the consuming project, but is intended to be
# gitignored so projects do not fight over foundation repo contents.
##
install_or_update_foundation() {
    mkdir -p "$(dirname "$FOUNDATION_DIR")"

    if [ -d "$FOUNDATION_DIR/.git" ]; then
        configure_foundation_checkout
        git -C "$FOUNDATION_DIR" pull --ff-only
        return
    fi

    if [ -e "$FOUNDATION_DIR" ]; then
        cat >&2 <<EOF
Cannot install foundation because '$FOUNDATION_DIR' already exists and is not a Git checkout.
Move it away, remove it, or set AGENT_FOUNDATION_DIR to another location.
EOF
        exit 1
    fi

    git clone --filter=blob:none --sparse "$FOUNDATION_REPO" "$FOUNDATION_DIR"
    configure_foundation_checkout
}

##
# Ensure the foundation checkout is ignored by the consuming project.
#
# Projects should commit their local router and project-specific skills, but not
# the pulled foundation repository itself.
##
install_gitignore_entry() {
    add_sorted_once ".gitignore" "$FOUNDATION_DIR/"
}

##
# Expose foundation skills through a location AI agent actually scans.
#
# AI agent does not discover skills from arbitrary folders like
# .agents/foundation/skills. It discovers repo skills from .agents/skills.
#
# Keep .agents/skills as a real directory so projects can add their own skills
# later. Each foundation skill is exposed as an individual generated symlink
# inside it, and each generated symlink is ignored individually.
##
install_skill_links() {
    local foundation_skills="$FOUNDATION_DIR/skills"

    if [ ! -d "$foundation_skills" ]; then
        return
    fi

    if [ -L "$SKILLS_DIR" ]; then
        cat >&2 <<EOF
Cannot expose skills because '$SKILLS_DIR' is a symlink.
Replace it with a real directory so project-specific skills can live alongside foundation skills.
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

    for skill in "$foundation_skills"/*; do
        [ -d "$skill" ] || continue

        local skill_name
        skill_name="$(basename "$skill")"

        if [ ! -e "$SKILLS_DIR/$skill_name" ]; then
            ln -s "../foundation/skills/$skill_name" "$SKILLS_DIR/$skill_name"
        fi

        add_sorted_once ".gitignore" "$SKILLS_DIR/$skill_name"
    done
}

##
# Ask which stack applies to the consuming project.
#
# The valid options are discovered from .agents/foundation/stacks/*.md after the
# foundation repo has been installed or updated. For non-interactive scripts,
# AGENT_PROJECT_STACK can be set to either a stack slug like "nuxt-spa" or a
# filename like "nuxt-spa.md".
##
select_project_stack() {
    local stacks_dir="$FOUNDATION_DIR/stacks"
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
# This is not an include system. It tells AI agent, in the project guidance it
# already discovers, to read the foundation guidance and selected stack file
# before doing project work.
##
install_agents_router() {
    local read_targets="\`$FOUNDATION_DIR/AGENTS.md\`"
    local last_two_bytes

    touch "$PROJECT_AGENTS_FILE"

    if grep -qF "Before doing anything, read" "$PROJECT_AGENTS_FILE"; then
        return
    fi

    if [ -n "${SELECTED_STACK_PATH:-}" ]; then
        read_targets="$read_targets and \`$SELECTED_STACK_PATH\`"
    fi

    if [ -s "$PROJECT_AGENTS_FILE" ]; then
        if [ -n "$(tail -c 1 "$PROJECT_AGENTS_FILE")" ]; then
            printf '\n\n' >> "$PROJECT_AGENTS_FILE"
        else
            last_two_bytes="$(tail -c 2 "$PROJECT_AGENTS_FILE" | od -An -tx1 | tr -d ' \n')"

            if [ "$last_two_bytes" != "0a0a" ]; then
                printf '\n' >> "$PROJECT_AGENTS_FILE"
            fi
        fi
    fi

    printf 'Before doing anything, read %s.\n' "$read_targets" >> "$PROJECT_AGENTS_FILE"
}

##
# Run the installer steps in dependency order.
##
install_or_update_foundation
install_gitignore_entry
install_skill_links
select_project_stack
install_agents_router

cat <<EOF
Agent foundation installed.

Foundation: $FOUNDATION_DIR
Skills:     $SKILLS_DIR
Router:     $PROJECT_AGENTS_FILE
EOF
