# Laravel Monolith

This describes the rules, development commands, architecture, technology, and guidance for a Laravel Monolith project.

This project type involves a single repository with Laravel handling both server-side duties, as well as client-side duties in the form of Blade views combined with TurboJS and AlpineJS.

## Rules

Reference the relevant rules file in `.agents/standards/rules/` whenever working on matching files:

- [.agents/standards/rules/general.md](.agents/standards/rules/general.md) — General code formatting and style patterns. Always reference for any code change.
- [.agents/standards/rules/php.md](.agents/standards/rules/php.md) — PHP style rules. Reference when editing files matching `{app,bootstrap,config,database,routes,tests}/**/*.php`.
- [.agents/standards/rules/laravel.md](.agents/standards/rules/laravel.md) — Laravel-specific patterns. Reference when editing files matching `{app,bootstrap,config,database,routes,tests}/**/*.php`.
- [.agents/standards/rules/blade.md](.agents/standards/rules/blade.md) — Laravel Blade templating rules. Reference when editing files matching `resources/views/**/*.blade.php`.
- [.agents/standards/rules/tailwind.md](.agents/standards/rules/tailwind.md) — TailwindCSS rules. Reference when editing files matching `resources/views/**/*.blade.php`.
- [.agents/standards/rules/javascript.md](.agents/standards/rules/javascript.md) — JavaScript style rules (including Alpine.js within Blade). Reference when editing files matching `resources/views/**/*.js` or `resources/views/**/*.blade.php`.

## Commands

```bash
npm run dev     # Start Vite dev server
npm run build   # Build production frontend assets
```

**Testing:**
```bash
composer server-tests          # Run all server-side tests (PHPUnit)
composer server-tests-filter   # Run filtered server-side tests (append filter name)
composer client-tests          # Run all client-side tests (Laravel Dusk)
composer client-tests-filter   # Run filtered client-side tests (append filter name)
```

**Direct PHPUnit:**
```bash
./vendor/bin/phpunit                       # All tests
./vendor/bin/phpunit --testsuite Feature   # Feature tests
./vendor/bin/phpunit --testsuite Unit      # Unit tests
```

**Code Quality:**
```bash
./vendor/bin/pint  # Laravel Pint (PHP code formatter)
```

## Architecture

### Directory Structure

**Application Layer (app/):**
- `Actions/` - Single purpose, reusable actions organized by domain (Organization/, Account/, etc.)
- `Controllers/` - HTTP controllers organized by domain (Organization/, Account/, etc.)
- `Models/` - Eloquent models with concerns for organization
- `Concerns/` - Model traits organized by model name (Organization/, User/, Contact/, etc.)
- `Requests/` - Form request validation classes organized by domain
- `.agents/standards/rules/` - Custom validation rules
- `Jobs/` - Queueable job classes
- `Notifications/` - Notification classes for email/SMS
- `Services/` - External service integrations
- `Types/` - Base types (Controller, Model, etc.)
- `Support/` - Helper utilities
- `Enumerations/` - Backed enums
- `Casts/` - Custom Eloquent casts
- `Middleware/` - HTTP middleware
- `Mixins/` - Macro extensions for Laravel classes
- `Commands/` - Artisan console commands

**Routes (routes/):**
- Domain-based route files: `Account.php`, `Authentication.php`, `Organization.php`, etc.

**Frontend (resources/):**
- `views/` - Blade templates
  - `components/` - Reusable Blade components
  - `pages/` - Page views organized by domain
  - `partials/` - Partial templates
  - `icons/` - SVG icon components
  - `mail/` - Email templates
- `styles/` - CSS files
- `scripts/` - JavaScript files

**Testing (tests/):**
- `Unit/`, `Feature/`, `Browser/`

#### Key Patterns

**Models:**
- Use concerns (traits) to organize functionality by domain
- Located in `app/Concerns/{ModelName}/`
- Concerns include: Storage, Paths, Collections, Integrations, Relationships

**Frontend:**
- Alpine.js for interactivity within Blade components
- Hotwired Turbo for navigation
- JavaScript kept within Alpine components, not extracted to separate files
- Use `Browser` helper for Turbo navigation: `Browser.redirect()`, `Browser.request()`, `Browser.share()`
- Explore existing `pages`, `partials` and `components` to see how they are used. Always use existing components and patterns.

**Enums:**
- Use `enum_value($enum)` helper for enum values

## Technology

- PHP 8.5+
- Laravel 13.0
- PHPUnit 13.0
- Tailwind CSS v4
- AlpineJS v3
- TurboJS
- Stripe (payments)
- Cloudflare R2 (S3-style file storage via Flysystem)

## Guidance

- Never run Browser / Dusk tests unless specifically instructed
- Do not create helper methods in test files, each test should encapsulate all required logic
- Prefer model factories for test data and payloads instead of hard-coded values when the exact value is not the behavior under test. For example, use `Library::factory()->make()` for update payloads so tests exercise realistic, randomized data.
