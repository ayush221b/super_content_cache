import 'package:flutter/material.dart';
import 'package:super_content_cache/super_content_cache.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SuperContentCache.configure(
    cacheKey: 'superContentCache_myApp',
    globalCacheDuration: const Duration(days: 7),
    maxObjects: 500,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Configure the cache with a custom cacheKey
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Content Cache Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContentCacheDemo(),
    );
  }
}

class ContentCacheDemo extends StatefulWidget {
  const ContentCacheDemo({super.key});

  @override
  _ContentCacheDemoState createState() => _ContentCacheDemoState();
}

class _ContentCacheDemoState extends State<ContentCacheDemo> {
  final String key1 = 'user_profile_123';
  final String tag1 = 'user_profiles';

  final String key2 = 'app_settings';
  final String tag2 = 'settings';

  Map<String, dynamic>? content1;
  DateTime? updatedOn1;

  Map<String, dynamic>? content2;
  DateTime? updatedOn2;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    // Load content for key1
    final loadedContent1 = await SuperContentCache.getContent(key1);
    final loadedUpdatedOn1 = await SuperContentCache.getUpdatedOn(key1);

    // Load content for key2
    final loadedContent2 = await SuperContentCache.getContent(key2);
    final loadedUpdatedOn2 = await SuperContentCache.getUpdatedOn(key2);

    setState(() {
      content1 = loadedContent1;
      updatedOn1 = loadedUpdatedOn1;

      content2 = loadedContent2;
      updatedOn2 = loadedUpdatedOn2;
    });
  }

  Future<void> _storeContent1() async {
    await SuperContentCache.storeContent(
      key: key1,
      content: {
        'name': 'John Doe',
        'age': 30,
      },
      updatedOn: DateTime.now(),
      tag: tag1,
    );
    _loadContent();
  }

  Future<void> _updateContent1() async {
    await SuperContentCache.storeContent(
      key: key1,
      content: {
        'name': 'John Doe',
        'age': 31, // Updated age
      },
      updatedOn: DateTime.now(),
      tag: tag1,
    );
    _loadContent();
  }

  Future<void> _storeContent2() async {
    await SuperContentCache.storeContent(
      key: key2,
      content: {
        'theme': 'dark',
        'notifications': true,
      },
      updatedOn: DateTime.now(),
      tag: tag2,
    );
    _loadContent();
  }

  Future<void> _clearKey1() async {
    await SuperContentCache.clearKey(key1);
    _loadContent();
  }

  Future<void> _clearTag1() async {
    await SuperContentCache.clearTag(tag1);
    _loadContent();
  }

  Future<void> _clearAll() async {
    await SuperContentCache.clearAll();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Content Cache Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content for $key1:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Content: ${content1 ?? 'None'}'),
              Text('Updated On: ${updatedOn1 ?? 'None'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _storeContent1,
                child: const Text('Store Content 1'),
              ),
              ElevatedButton(
                onPressed: _updateContent1,
                child: const Text('Update Content 1'),
              ),
              ElevatedButton(
                onPressed: _clearKey1,
                child: const Text('Clear Key 1'),
              ),
              ElevatedButton(
                onPressed: _clearTag1,
                child: const Text('Clear Tag 1'),
              ),
              const Divider(),
              Text(
                'Content for $key2:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Content: ${content2 ?? 'None'}'),
              Text('Updated On: ${updatedOn2 ?? 'None'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _storeContent2,
                child: const Text('Store Content 2'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: _clearAll,
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear All Cache'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
