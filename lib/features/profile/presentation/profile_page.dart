import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/mediconnect_app_bar.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const String routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const MediconnectAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
            ),
            const SizedBox(height: 10),
            Text(
              ref.watch(authNotifierProvider).user?.name ?? 'User Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              ref.watch(authNotifierProvider).user?.email ?? 'user@example.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _ProfileMenu(title: 'History', icon: Icons.history, onPress: () => GoRouter.of(context).push('/history')),
            _ProfileMenu(title: 'Availability', icon: Icons.calendar_today_outlined, onPress: () => GoRouter.of(context).push('/availability')),
            _ProfileMenu(title: 'Payment Details', icon: Icons.payment_outlined, onPress: () => GoRouter.of(context).push('/payments')),
            _ProfileMenu(title: 'Reviews', icon: Icons.star_outline, onPress: () {}),
            const Divider(),
            _ProfileMenu(title: 'Settings', icon: Icons.settings_outlined, onPress: () {}),
            _ProfileMenu(
              title: 'Logout',
              icon: Icons.logout_outlined,
              textColor: Colors.red,
              endIcon: false,
              onPress: () async {
                // call notifier to clear secure storage / token
                await ref.read(authNotifierProvider.notifier).logout();
                // clear browser cookies on web to remove session/XSRF cookies
                if (kIsWeb) {
                  final cookies = html.document.cookie?.split(';') ?? [];
                  for (final c in cookies) {
                    final eq = c.indexOf('=');
                    final name = (eq > -1 ? c.substring(0, eq) : c).trim();
                    html.document.cookie = '$name=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/';
                  }
                }
                // navigate to login
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
      trailing: endIcon ? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.arrow_forward_ios, size: 18.0, color: Colors.grey),
      ) : null,
    );
  }
}
