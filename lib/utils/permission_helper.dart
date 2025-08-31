import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    Permission permission;

    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use specific media permissions
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    } else {
      // For iOS
      permission = Permission.photos;
    }

    final status = await permission.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    Permission permission;

    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        // For Android 13+, request media permissions
        final photoStatus = await Permission.photos.request();
        final videoStatus = await Permission.videos.request();
        return photoStatus.isGranted && videoStatus.isGranted;
      } else {
        permission = Permission.storage;
      }
    } else {
      permission = Permission.photos;
    }

    final status = await permission.request();
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return await Permission.photos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else {
      return await Permission.photos.isGranted;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        final photoGranted = await Permission.photos.isGranted;
        final videoGranted = await Permission.videos.isGranted;
        return photoGranted && videoGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else {
      return await Permission.photos.isGranted;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<int> _getAndroidVersion() async {
    // This is a simplified version - in a real app you might want to use device_info_plus
    return 33; // Assume modern Android for now
  }

  static Future<bool> showPermissionDialog(
    BuildContext context,
    String permissionType,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission Required'),
              content: Text(
                'This app needs $permissionType permission to function properly.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Grant Permission'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<void> showPermissionDeniedDialog(
    BuildContext context,
    String permissionType,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
            '$permissionType permission is required. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
