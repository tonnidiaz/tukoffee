import 'package:flutter/material.dart';

class TuScrollview extends StatelessWidget {
  final Widget? child;
  const TuScrollview({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: child,
    );
  }
}
