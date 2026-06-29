# Code Style Guide - Laravel Rules

All generated Laravel code must match these patterns to ensure consistency and maintainability.

---

### General Rules

- Write all code as though it belongs in an official first-party Laravel package. Prioritize readability, elegance, expressive APIs, consistency, and pragmatic simplicity
- Prefer Laravel conventions over cleverness, favour composition over unnecessary abstraction, and write code that would feel natural alongside the Laravel framework itself

### Prohibited Patterns
- Never create multi-purpose actions (one action = one operation)
- Never use raw `Carbon::now()` or `now()` (use `Clock` facade)
- Never use `env()` or `Env::get()` helper outside of config files

### Required Patterns

**General Laravel**
- Use Facades over global helpers: `Config::get()` over `config()`
- Use `Illuminate\Support\Arr` for array functions when supported
- Use `Illuminate\Support\Str` for string functions when supported
- Use `Illuminate\Support\Collection` when performing multiple operations on arrayable variables
- Do not use Eloquent `with()` calls for relations as they are already automatically eager loaded by the application

**Time and Dates**
- Use `Clock::now()` for current time

**Forms and Requests**
- Use `Request::old()` for form repopulation

**Routing and URLs**
- Use `URL::route()` for route generation
- Use `Redirect::route()->withNotification()` for redirects with messages

**Session and Redirects**
- Use `Session::flash()` for temporary data

**Authorization**
- Use `$parent->owns($child)` for ownership checks

**(Blade / Alpine.js) Frontend Integration**
- Use `Browser::redirect()` for Turbo navigation