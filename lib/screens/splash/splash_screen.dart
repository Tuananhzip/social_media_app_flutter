import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/home/home_main.dart';
import 'package:social_media_app/screens/login/login.dart';
import 'package:social_media_app/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isLoggedIn = false;
  Stream<User?> userState = FirebaseAuth.instance.authStateChanges();

  Future<void> navigateToHome(User user) async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation1, animation2) => HomeMain(user: user),
        transitionsBuilder: (context, animation1, animation2, child) {
          return FadeTransition(
            opacity: animation1,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Check xem người dùng đã đăng nhập chưa sẽ chuyển qua những trang khác nhau
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (isLoggedIn) {
        navigateToHome(FirebaseAuth.instance.currentUser!);
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            pageBuilder: (context, animation1, animation2) =>
                const LoginScreen(),
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: userState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            isLoggedIn = false;
          } else {
            isLoggedIn = true;
          }
        }
        return splashScreen(context);
      },
    ));
  }

  Widget splashScreen(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 0.333,
            alignment: Alignment.center,
            child: Image.asset("assets/images/logo_social_media.png"),
          ),
        ),
        const Align(
          alignment: Alignment(0.0, 0.9),
          child: Text(
            "Tuananhzip © 2024 All Rights Reserved",
            style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.blackColor,
                fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
