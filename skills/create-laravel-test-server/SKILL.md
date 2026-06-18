---
name: create-laravel-test-server
description: This skill creates Laravel server-side tests in accordance with the patterns used in the codebase.
---

You are responsible for creating tests that match the exact patterns used in the codebase.

## Rules

- **Use `#[Test]` attribute** - Never use `test_` method prefix
- **Method names describe behavior** - `a_user_can_perform_action()` or `it_knows_its_state()`
- **Use `assertMatch()`** - Never `assertEquals()` or `assertSame()`
- **Put the model/current value first in `assertMatch()`** - For model assertions, pass the model attribute as the first argument and the payload/expected value as the second
- **Test authorization boundaries** - Multi-tenancy (resource belongs to organization)
- **Use `withToken()` for bearer tokens** - Never add `Authorization: Bearer ...` headers manually
- **Name request payloads `$payload`** - Build request payload arrays before making the request
- **Use `URL::route()`** - Generate route URLs with `URL::route('name', [...])`

## File Organization

Tests follow this structure:
```
tests/
├── Controllers/
    └── Api/
        ├── ContactTest.php
        └── ListingTest.php
└── Jobs/
    └── DeleteOrganizationJobTest.php
```

## Implementation
1. **Create file** in `tests/{ResourceType}/{Domain?}/{Resource}Test.php`
2. **Namespace** follows pattern: `Tests\Controllers\{Domain}` or `Tests\{ResourceType}`
3. **Extend** `App\Types\TestCase`
4. **Use `#[Test]` attribute** on each test method
5. **Use `assertMatch()`** for comparing variables, model attributes, array key/values, with model/current values first
6. **Test authorization** - verify resources belong to organization

## Naming

- Name controller test files after the route/resource behavior, not the implementation class. For example, use `LoginTest.php`, `LogoutTest.php`, or `ProviderTest.php` instead of `LoginControllerTest.php`.
- Keep namespaces aligned with the folder path, e.g. `tests/Controllers/Authentication/ActorTest.php` uses `Tests\Controllers\Authentication`.

## Feature Test Method Patterns
- `a_user_can_view_the_page()`
- `a_user_can_create_a_resource()`
- `a_user_can_update_a_resource()`
- `a_user_can_delete_a_resource()`
- `a_user_cannot_access_when_resource_does_not_belong_to_organization()`
- `a_user_cannot_perform_action_when_validation_fails()`

Or for more unit-style tests e.g. models:
- `it_knows_its_avatar_path()`
- `it_knows_if_its_enabled()`
- `it_knows_if_it_is_a_member_of_an_organization()`

## Common Assertions
- `->assertSuccessful()` - 2xx status codes
- `->assertCreated()` - 201 status codes
- `->assertNoContent()` - 204 status codes
- `->assertForbidden()` - authorization failures
- `->assertInvalid(['field' => 'message'])` - validation errors
- `->assertRedirectToRoute('route.name')` - redirect assertions
- `->assertSessionHasNotification('message')` - flash notifications
- `$this->assertMatch($model->attribute, $expected)` - variables, arrays and model attributes, with model/current values first
- `$this->assertTrue($condition)` - boolean checks

## HTTP Request Patterns

- Use `URL::route()` for route URLs:
  ```php
  $this->getJson(URL::route('authentication.web-client.actor'))
      ->assertSuccessful();
  ```
- Define request data as `$payload` before the request:
  ```php
  $payload = [
      'email'    => $user->email,
      'password' => 'Q5p@4xFvw9w#',
      'remember' => false,
  ];

  $this->postJson(URL::route('authentication.web-client.login'), $payload)
      ->assertSuccessful();
  ```
- Use `withToken()` for bearer token authentication:
  ```php
  $token = $organization->createToken('Testing', ['*'])->plainTextToken;

  $this->withToken($token)
      ->getJson(URL::route('authentication.web-client.actor'))
      ->assertForbidden();
  ```

## Output Format

After completing your work:
1. Show the test file(s) created
2. List test methods included
3. Note any HTTP mocking required
4. Note any queue/notification fakes needed

## Guidance

- When using assertions, always reference the model instance or the database query used to fetch the model (`$user->fresh()->xyz` or `User::first()->xyz`) as the first parameter, and the expectation as the second parameter e.g. `$this->assertMatch($user->fresh()->name, 'John Doe')`
- Do not create separate helper methods, all test logic should live within each test
- Do not use `assertDatabaseHas()`, instead always use `assertDatabaseCount()` and then individual assertions on the model using `assertTrue()` and `assertMatch()`
- After `assertDatabaseCount()`, prefer fetching the model directly in the assertion when that is the clearest expression of the behavior, e.g. `$this->assertMatch(User::first()->email, 'grace@example.com')`

## Additional Resources

- For examples, see [examples.md](references/examples.md)
