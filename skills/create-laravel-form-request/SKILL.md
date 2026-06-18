---
name: create-laravel-form-request
description: This skill creates a Laravel form request validation class in accordance with the patterns used in the codebase.
---

You are responsible for creating form request validation classes that match the exact patterns used in the codebase.

## Rules

- **Extend `App\Types\FormRequest`** - Never use `Illuminate\Foundation\Http\FormRequest`
- **Always start with `bail`** - First validation rule in every field
- **Organization scoping** - Use `Rule::exists()` and `Rule::unique()` with organization_id where clause
- **Two rule formats** - Pipe format for simple rules, array format for complex rules or alignment needs
- **Authorization patterns** - Use `$this->abort()` for custom messages, `$this->organization()->owns()` for ownership checks
- **UpdateRequest pattern** - Use `ignoreModel()` on unique rules to exclude current record

## File Organization

Form requests follow this structure:
```
app/Requests/
├── Account/
│   ├── Avatar/
│   │   └── UpdateRequest.php
│   └── Profile/
│       └── UpdateRequest.php
├── Api/
│   ├── Contact/
│   │   ├── StoreRequest.php
│   │   └── UpdateRequest.php
│   └── Listing/
│       ├── StoreRequest.php
│       └── UpdateRequest.php
└── Organizations/
    └── Membership/
        ├── StoreRequest.php
        └── UpdateRequest.php
```

## Implementation

1. **Determine the operation** (store, update, delete, etc.)
2. **Determine domain and resource** (Operations/Contact, Organizations/Membership, etc.)
3. **Create request file** in `app/Requests/{Domain}/{Resource}/{Action}Request.php`
4. **Start with exact structure** from examples
5. **Define `authorize()` method**
   - Simple: return `true`
   - Ownership: return `$this->organization()->owns($this->route('model'))`
   - Credits check: return ternary with `$this->abort()`
   - Complex: multi-line with conditional `$this->abort()` calls
6. **Define `rules()` method**
   - Define Rule variables first (before return statement)
   - Add `ignoreModel()` for UpdateRequest
   - Return rules array with proper format
   - Add custom fields spread at end if applicable
7. **Never add `messages()` method** - not used in this codebase

## Output Format

After completing your work:
1. Show the form request file created
2. Note the authorization pattern used
3. List any custom rules that need to be created (if they don't exist)
4. Note which controller method(s) should use this request
5. Confirm UpdateRequest has `ignoreModel()` on unique rules

## Additional resources

- For examples, see [examples.md](references/examples.md)
