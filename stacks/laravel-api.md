# Laravel API

This describes the rules, development commands, architecture, technology, and guidance for a Laravel API project.

This project type involves a single repository with Laravel handling all server-side duties. The corresponding client-side element is a separate repository.

## Rules

Reference the relevant rules file in `.agents/standards/rules/` whenever working on matching files:

- [.agents/standards/rules/general.md](.agents/standards/rules/general.md) — General code formatting and style patterns. Always reference for any code change.
- [.agents/standards/rules/php.md](.agents/standards/rules/php.md) — PHP style rules. Reference when editing files matching `{app,bootstrap,config,database,routes,tests}/**/*.php`.
- [.agents/standards/rules/laravel.md](.agents/standards/rules/laravel.md) — Laravel-specific patterns. Reference when editing files matching `{app,bootstrap,config,database,routes,tests}/**/*.php`.

## Commands

**Testing:**
```bash
composer tests          # Run all side tests (PHPUnit)
composer tests-filter   # Run filtered side tests (append filter name)
```

**Direct PHPUnit:**
```bash
./vendor/bin/phpunit   # All tests
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
- `.agents/standards/Rules/` - Custom validation rules
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

#### Key Patterns

**Models:**
- Use concerns (traits) to organize functionality by domain
- Located in `app/Concerns/{ModelName}/`
- Concerns include: Storage, Paths, Collections, Integrations, Relationships

**Enums:**
- Use `enum_value($enum)` helper for enum values

## Technology

- PHP 8.5+
- Laravel 13.0
- PHPUnit 13.0
- Stripe (payments)
- Cloudflare R2 (S3-style file storage via Flysystem)

## Guidance

- Do not create helper methods in test files, each test should encapsulate all required logic
- Prefer model factories for test data and payloads instead of hard-coded values when the exact value is not the behavior under test. For example, use `Library::factory()->make()` for update payloads so tests exercise realistic, randomized data.
