import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only( left: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            ThingsboardImage.nexorLogo,
            height: 30,
          ),
        ],
      ),
    );
  }
}
