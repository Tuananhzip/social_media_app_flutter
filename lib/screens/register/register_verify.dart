import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button/outline_button_login.component.dart';
import 'package:social_media_app/components/form/general_form.component.dart';
import 'package:social_media_app/screens/home_main/home_main.dart';
import 'package:social_media_app/services/authentication/authentication.services.dart';
import 'package:social_media_app/utils/app_colors.dart';
import 'package:social_media_app/utils/my_enum.dart';

class RegisterVerifyScreen extends StatefulWidget {
  const RegisterVerifyScreen({super.key});

  @override
  State<RegisterVerifyScreen> createState() => _RegisterVerifyScreenState();
}

class _RegisterVerifyScreenState extends State<RegisterVerifyScreen> {
  bool _isEmailVerified = false;
  final AuthenticationServices _authServices = AuthenticationServices();
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _isEmailVerified = await _authServices.isEmailVerified();
      // ignore: avoid_print
      print(_isEmailVerified);
    } catch (error) {
      // ignore: avoid_print
      print("checkEmailVerified : ---> $error");
    }
    if (_isEmailVerified) {
      Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const HomeMain(
              fragment: Fragments.homeScreen,
            ),
          ),
          ModalRoute.withName('/'));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GeneralFormComponent(
      listWidget: [
        const SizedBox(
          height: 45.0,
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Text(
          "Please check email ${_currentUser!.email}",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24.0,
          ),
        ),
        const Text(
          "To confirm whether this email account is yours, please go to your email and confirm the information for us.",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
        ),
        const SizedBox(
          height: 16.0,
        ),
        const Text(
          "If the page does not automatically redirect you to the next page, please press this button.",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0,
              color: AppColors.infoColor),
        ),
        const SizedBox(
          height: 16.0,
        ),
        SizedBox(
          width: 250.0,
          child: OutlineButtonLoginComponent(
            text: 'Continue',
            onTap: _onSubmit,
          ),
        ),
        SizedBox(
          child: _isEmailVerified
              ? null
              : const Text(
                  "Please confirm your email to continue",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dangerColor),
                ),
        ),
        SizedBox(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ))
              : null,
        )
      ],
    );
  }
}
