import 'package:flutter/material.dart';

class NavIconButton extends StatelessWidget {
  const NavIconButton({super.key, required this.iconData, this.onPressed, this.tooltip, this.isActive});

  final IconData iconData;
  final Function()? onPressed;
  final String? tooltip;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    var color = (isActive != null && isActive == true) ? Theme.of(context).colorScheme.secondary : Colors.black54;

    return SizedBox(
      height: 36.0,
      width: 36.0,
      child: IconButton(
        iconSize: 20.0,
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(iconData, color: color),
      ),
    );
  }
}
