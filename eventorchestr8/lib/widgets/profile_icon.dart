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
  Widget build(BuildContext context) {
    SharedPreferencesProvider sp = SharedPreferencesProvider();
    imageUrl = sp.userDetails['profilePicture'];
    return InkWell(
      onTap: () {
        Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
      },
      child: imageUrl == null || imageUrl ==""
          ? CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 20,
              child: const Icon(
                Icons.account_circle,
                size: 20,
                color: Colors.white,
              ),
            )
          : CircleAvatar(
              radius: 20,
              child: ClipOval(
                child: FadeInImage(
                  placeholder: AssetImage('assets/images/default_profile.jpg'),
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
    );
  }
}