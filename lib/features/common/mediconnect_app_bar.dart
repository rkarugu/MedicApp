import 'package:flutter/material.dart';

class MediconnectAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  const MediconnectAppBar({Key? key, this.showBackButton = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 36),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('mediconnect', style: TextStyle(color: Color(0xFF0056b3), fontWeight: FontWeight.bold, fontSize: 20)),
              Text('Care is just a tap away!', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
