import 'super_content_cache_manager.dart';

class SuperContentCache {
  static final SuperContentCacheManager _manager =
      SuperContentCacheManager.instance;

  /// Configuration method
  static void configure({
    String? cacheKey,
    Duration? globalCacheDuration,
    int? maxObjects,
  }) {
    SuperContentCacheManager.configure(
      cacheKey: cacheKey,
      globalCacheDuration: globalCacheDuration,
      maxObjects: maxObjects,
    );
  }

  /// Store content
  static Future<void> storeContent({
    required String key,
    required Map<String, dynamic> content,
    required DateTime updatedOn,
    String? tag,
  }) async {
    await _manager.storeContent(
      key: key,
      content: content,
      updatedOn: updatedOn,
      tag: tag,
    );
  }

  /// Get content
  static Future<Map<String, dynamic>?> getContent(String key) async {
    return await _manager.getContent(key);
  }

  /// Get updatedOn date
  static Future<DateTime?> getUpdatedOn(String key) async {
    return await _manager.getUpdatedOn(key);
  }

  /// Clear cache for key
  static Future<void> clearKey(String key) async {
    await _manager.clearKey(key);
  }

  /// Clear cache for tag
  static Future<void> clearTag(String tag) async {
    await _manager.clearTag(tag);
  }

  /// Clear all cache
  static Future<void> clearAll() async {
    await _manager.clearAll();
  }
}
