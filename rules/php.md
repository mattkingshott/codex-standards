# Code Style Guide - PHP Rules

All generated PHP code must match these patterns to ensure consistency and maintainability.

---

## File Structure
- Line 3: Always include `declare(strict_types=1);`

## Type Declarations
- Always use explicit type hints and return types
- Always specify `void` return type when methods return nothing
- Use short nullable notation: `?string` not `string|null`

## Class Structure
- Constructor: Use `private` promoted properties (use `public` for queue-serialized classes like jobs)
- Traits: One trait per line

## Method Visibility
- Default to `private`
- Use `protected` only if subclasses need access
- Use `public` only if external access is required

## Docblocks
- Include docblocks for all PHP class methods
- Single sentence describing purpose
- No use of `@param` or `@return`, rely on types
- Only document "why" if non-obvious
- Example:
```php
/**
 * Produce the avatar for the given model.
 *
 */
private function renderAvatar(Model $model) : string
{
    // ...
}
```

## Important Guidance
- Do not wrap objects when instantiating e.g. `(new Process($event))->failed(null)`. PHP no longer requires this.

## Language Features
- String functions: Prefer multi-byte string functions over regular
- Closures: Prefer short closures / arrow functions
- Control structures: Always use `match` blocks over `switch` blocks
- Conditionals: Prefer ternary statements over `if-else` blocks
- Conditionals: Prefer `match` blocks over lengthy `if-elseif-else` blocks

## Control Flow Patterns
- **Happy path last**: Handle error conditions first, success case last
- **Avoid else**: Use early returns instead of nested conditions
- **Separate conditions**: Prefer multiple if statements over compound conditions
- **Always use curly brackets**: Even for single statements
- **Ternary operators**: Each part on own line unless short enough to read on one
