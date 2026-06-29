---
name: task-optimize-code
description: Refactor, simplify, validate, and repair the current unstaged repository changes while preserving intended features and functionality. Use when Codex should critically improve existing working-tree changes before review or commit, especially by reducing unnecessary code, removing dead or speculative abstractions, preserving behavior, and reporting remaining risks.
---

# Task Optimize Code

Improve the current unstaged changes in the repository with a bias toward minimal, readable, maintainable code.

Start by understanding the working tree:

```bash
git status --porcelain
git diff --stat
git diff
```

If staged changes exist, inspect them too:

```bash
git diff --cached --stat
git diff --cached
```

If task context exists in `TASK.md`, `SPEC.md`, issue notes, or recent conversation, use it only to infer the intended behavior. Do not preserve complexity merely because it is already present.

## Preparation: Learn the Codebase

Before modifying any code, study the existing committed codebase to understand how the project is designed.

Look for established patterns such as:

* Architectural conventions
* Naming conventions
* File organization
* Dependency usage
* Error handling approaches
* Testing styles
* Validation patterns
* State management patterns
* API design conventions
* UI composition patterns
* Framework-specific practices

Pay particular attention to:

* Frequently repeated patterns
* Existing abstractions that are widely adopted
* Project-specific conventions that differ from generic best practices

Treat repeated patterns as intentional unless there is strong evidence otherwise.

Your goal is not to determine how you would build the project from scratch.

Your goal is to determine:

"How do the maintainers want this codebase to look and feel?"

Use those observations to guide all subsequent decisions.

When choosing between multiple valid implementations:

1. Follow existing project conventions.
2. Follow existing project architecture.
3. Prefer consistency with surrounding code.
4. Only introduce a different pattern when there is a clear and significant benefit.

Do not create new architectural styles when an established one already exists.

## Minimality Ladder

After understanding the task and tracing the real code path, choose the first rung that safely satisfies the requirement:

1. Do not build it if the requirement is already covered or is speculative.
2. Reuse an existing project helper, component, pattern, or API.
3. Use the language standard library or framework feature.
4. Use a native platform capability.
5. Use an already-installed dependency when it is a natural fit.
6. Write the smallest clear implementation that works.

Do not climb this ladder before understanding the problem. A small change in the wrong layer is not simpler; it is a future bug with fewer lines.

## Phase 1: Simplify

Review all unstaged changes and refactor them to the simplest implementation that appears to satisfy the requirements.

Prefer, in order:

1. Deleting code over adding code.
2. Existing abstractions over new abstractions.
3. Direct, explicit code over indirection.
4. Local changes over broad architectural changes.
5. Stable public APIs unless a change is clearly justified.

Actively remove unnecessary configuration, helpers, wrappers, traits, services, hooks, utilities, components, classes, speculative flexibility, premature optimization, duplication, and stale comments.

Ask repeatedly: can this be implemented with fewer files, fewer concepts, fewer lines, or fewer moving parts? If yes, simplify it, but only to a point where it still remains interpretable to developers - extreme minimalism that is indecipherable is not a win.

Do not treat shorter code as automatically better. Avoid:

- Clever one-liners that hide control flow or make debugging harder.
- Replacing readable domain code with dense generic code.
- Local patches that leave the same bug in sibling callers.
- New dependencies, abstractions, or configuration for convenience only.

When a simplification has a known ceiling, document the tradeoff briefly in normal project style. Examples include an intentionally linear scan, a deliberately local-only cache, or a heuristic that may need to become a proper parser later.

## Phase 2: Validate

Critically review the simplified result. Do not assume it is correct because it compiles or looks tidy.

Look for:

- Logic errors and edge case failures
- Race conditions and incorrect assumptions
- Missing validation or unsafe input handling
- Null or undefined handling issues
- Type inconsistencies
- Broken imports or references
- Dead code, unused variables, unused methods, and unused classes
- Stale comments, documentation, or tests
- Incorrect naming
- Backwards compatibility issues
- Security concerns
- Performance regressions introduced by the refactor

For bug fixes, identify the root cause before changing code. Search every caller or entry point related to the function, component, route, command, hook, or API being touched. Prefer one correct fix at the shared source of behavior over scattered guards at individual call sites.

Run the narrowest relevant verification commands available in the repo. Prefer existing test, lint, typecheck, or formatter scripts over inventing new checks. If the correct command is unclear, inspect package or project scripts before choosing.

For non-trivial logic, leave behind the smallest durable check that would fail if the behavior regresses. This can be a focused unit test, existing test extension, or small self-check if that is the local convention. Trivial mechanical removals or obvious one-line changes do not need new tests.

## Phase 3: Repair

Fix every issue discovered during validation.

When multiple repairs are possible, choose the solution with the least code, fewest concepts, and clearest future maintenance path.

After repair, rerun the relevant checks when practical. If a check cannot be run, explain why.

## Guardrails

- Preserve unrelated user changes.
- Do not introduce new dependencies unless there is no simpler viable option.
- Do not broaden the task beyond the changed behavior unless required to make the implementation correct.
- Do not perform destructive git operations.
- Do not commit unless explicitly asked.

## Final Response

Provide these sections:

**Summary**
Concise explanation of what was simplified and why.

**Changes Made**
Categorized list covering applicable items:

- Simplifications
- Bug fixes
- Dead code removals
- Naming improvements
- Safety improvements

**Remaining Concerns**
Questionable items that cannot be safely fixed without more requirements or domain knowledge.

**Final Assessment**
State whether the resulting implementation is simpler, safer, and easier to maintain, and explain why.
