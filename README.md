# Super Content Cache

A powerful Flutter package for caching content with tagging and metadata capabilities, utilizing `flutter_cache_manager` and `shared_preferences` under the hood.

## Features

- **Content Caching**: Store and retrieve `Map<String, dynamic>` content against unique keys.
- **Metadata Storage**: Associate an `updatedOn` date with each cached content item.
- **Tagging System**: Assign a single tag to content keys for grouped cache management.
- **Cache Invalidation**: Clear cache by key, tag, or entirely.
- **Configuration**: Customize global cache duration, maximum number of cache objects, and cache key.
- **Platform Support**: Works seamlessly on Android, iOS, and Web platforms.
- **Consistent API**: Provides a uniform interface across platforms, abstracting away platform-specific differences.

## Getting Started

### Installation

Add `super_content_cache` to your project's `pubspec.yaml` file:

```yaml
dependencies:
  super_content_cache: 0.0.1
```

Then, run:

```bash
flutter pub get
```

### Import

```dart
import 'package:super_content_cache/super_content_cache.dart';
```

## Usage

### Configure the Cache (Optional)

Before using the cache, you can configure it with optional parameters:

- **`cacheKey`**: A unique identifier for your cache (useful if you have multiple caches or to avoid conflicts on the web).
- **`globalCacheDuration`**: The default duration to keep content in the cache (default is 30 days).
- **`maxObjects`**: The maximum number of objects to store in the cache (default is 200).

```dart
SuperContentCache.configure(
  cacheKey: 'superContentCache_myApp',
  globalCacheDuration: Duration(days: 7),
  maxObjects: 500,
);
```

### Store Content

Store a `Map<String, dynamic>` against a key, with an optional tag and `updatedOn` date:

```dart
await SuperContentCache.storeContent(
  key: 'user_profile_123',
  content: {
    'name': 'John Doe',
    'age': 30,
  },
  updatedOn: DateTime.now(),
  tag: 'user_profiles', // Optional
);
```

### Retrieve Content

Retrieve the content associated with a key:

```dart
final content = await SuperContentCache.getContent('user_profile_123');
print('Content: $content');
```

### Get `updatedOn` Date

Retrieve the `updatedOn` date for a key:

```dart
final updatedOn = await SuperContentCache.getUpdatedOn('user_profile_123');
print('Updated On: $updatedOn');
```

### Clear Cache for a Specific Key

Clear the cache for a specific key:

```dart
await SuperContentCache.clearKey('user_profile_123');
```

### Clear Cache for a Tag

Clear the cache for all keys associated with a tag:

```dart
await SuperContentCache.clearTag('user_profiles');
```

### Clear All Cache

Clear all cached content and associated metadata:

```dart
await SuperContentCache.clearAll();
```

## Example App

An example application demonstrating how to use the `super_content_cache` package is available in the `example` directory. It showcases:

- Configuring the cache with a custom `cacheKey`.
- Storing, updating, and retrieving content.
- Clearing cache by key, tag, and entirely.

You can find the complete example in the `example` directory of the package.

## Platform Considerations

### Web Platform

- **Storage Mechanism**: On the web, content is stored using `SharedPreferences`, which utilizes the browser's `localStorage`.
- **Data Persistence**: Data persists across page reloads and browser sessions.
- **Storage Limitations**: Browsers typically limit `localStorage` to around 5MB per origin. Be mindful of the data size when storing content.
- **Performance**: Suitable for small to medium-sized data. Not ideal for large binary files or extensive data storage.

### Mobile Platforms (Android & iOS)

- **Storage Mechanism**: Uses `flutter_cache_manager` to store content in the app's local file system.
- **Data Persistence**: Data persists as long as the app's cache is not cleared.
- **Capacity**: Capable of handling larger amounts of data compared to `SharedPreferences`.
- **Performance**: Efficient for storing and retrieving larger datasets.

## Limitations

- **Web Storage Quotas**: Be aware of storage limitations on the web and handle potential `QuotaExceededError` exceptions.
- **Data Size**: Ensure that the content size is appropriate for the storage mechanism on each platform.
- **Single Tag per Key**: Each key can have only one associated tag.

## Contributions

Contributions are welcome! If you find any issues or have suggestions for improvements, please submit issues and pull requests on [GitHub](https://github.com/ayush221b/super_content_cache).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.