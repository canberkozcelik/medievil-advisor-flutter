import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

/// Test setup helper for handling platform dependencies
class TestSetup {
  static void setupPlatformChannels() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock permission handler
    const MethodChannel permissionChannel = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'requestPermissions':
          return {'microphone': 'granted'};
        case 'checkPermissions':
          return {'microphone': 'granted'};
        default:
          return null;
      }
    });

    // Mock path provider
    const MethodChannel pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getTemporaryDirectory':
          return '/tmp';
        case 'getApplicationDocumentsDirectory':
          return '/app_docs';
        case 'getApplicationSupportDirectory':
          return '/app_support';
        default:
          return null;
      }
    });

    // Mock speech to text
    const MethodChannel speechChannel = MethodChannel(
      'speech_to_text',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
          return true;
        case 'listen':
          return true;
        case 'stop':
          return true;
        default:
          return null;
      }
    });
  }

  static void teardownPlatformChannels() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('speech_to_text'), null);
  }
} 