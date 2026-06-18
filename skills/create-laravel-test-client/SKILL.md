---
name: create-laravel-test-client
description: This skill creates Laravel Dusk browser tests in accordance with the patterns used in the codebase. Only use it when the frontend is Blade views.
---

You are responsible for creating browser (Dusk) tests that match the exact patterns used in the codebase.

## Rules

- **Use `#[Test]` attribute** - Never use `test_` method prefix
- **Method names describe behavior** - `a_user_can_perform_action()`
- **Use `assertMatch()`** - Never `assertEquals()` or `assertSame()`
- **Type browser parameter** - `function(Browser $browser) : void`
- **Arrange inside browse closure**

## File Organization

Tests follow this structure:
```
tests/Browser/
├── Operations/
│   ├── ContactTest.php
│   └── ListingTest.php
└── Organizations/
    └── MembershipTest.php
```

## Implementation
1. **Create file** in `tests/Browser/{Domain}/{Resource}Test.php`
2. **Namespace** follows pattern: `Tests\Browser\{Domain}`
3. **Extend** `Tests\Types\DuskTestCase`
4. **Import** `Tests\Support\Browser` and `Tests\Types\DuskTestCase`
5. **Use `#[Test]` attribute** on each test method
6. **Type browser parameter**: `function(Browser $browser) : void`
7. **Arrange data INSIDE** the browse closure
8. **HTTP mocking at START**: `$browser->fake(Http::class, [...])`
9. **Authenticate separately**: `$browser->start($user);` on its own line
10. **Use custom browser methods**: `->modal()`, `->push()`, `->tableItemMenu()`
11. **Use `assertMatch()`** for comparing variables, model attributes, array key/values

## Test Method Patterns
- `a_user_can_view_the_page()`
- `a_user_can_create_a_resource()`
- `a_user_can_update_a_resource()`
- `a_user_can_delete_a_resource()`

## Common Standard Assertions
- `$this->assertMatch($value, $expected)` - variables, arrays and model attributes
- `$this->assertTrue($condition)` - boolean checks

## Common Browser Assertions
- `->assertTitle("Page Title - {$organization->name}")` - page title
- `->assertRouteIs('route.name', ['param' => $value])` - current route
- `->assertSee('text')` - visible text
- `->assertInputValue('field_name', 'expected')` - input values
- `->assertSelected('field_name', $enumValue)` - select dropdown
- `->assertChecked('field_name')` - checkbox state

## Common Browser Interactions
- `->type('field_name', 'expected')` - Enter text into input
- `->select('field_name', $enumValue)` - select dropdown item
- `->check('field_name')` - Check a checkbox
- `->uncheck('field_name')` - un-check a checkbox
- `->push('field_name')` - Click a button

## Output Format

After completing your work:
1. Show the test file(s) created
2. List test methods included
3. Note any HTTP mocking required
4. Note any queue/notification fakes needed

## Additional Resources

- For examples, see [examples.md](references/examples.md)
