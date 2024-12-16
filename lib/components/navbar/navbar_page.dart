import 'package:flutter/material.dart';

class NavbarPage extends StatelessWidget {
  final Widget body;

  const NavbarPage({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: body,
      )));
  }
}
