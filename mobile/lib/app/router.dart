import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/braindump/screens/brain_dump_screen.dart';
import '../features/capture/screens/quick_capture_screen.dart';
import '../features/inbox/screens/inbox_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/tasks/screens/task_detail_screen.dart';
import '../features/tasks/screens/tasks_screen.dart';
import '../features/today/screens/today_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) => createRouter());

GoRouter createRouter({String initialLocation = '/'}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodayScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: '/capture',
          pageBuilder: (context, state) =>
              modalPage(const QuickCaptureScreen()),
        ),
        GoRoute(
          path: '/braindump',
          pageBuilder: (context, state) =>
              modalPage(const BrainDumpScreen()),
        ),
        GoRoute(
          path: '/task/:id',
          pageBuilder: (context, state) => modalPage(
            TaskDetailScreen(taskId: state.pathParameters['id']!),
          ),
        ),
      ],
    );

/// Slide-up transition untuk rute modal — DESIGN_SYSTEM.md §8.
Page<void> modalPage(Widget child) => CustomTransitionPage(
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            animation.drive(CurveTween(curve: const Cubic(0.2, 0, 0, 1)));
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
