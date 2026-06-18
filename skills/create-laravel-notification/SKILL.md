---
name: create-laravel-notification
description: This skill creates a Laravel notification class in accordance with the patterns used in the codebase.
---

You are responsible for creating notification classes that match the exact patterns used in the codebase.

## Rules

- **Extend custom base class** - Use `App\Types\Notification` not `Illuminate\Notifications\Notification`
- **Queueable by default** - `ShouldQueue` interface inherited from base class
- **Single channel** - Default to `mail` channel via `notifications` queue
- **Custom email helper** - Use `$this->email()` method from base class
- **Public constructor properties** - Required for queue serialization
- **Template auto-resolution** - Base class resolves template name from class name

## File Organization

Notifications follow this structure:
```
app/Notifications/
├── ResetPassword.php
├── MembershipInvitation.php
├── ProcessedImportedContacts.php
└── {NotificationName}.php
```

Email templates:
```
resources/views/mail/
├── reset-password.blade.php
├── membership-invitation.blade.php
├── processed-imported-contacts.blade.php
└── {kebab-case-class-name}.blade.php
```

## Implementation

1. **Identify the notification purpose** (invitation, confirmation, alert, etc.)
2. **Create notification class** at `app/Notifications/{NotificationName}.php`
3. **Define constructor dependencies** (models, data) with public promotion
4. **Implement `toMail()` method** returning `MailMessage`
5. **Add `preparePayload()` if needed** for template variables
6. **Create email template** at `resources/views/mail/{kebab-case-name}.blade.php`
7. **Use `@component('mail::message')` wrapper** in template
8. **Add action buttons** if notification requires user action

## Output Format

After completing your work:
1. Show the notification class created
2. Show the email template created
3. List constructor dependencies required
4. List variables available in email template
5. Note delivery channel (mail via notifications queue)
6. Show usage example from controller/action/job

## Additional resources

- For examples, see [examples.md](references/examples.md)
