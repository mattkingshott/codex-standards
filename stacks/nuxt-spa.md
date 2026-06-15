# Nuxt SPA

This describes the rules, development commands, architecture, technology, and guidance for a Nuxt SPA project.

This project type involves a single repository with Nuxt handling all client-side duties. The corresponding server-side element is a separate repository.

## Rules

Reference the relevant rules file in `.agents/standards/rules/` whenever working on matching files:

- [.agents/standards/rules/general.md](.agents/standards/rules/general.md) — General code formatting and style patterns. Always reference for any code change.
- [.agents/standards/rules/tailwind.md](.agents/standards/rules/tailwind.md) — TailwindCSS rules. Reference when editing files matching `*.vue`.
- [.agents/standards/rules/javascript.md](.agents/standards/rules/javascript.md) — JavaScript style rules (including Alpine.js within Blade). Reference when editing files matching `*.js` or `*.vue`.
- [.agents/standards/rules/vue.md](.agents/standards/rules/vue.md) — Vue templating and script rules. Reference when editing files matching `*.vue`.

## Commands

```bash
npm run dev     # Start Vite dev server
npm run build   # Build production frontend assets
npm run tests   # Run the test suite
```

## Architecture

### Directory Structure

- `app/assets/` - Static assets (fonts, icons, images)
- `app/components/` - Reusable components
- `app/layouts/` - Page layouts
- `app/middleware/` - Nuxt middleware
- `app/pages/` - Page views organized by domain
- `app/partials/` - Partial views organized by domain
- `app/plugins/` - Nuxt plugins
- `app/routes/` - Server and client side routes
- `app/utils/` - Reusable utilities / mixins e.g. shared form field logic

### Key Patterns

- Explore existing `pages`, `partials`, and `components` to see how they are used. Always use existing components and patterns.

## Technology

- Vue v3
- Nuxt v4
- Tailwind CSS v4
- Vite

## Technology

## Guidance

- Do not create helper methods in test files, each test should encapsulate all required logic
- Do not run Vite dev server, it is always available at `http://{process.env.HOST}:{process.env.PORT}`
- Do not use browser previews, web browsing, or in-app browser tooling to inspect the app. NPM compilation checks and reviewing generated HTML files are allowed.
- Playwright browser launches may fail inside Codex sandbox on macOS with Firefox/WebKit `SIGABRT` or Chromium `bootstrap_check_in ... Permission denied`. Run Playwright tests unsandboxed/escalated when validating browser behavior.
