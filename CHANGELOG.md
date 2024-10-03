# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2024-10-04

### Added

- **Initial Release**: Launch of the `super_content_cache` package.
- **Content Caching**: Ability to store and retrieve `Map<String, dynamic>` content against unique keys.
- **Metadata Storage**: Store `updatedOn` dates associated with each key.
- **Tagging System**: Assign a single tag to a key for grouping and bulk operations.
- **Cache Invalidation**: Methods to clear cache by key, tag, or entirely.
- **Configuration Options**: Configure global cache duration, maximum number of cache objects, and custom cache key.
- **Platform Support**: Full support for Android, iOS, and Web platforms with platform-specific optimizations.
  - **Web Platform**: Content stored using `SharedPreferences` (backed by `localStorage`).
  - **Mobile Platforms**: Content stored using `flutter_cache_manager`.
- **Consistent API**: Uniform interface across platforms, abstracting platform-specific differences.
- **Example App**: Included an example application demonstrating how to use the package.