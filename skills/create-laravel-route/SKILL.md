---
name: create-laravel-route
description: This skill creates or modifies Laravel routes in domain-specific route files in accordance with the patterns used in the codebase.
---

You are responsible for creating or modifying routes in domain-specific route files.

## Rules

- **Domain organization** - Routes organized by domain in separate files
- **Single-line definitions** - All routes on one line with chained `->name()`
- **Index naming** - Index routes use `domain.resources` (no `.index` suffix)
- **RESTful ordering** - Follow standard order: index, create, store, edit, update, delete
- **Delete not destroy** - Use `.delete` action name, not `.destroy`

## Domain Route Files

Routes are organized by domain in `routes/`:
- `Account.php` - User account management
- `Authentication.php` - Login, register, password reset
- `Api.php` - Core operations
- `Organization.php` - Organization management, billing, subscriptions
- `Webhooks.php` - Webhook handlers

## File Organization

Every route file follows this structure:
```
Line 1: <?php
Line 2: Empty
Line 3: declare(strict_types=1);
Line 4: Empty
Line 5+: Imports (Route facade, then controllers ordered by length)
Empty line
PHPDoc: /** * Routes. * */
Routes (single line, chained ->name())
```

## Route Naming Conventions

**Pattern:** `{domain}.{resource}.{action}`

- Domain matches the route file name (lowercase)
- Resource is plural for collections, singular for single items
- Action is the controller method name
- **Special case:** Index routes omit the `.index` suffix

**Examples:**
- `api.contacts` - Index (no `.index`)
- `api.contacts.store` - Store new contact
- `api.contacts.update` - Update contact
- `api.contacts.delete` - Delete contact (not `.destroy`)

## RESTful Action Order

When adding multiple routes for a resource, follow this order:
1. Index (GET `/resources`)
3. Store (POST `/resources`)
5. Update (PATCH `/resources/{resource}`)
6. Delete (DELETE `/resources/{resource}`)
7. Custom actions (alphabetically)

## Implementation

1. **Identify the correct domain file** (Api, Organization, Account, etc.)
2. **Read the target file** to understand current structure
3. **Identify where to add routes** (group with related resources)
4. **Import the controller** at the top (maintain alphabetical by length order)
5. **Add routes** matching existing format:
   - Single line definitions
   - Chained `->name()` method
   - Correct parameter names (`{organization}`, `{contact}`, etc.)
   - Proper HTTP verbs (GET, POST, PATCH, DELETE)
6. **Follow RESTful order** for standard actions
7. **Verify route names** follow the pattern (no `.index` for index routes)

## Output Format

After completing your work:
1. **File modified:** `routes/{Domain}.php`
2. **Routes added:**
   - `HTTP_METHOD /path` → `route.name` (Controller@method)
3. **Controller imports added:** List any new controllers imported
4. **Verification command:** `php artisan route:list --path={domain}`

## Additional resources

- For examples, see [examples.md](references/examples.md)
