import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class SuperContentCacheManager extends CacheManager {
  static String _key = 'superContentCache';

  static Duration cacheDuration = const Duration(days: 30);
  static int maxNrOfCacheObjects = 200;

  static SuperContentCacheManager? _instance;
  static SharedPreferences? _prefs;
  static Completer<void>? _prefsCompleter;

  // Singleton instance
  factory SuperContentCacheManager() {
    _instance ??= SuperContentCacheManager._();
    return _instance!;
  }

  SuperContentCacheManager._()
      : super(
          Config(
            _key,
            stalePeriod: cacheDuration,
            maxNrOfCacheObjects: maxNrOfCacheObjects,
          ),
        ) {
    if (_prefs == null) {
      _prefsCompleter = Completer<void>();
      _initPrefs();
    }
  }

  static SuperContentCacheManager get instance => SuperContentCacheManager();

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefsCompleter!.isCompleted) {
      _prefsCompleter!.complete();
    }
  }

  Future<void> _ensurePrefsReady() async {
    if (_prefs == null) {
      await _prefsCompleter!.future;
    }
  }

  /// Configuration method to set global cache duration, max objects, and cache key
  static void configure({
    String? cacheKey,
    Duration? globalCacheDuration,
    int? maxObjects,
  }) {
    if (cacheKey != null) {
      _key = cacheKey;
    }
    if (globalCacheDuration != null) {
      cacheDuration = globalCacheDuration;
    }
    if (maxObjects != null) {
      maxNrOfCacheObjects = maxObjects;
    }
    // Reinitialize the instance with new config
    _instance = SuperContentCacheManager._();
  }

  /// Store content against a key with optional tag and updatedOn date
  Future<void> storeContent({
    required String key,
    required Map<String, dynamic> content,
    required DateTime updatedOn,
    String? tag,
  }) async {
    await _ensurePrefsReady();

    if (kIsWeb) {
      // On web, store content in SharedPreferences
      final jsonString = jsonEncode(content);
      await _prefs!.setString('content_$key', jsonString);
    } else {
      // On mobile, use flutter_cache_manager
      final jsonString = jsonEncode(content);
      final bytes = utf8.encode(jsonString);

      await putFile(
        key,
        Uint8List.fromList(bytes),
        maxAge: cacheDuration,
      );
    }

    // Store updatedOn date
    await _prefs!.setString('updatedOn_$key', updatedOn.toIso8601String());

    // Store tag if provided
    if (tag != null) {
      await _setKeyTag(key, tag);
      await _addKeyToTagList(tag, key);
    } else {
      // Remove any existing tag association if tag is null
      await _removeKeyTag(key);
    }
  }

  /// Retrieve content by key
  Future<Map<String, dynamic>?> getContent(String key) async {
    await _ensurePrefsReady();

    if (kIsWeb) {
      // On web, retrieve content from SharedPreferences
      final jsonString = _prefs!.getString('content_$key');
      if (jsonString == null) {
        return null;
      }
      final content = jsonDecode(jsonString) as Map<String, dynamic>;
      return content;
    } else {
      // On mobile, use flutter_cache_manager
      final fileInfo = await getFileFromCache(key);
      if (fileInfo == null) {
        return null;
      }
      final bytes = await fileInfo.file.readAsBytes();
      final jsonString = utf8.decode(bytes);
      final content = jsonDecode(jsonString) as Map<String, dynamic>;
      return content;
    }
  }

  /// Get updatedOn date for a key
  Future<DateTime?> getUpdatedOn(String key) async {
    await _ensurePrefsReady();
    final dateString = _prefs!.getString('updatedOn_$key');
    if (dateString == null) {
      return null;
    }
    return DateTime.parse(dateString);
  }

  /// Clear cache for a specific key
  Future<void> clearKey(String key) async {
    await _ensurePrefsReady();

    if (kIsWeb) {
      // Remove content from SharedPreferences
      await _prefs!.remove('content_$key');
    } else {
      // On mobile, remove file from cache
      await removeFile(key);
    }

    // Remove updatedOn and tag data
    await _prefs!.remove('updatedOn_$key');
    await _removeKeyFromTagList(key);
    await _removeKeyTag(key);
  }

  /// Clear cache for a tag
  Future<void> clearTag(String tag) async {
    await _ensurePrefsReady();
    final keys = _prefs!.getStringList('tag_list_$tag') ?? [];
    for (final key in keys) {
      if (kIsWeb) {
        await _prefs!.remove('content_$key');
      } else {
        await removeFile(key);
      }
      await _prefs!.remove('updatedOn_$key');
      await _prefs!.remove('key_tag_$key');
    }
    await _prefs!.remove('tag_list_$tag');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _ensurePrefsReady();

    if (kIsWeb) {
      // Remove all content_* keys from SharedPreferences
      final contentKeys =
          _prefs!.getKeys().where((key) => key.startsWith('content_'));
      for (final key in contentKeys) {
        await _prefs!.remove(key);
      }
    } else {
      // On mobile, empty the cache
      await emptyCache();
    }

    // Remove updatedOn and tag data
    final keysToRemove = _prefs!.getKeys().where(
          (key) =>
              key.startsWith('updatedOn_') ||
              key.startsWith('key_tag_') ||
              key.startsWith('tag_list_'),
        );
    for (final key in keysToRemove) {
      await _prefs!.remove(key);
    }
  }

  /// Associate a key with a tag
  Future<void> _setKeyTag(String key, String tag) async {
    await _prefs!.setString('key_tag_$key', tag);
  }

  /// Get the tag associated with a key
  Future<String?> _getKeyTag(String key) async {
    return _prefs!.getString('key_tag_$key');
  }

  /// Remove the tag associated with a key
  Future<void> _removeKeyTag(String key) async {
    await _prefs!.remove('key_tag_$key');
  }

  /// Add a key to the tag's list of keys
  Future<void> _addKeyToTagList(String tag, String key) async {
    final tagListKey = 'tag_list_$tag';
    final keys = _prefs!.getStringList(tagListKey) ?? [];
    if (!keys.contains(key)) {
      keys.add(key);
      await _prefs!.setStringList(tagListKey, keys);
    }
  }

  /// Remove a key from its tag's list of keys
  Future<void> _removeKeyFromTagList(String key) async {
    final tag = await _getKeyTag(key);
    if (tag != null) {
      final tagListKey = 'tag_list_$tag';
      final keys = _prefs!.getStringList(tagListKey) ?? [];
      if (keys.contains(key)) {
        keys.remove(key);
        if (keys.isEmpty) {
          await _prefs!.remove(tagListKey);
        } else {
          await _prefs!.setStringList(tagListKey, keys);
        }
      }
    }
  }
}
