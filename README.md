# letsblaze

Blazingly fast, highly opinionated flyweight Hugo theme

## CSS Philosophy

letsblaze uses CSS only where it is essential for end-user usability. Every rule
in the theme has an explicit justification. The complete CSS registry is maintained
in the project's review plan document.

Rules included and why:

- **Skip link visibility** — hidden off-screen, revealed on keyboard focus only
- **Body max-width (`65ch`)** — prevents unreadable line lengths on wide viewports
- **Body line-height (`1.6`)** — browser default is too tight for comfortable reading
- **Image max-width** — prevents overflow on small screens
- **Table overflow** — prevents wide tables breaking page layout
- **`[aria-current="page"]`** — visual indication of the active navigation item
- **Dark mode (`prefers-color-scheme`)** — respects OS-level user preference

No external stylesheet. No CDN resources. No JavaScript. All CSS is inline in
`baseof.html` and can be audited in one place.

### Dark Mode

Dark mode follows the system preference via `prefers-color-scheme: dark`. A manual
light/dark toggle is intentionally not implemented — it requires JavaScript, which
conflicts with the theme's no-JS design principle. Users who want dark mode should
set it at the OS or browser level.
