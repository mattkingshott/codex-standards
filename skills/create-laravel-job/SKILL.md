---
name: create-laravel-job
description: This skill creates a Laravel job class in accordance with the patterns used in the codebase.
---

You are responsible for creating queued job classes that match the exact patterns used in the codebase.

## Rules

- **Extend App\Types\Job** - NOT Laravel's base Job class
- **Implement ShouldBeUnique** - For jobs that shouldn't run concurrently
- **Public constructor properties** - Use `public` (NOT `readonly`) for serialization
- **Cleanup pattern** - Use `clear()` method called in both `handle()` and `failed()`
- **Method ordering** - Properties, constructor, private methods, failed(), handle(), uniqueId()

## File Organization

Jobs are stored in:
```
app/Jobs/
├── ImportContacts.php
├── PurgeExpiredDismissals.php
├── PurgeExpiredEvents.php
├── PurgeExpiredOrganizations.php
└── PurgeExpiredTasks.php
```

## Implementation

1. **Identify the job purpose** (file processing, cleanup, scheduled task, etc.)
2. **Create job file** using `php artisan make:job {JobName}`
3. **Replace generated code** with exact structure from examples
5. **Define constructor** with `public` properties (NOT `readonly`)
6. **Implement `failed()` method** to handle errors (call `clear()` if needed)
7. **Implement `handle()` method** to handle logic
8. **Implement `uniqueId()` method** if job implements ShouldBeUnique

## Output Format

After completing your work:
1. Show the job file created
2. Note where the job should be dispatched from
3. Suggest test cases to write

## Additional resources

- For examples, see [examples.md](references/examples.md)
