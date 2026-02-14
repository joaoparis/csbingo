# Landing Page Implementation Plan

This document describes the implementation plan for the CS BINGO landing page and lists open questions and tasks.

## Goal

- Create a three-section landing page matching the provided wiremock:
  1. Full-screen hero with game name, tagline and large `Play` button. The hero occupies the full viewport. When the user scrolls the title shrinks into the app bar.
 2. Full-screen "How to play" section containing explanatory text and a placeholder image anchored to the bottom-left of the section (no bottom padding).
 3. Info section with an image on the left and text on the right (height determined by content). Footer at the bottom of the page.

## Files

- Current landing page: [lib/pages/landing_page.dart](lib/pages/landing_page.dart)
- New plan file: `docs/landing_page_plan.md`

## High-level tasks

1. Implement `LandingPage` widget (scrollable single route).
2. Implement hero section:
   - Centered large title and tagline.
   - Large `Play` button which navigates to the game route.
   - Section fills viewport height.
   - Title shrinks smoothly into the app bar on scroll.
3. Implement "How to play" section:
   - Fill viewport height.
   - Place a placeholder image anchored to bottom-left with zero bottom padding.
   - Text flows on the right side.
4. Implement info section with left image / right text and footer.
5. Add responsive tweaks (mobile vs desktop): font scaling, spacing.
6. Hook up navigation for the `Play` button to the existing game page / route.
7. Test on multiple screen sizes and fix visual regressions.

## Implementation notes and suggestions

- Use a `CustomScrollView` with a `SliverAppBar` to achieve the shrinking title effect. Configure the `SliverAppBar` with `pinned: true`, `expandedHeight` equal to viewport height for the hero, and supply a `FlexibleSpaceBar` for the large title.
- The hero content (title, tagline, play button) should be placed inside the `FlexibleSpaceBar`'s background or `centerTitle` area so it scales with the app bar.
- Use `SliverToBoxAdapter` for the two following sections. For the full-height sections, wrap content with `SizedBox(height: MediaQuery.of(context).size.height)` or a `ConstrainedBox`.
- Use `Stack` in the "How to play" section to place the image anchored to the bottom-left with `Positioned(bottom: 0, left: 0)` and allow the text to flow above or beside it using padding or a `Row` with flexible children.
- Prefer `Image.asset('assets/images/...')` placeholders where possible. If no suitable assets exist, use a network placeholder such as `https://via.placeholder.com/600x400` for development.
- Keep styles (fonts, colors, sizes) in `lib/constants/` or reuse existing theme values.

## Accessibility

- Ensure the `Play` button has semantic label and sufficient contrast.
- Set sensible `tapTargetSize` and padding for touch targets.

## Open questions / decisions needed

1. Which route or widget should the `Play` button navigate to? (e.g., `/game`, `GamePage`, `GameScreen` or the route defined in `lib/config/router_config.dart`). Answer; navigate to /game
2. Which placeholder images from `assets/` should I use for the two image slots? Provide filenames or confirm using network placeholders. Answer: any that says "Placeholder"
3. Confirm if we should reuse the app font and primary color from the existing theme, or apply a custom style for the landing page title. Answer: use the existing theme
4. Any animation preferences for the `Play` button (ripple only, scale on press, or a subtle entrance animation)? Answer: simple

## Checklist (progress tracking)

- [ ] Create `LandingPage` widget and route
- [ ] Hero section implemented with shrinking title
- [ ] `Play` button wired to navigation
- [ ] How-to-play section implemented with bottom-left anchored image
- [ ] Info section + footer
- [ ] Responsive and accessibility checks

## Next steps (if you want me to proceed)

1. Confirm the answers to the open questions above.
2. I'll implement the landing page in `lib/pages/landing_page.dart` (or add a new file if you prefer) and run the app locally to iterate.

---

If you'd like I can now implement the UI scaffolding and wire the `Play` button to a default route `/game` while we decide final route names and images.

NOTE: first section should not show a navbar, then the hero animation becomes the navbar.