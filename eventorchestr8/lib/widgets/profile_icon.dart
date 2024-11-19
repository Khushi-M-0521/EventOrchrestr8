import 'dart:io';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/screens/profilescreen.dart';
import 'package:flutter/material.dart';

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  void _loadProfilePicture() {
    SharedPreferencesProvider sp = SharedPreferencesProvider();
    setState(() {
      imageUrl = sp.userDetails['profilePicture'];
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        // Network image
        imageProvider = NetworkImage(imageUrl!);
      } else if (imageUrl!.startsWith('file://') ||
          File(imageUrl!).existsSync()) {
        // Local file image
        imageProvider = FileImage(File(imageUrl!));
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: imageProvider ??
            const AssetImage('assets/images/default_profile.jpg'),
        child: imageProvider == null
            ? const Icon(
                Icons.account_circle,
                size: 20,
                color: Colors.white,
              )
            : null, // No icon if the image is loaded
      ),
    );
  }
}
