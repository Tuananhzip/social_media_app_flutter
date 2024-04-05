import 'package:flutter/material.dart';
import 'package:social_media_app/utils/app_colors.dart';

class ListVideoScreen extends StatelessWidget {
  const ListVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: AppColors.blueColor,
      ),
    );
  }
}
