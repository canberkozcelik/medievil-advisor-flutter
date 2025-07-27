import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';


/// Abstract platform service for handling platform-specific operations
abstract class PlatformService {
  /// Request microphone permission
  Future<bool> requestMicrophonePermission();
  
  /// Get temporary directory
  Future<Directory> getTemporaryDirectory();
  
  /// Check if microphone permission is granted
  Future<bool> isMicrophonePermissionGranted();
}

/// Implementation of PlatformService
class PlatformServiceImpl implements PlatformService {
  @override
  Future<bool> requestMicrophonePermission() async {
    try {
      print('PlatformService: Checking current microphone permission status...');
      
      // First, check current status
      final currentStatus = await Permission.microphone.status;
      print('PlatformService: Current permission status: $currentStatus');
      print('PlatformService: Is granted: ${currentStatus.isGranted}');
      print('PlatformService: Is denied: ${currentStatus.isDenied}');
      print('PlatformService: Is permanently denied: ${currentStatus.isPermanentlyDenied}');
      print('PlatformService: Is limited: ${currentStatus.isLimited}');
      print('PlatformService: Is restricted: ${currentStatus.isRestricted}');
      
      // If already granted, return true immediately
      if (currentStatus.isGranted) {
        print('PlatformService: Permission already granted');
        return true;
      }
      
      // If permanently denied, we can't request it again
      if (currentStatus.isPermanentlyDenied) {
        print('PlatformService: Permission permanently denied - cannot request again');
        return false;
      }
      
      // If limited (iOS), consider it as granted for our use case
      if (currentStatus.isLimited) {
        print('PlatformService: Permission limited - treating as granted');
        return true;
      }
      
      // Request permission only if not granted, not permanently denied, and not limited
      print('PlatformService: Requesting microphone permission...');
      print('PlatformService: About to call Permission.microphone.request()...');
      
      final newStatus = await Permission.microphone.request();
      
      print('PlatformService: Permission request completed');
      print('PlatformService: New permission status: $newStatus');
      print('PlatformService: New is granted: ${newStatus.isGranted}');
      print('PlatformService: New is denied: ${newStatus.isDenied}');
      print('PlatformService: New is permanently denied: ${newStatus.isPermanentlyDenied}');
      print('PlatformService: New is limited: ${newStatus.isLimited}');
      print('PlatformService: New is restricted: ${newStatus.isRestricted}');
      
      return newStatus.isGranted || newStatus.isLimited;
    } catch (e) {
      print('PlatformService: Permission request failed: $e');
      print('PlatformService: Exception type: ${e.runtimeType}');
      print('PlatformService: Exception details: $e');
      return false;
    }
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    try {
      return await path_provider.getTemporaryDirectory();
    } catch (e) {
      print('Failed to get temporary directory: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      print('PlatformService: Current permission status: $status');
      print('PlatformService: Permission is granted: ${status.isGranted}');
      return status.isGranted;
    } catch (e) {
      print('PlatformService: Failed to check microphone permission: $e');
      return false;
    }
  }
}

/// Mock implementation for testing
class MockPlatformService implements PlatformService {
  bool _microphonePermissionGranted = false;
  Directory? _tempDirectory;

  @override
  Future<bool> requestMicrophonePermission() async {
    return _microphonePermissionGranted;
  }

  @override
  Future<Directory> getTemporaryDirectory() async {
    if (_tempDirectory == null) {
      _tempDirectory = Directory.systemTemp;
    }
    return _tempDirectory!;
  }

  @override
  Future<bool> isMicrophonePermissionGranted() async {
    return _microphonePermissionGranted;
  }

  // Test helpers
  void setMicrophonePermission(bool granted) {
    _microphonePermissionGranted = granted;
  }

  void setTemporaryDirectory(Directory directory) {
    _tempDirectory = directory;
  }
} 