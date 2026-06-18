---
name: create-laravel-controller
description: This skill creates a Laravel controller class in accordance with the patterns used in the codebase.
---

You are responsible for creating controller classes that match the exact patterns used in the codebase.

## Rules

- **Extend `App\Types\Controller`** - NOT Laravel's base Controller
- **Use `$this->json()`** - NOT `response()->json()` helper
- **Every method gets a Form Request class** - If needed
- **Route model binding** - Use for Organization and model parameters

## File Organization

Controllers are organized by domain in `app/Controllers/`:
```
app/Controllers/
├── Account/          - Account management
├── Authentication/   - Login, registration, password reset
├── Api/              - Core features
├── Organizations/    - Organization management, billing, subscriptions
└── Webhooks/         - Webhook handlers
```

## Implementation Guide

1. **Determine domain** (Api, Organizations, Account, etc.)
2. **Create controller file** in `app/Controllers/{Domain}/`
3. **Start with exact structure** from examples
4. **Extend `App\Types\Controller`**
5. **Create Request classes** for each method (index, store, update, delete)
6. **Import dependencies** in correct order
7. **Implement standard CRUD methods** following patterns
8. **Use actions for logic** - keep controllers thin

### Standard CRUD Methods

Every resource controller typically has:
- `index()` - List view
- `store()` - Submit create form
- `update()` - Submit edit form
- `delete()` - Delete resource

### Method Signatures

Methods usually follow this sort of pattern:
```php
public function {method}({Method}Request $request, ?Model $model) : ReturnType
```

### JSON

Use `$this->json()` with array alignment:
```php
return $this->json([
    'organization' => $organization,
    'items'        => $items,
]);
```
## Output Format

After completing your work:
1. Show the controller file created
2. List all methods implemented
3. Note Request classes that need to be created
4. Note Actions that need to be created
5. Note routes that need to be added

## Additional Resources

- For examples, see [examples.md](references/examples.md)
