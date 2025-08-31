import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile_model.dart';
import '../../utils/constants.dart';
import '../../utils/permission_helper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      profileProvider.loadProfile(authProvider.user!.uid);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final hasPermission = await PermissionHelper.requestGalleryPermission();
    if (!hasPermission) {
      _showError(AppConstants.permissionDeniedMessage);
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        final downloadURL = await profileProvider.uploadProfilePicture(
          authProvider.user!.uid,
          File(pickedFile.path),
        );

        if (downloadURL != null) {
          _showSuccess('Profile picture updated successfully!');
          _loadProfile();
        } else if (profileProvider.errorMessage != null) {
          _showError(profileProvider.errorMessage!);
        }
      }
    }
  }

  Future<void> _pickAndUploadDocument() async {
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      _showError(AppConstants.permissionDeniedMessage);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedDocumentExtensions,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        int successCount = 0;

        for (final file in result.files) {
          if (file.path != null) {
            final downloadURL = await profileProvider.uploadDocument(
              authProvider.user!.uid,
              File(file.path!),
              file.name,
            );
            if (downloadURL != null) {
              successCount++;
            }
          }
        }

        if (successCount > 0) {
          final message = successCount == result.files.length
              ? 'All documents uploaded successfully!'
              : '$successCount of ${result.files.length} documents uploaded successfully.';
          _showSuccess(message);
        }

        if (successCount != result.files.length) {
          _showError(
              '${result.files.length - successCount} document(s) failed to upload.');
        }

        if (successCount > 0) {
          _loadProfile();
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    await authProvider.signOut();
    profileProvider.clearProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
      ),
      body: Consumer2<AuthProvider, ProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          if (profileProvider.isLoading && profileProvider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileProvider.profile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                // Profile Picture Section
                _buildProfilePictureSection(profile, profileProvider),
                const SizedBox(height: AppConstants.largePadding),

                // Profile Info Section
                if (profile != null) ...[
                  _buildProfileInfoSection(profile),
                  const SizedBox(height: AppConstants.largePadding),

                  // Document Section
                  _buildDocumentSection(profile, profileProvider),
                  const SizedBox(height: AppConstants.largePadding),

                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: profile),
                        ),
                      ).then((_) => _loadProfile());
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ] else ...[
                  // Create Profile Section
                  _buildCreateProfileSection(authProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePictureSection(
    ProfileModel? profile,
    ProfileProvider profileProvider,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: profile?.photoURL != null &&
                      profile!.photoURL!.isNotEmpty
                  ? CachedNetworkImageProvider(profile.photoURL!)
                  : null,
              child: profile?.photoURL == null || profile!.photoURL!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            if (profileProvider.isUploading)
              const Positioned.fill(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.black54,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppConstants.primaryColor,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: profileProvider.isUploading
                      ? null
                      : _pickAndUploadImage,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          profile?.name ?? 'No Name',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection(ProfileModel profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoRow('Name', profile.name),
            _buildInfoRow('Email', profile.email),
            _buildInfoRow('Age', profile.age.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(
    ProfileModel profile,
    ProfileProvider profileProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (profile.documents.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profile.documents.length,
                itemBuilder: (context, index) {
                  final document = profile.documents[index];
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(document.name),
                    subtitle: Text(document.sizeFormatted),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      final uri = Uri.parse(document.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        _showError('Could not open document');
                      }
                    },
                  );
                },
              ),
            ] else ...[
              const Text('No documents uploaded'),
            ],
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: profileProvider.isUploading
                  ? null
                  : _pickAndUploadDocument,
              icon: profileProvider.isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateProfileSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const Icon(
              Icons.person_add,
              size: 64,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Create Your Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'Complete your profile to get started',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      profile: ProfileModel(
                        uid: authProvider.user!.uid,
                        name: '',
                        email: authProvider.user!.email,
                        age: 0,
                        createdAt: DateTime.now(),
                        photoURL: '',
                        documents: [],
                      ),
                    ),
                  ),
                ).then((_) => _loadProfile());
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
