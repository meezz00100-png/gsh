import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool enabled;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? Colors.grey[700] : Colors.grey[400],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? Colors.black : Colors.grey[400],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: enabled ? Colors.grey[400] : Colors.grey[300],
      ),
      onTap: enabled ? onTap : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}
