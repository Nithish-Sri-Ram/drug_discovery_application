import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/features/auth/controller/auth_controller.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInButton extends ConsumerWidget {
  final bool isFromLogin;
  const SignInButton({Key? key, this.isFromLogin = true}) : super(key: key);

  void signInWithGoogle(BuildContext context,WidgetRef ref) {
    ref.read(authControllerProvider.notifier).signInWithGoogle(context,isFromLogin);
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: Text(
          'Continue with Google',
          style: TextStyle(fontSize: 18, color: Pallete.whiteColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}