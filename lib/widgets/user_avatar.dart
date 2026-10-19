import 'package:flutter/material.dart';
import '../models/user.dart';

class UserAvatar extends StatelessWidget {
  final AppUser user;
  final double size;

  const UserAvatar({super.key, required this.user, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Color(user.avatarColorValue),
      child: Text(
        user.initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.38),
      ),
    );
  }
}
