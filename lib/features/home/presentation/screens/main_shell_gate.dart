import 'package:flutter/material.dart';

import '../../../../core/services/permission_flow.dart';
import 'main_shell.dart';

/// Wraps [MainShell] and runs the one-time permission prompt flow on first entry.
class MainShellGate extends StatefulWidget {
  const MainShellGate({super.key});

  @override
  State<MainShellGate> createState() => _MainShellGateState();
}

class _MainShellGateState extends State<MainShellGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await runPermissionPromptFlowIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) => const MainShell();
}
