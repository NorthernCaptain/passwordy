
import 'package:flutter/material.dart';
import 'package:passwordy/service/icon_mapping.dart';
import 'package:passwordy/service/utils.dart';

class CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  CircleIcon.fromColor({super.key, required this.icon, required this.backgroundColor})
      : color = backgroundColor.isLightColor() ? Colors.black : Colors.white;

  CircleIcon({super.key, required String iconName, required String backgroundColor})
      : icon = CircleIcon.getIcon(iconName),
        backgroundColor = ColorExtension.fromString(backgroundColor),
        color = ColorExtension.fromString(backgroundColor).isLightColor() ? Colors.black : Colors.white;

  static IconData getIcon(String iconName) {
    return IconMapping.iconMap[iconName] ?? Icons.no_encryption;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(
            icon,
            color: color
        )
    );
  }
}