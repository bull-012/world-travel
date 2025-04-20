import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RouterWrapper extends StatelessWidget {
  const RouterWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(child: child),
      ),
    );
  }
}
