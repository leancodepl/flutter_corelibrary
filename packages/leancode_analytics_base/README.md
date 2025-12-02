# leancode_analytics_base

Base package providing core analytics abstractions for Flutter apps.

## Features

- Core analytics interface (`LeanAnalytics`)
- Base analytics events (`AnalyticsEvent`, `TapAnalyticsEvent`, `LoginAnalyticsEvent`)
- Route interface for analytics tracking (`LeanAnalyticsRoute`)

## Usage

This package provides the foundation for analytics implementations. Use specific implementation packages:
- `leancode_analytics_firebase` for Firebase Analytics
- `leancode_analytics_posthog` for PostHog Analytics

