# Create Test Examples

## File Shape

Every test file starts with a dependencies docblock and imports from `../../support/test.js`.

```js
/**
 * Dependencies.
 *
 */
import { button, expect, fake, route, start, test } from '../../support/test.js';
```

Use one `Test.` docblock per `test(...)` call.

```js
/**
 * Test.
 *
 */
test('a user can change their password', async({ createUser, page }) =>
{
    const user = createUser();

    await fake(page, 'PATCH', route('account.password'));

    await start(page, user);
});
```

## Imports

Import only what the test needs. Pull shared helpers from `../../support/test.js`.

```js
import { button, expect, fake, faker, route, start, test } from '../../support/test.js';
```

Use direct Node imports only for platform features that support does not export.

```js
import { fileURLToPath } from 'node:url';
```

## Sections

Use this order inside every test:

1. `Setup.`: factories, tokens, files, constants, payload-independent data.
2. `Interceptions.`: `fake(...)` calls only.
3. `Workflow.`: `start(...)`, navigation, assertions, form input, request waits.

`start(...)` must be the first workflow call, before `page.goto(...)`.

```js
await start(page, user);

await page.goto(route('account.profile'));
```

## Network Fakes

Use the method-required fake signature:

```js
await fake(page, 'PATCH', route('account.password'));
await fake(page, 'POST', route('authentication.web-client.login'), { data : user });
await fake(page, 'POST', file.url, null, 204);
```

Rules:

- Always pass the HTTP method as the second argument.
- Always pass `route(...)` for app routes.
- Omit the body when the frontend only needs a successful response.
- Keep meaningful JSON bodies when the frontend reads `response.json().data`.
- `fake()` already lets document navigation continue, so do not hand-roll `page.route(...)` for same-path form submissions.

## Request Assertions

Use the custom `page.waitFor(...)` object API:

```js
await page.waitFor({
    method  : 'POST',
    url     : route('authentication.web-client.login'),
    trigger : async() => await button(page, 'login').click(),
});
```

Add `body` when asserting submitted JSON.

Single-key body stays inline:

```js
await page.waitFor({
    method   : 'DELETE',
    url      : route('account.close'),
    body     : { password : 'Q5p@4xFvw9w#' },
    trigger  : async() => await button(page, 'delete').click(),
});
```

Multi-key body uses `payload`:

```js
const payload = {
    new_password              : 'R5p@4xFvw9w#',
    new_password_confirmation : 'R5p@4xFvw9w#',
    old_password              : 'Q5p@4xFvw9w#',
};

await page.waitFor({
    method   : 'PATCH',
    url      : route('account.password'),
    body     : payload,
    trigger  : async() => await button(page, 'change').click(),
});
```

When the request object itself is needed, keep the return value:

```js
const request = await page.waitFor({
    method  : 'DELETE',
    url     : route('account.sessions.delete', { token : token.id }),
    trigger : async() => await menu(page, `session_${token.id}`, 'delete').link.click(),
});

expect(request.url()).toContain(`/account/sessions/${token.id}`);
```

## Factories

Use factory fixtures from the test context (ensure overrides match the key order defined in the factory):

```js
test('a user can join an organization', async({ createInvitation, createUser, page }) =>
{
    const user = createUser({
        organization_id : null,
        role            : null,
        email           : 'associate@example.com',
    });
});
```

Use `faker` from support when random values are needed:

```js
import { faker, test } from '../../support/test.js';

const token = faker.string.alphanumeric(64);
```

## Selectors

Prefer helpers:

```js
await button(page, 'save').click();
await menu(page, `session_${token.id}`, 'delete').trigger.click();
```

Use direct locators for field IDs and precise Playwright roles:

```js
await page.locator('#email').fill(user.email);
```

Avoid broad text locators when they can match page titles, status regions, or headings at the same time.

## Verification

After edits:

```bash
npm run tests -- --list
```

Run a targeted test when practical:

```bash
npm run tests -- testing/tests/account/password.js --project=chromium
```