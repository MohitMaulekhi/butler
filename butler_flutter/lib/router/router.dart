import 'package:go_router/go_router.dart';
import 'package:butler_flutter/main.dart'; // To access `client`
import 'package:butler_flutter/router/routes.dart';
import 'package:butler_flutter/screens/sign_in_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'; // For auth

final router = GoRouter(
  initialLocation: Routes.rootRoute,
  refreshListenable: client.auth.authInfoListenable,
  routes: [
    GoRoute(
      path: Routes.rootRoute,
      builder: (context, state) => const MyHomePage(title: 'Butler AI'),
      redirect: (context, state) {
        if (!client.auth.isAuthenticated) {
          return Routes.signinRoute;
        }
        return null; // Stay on the current route
      },
    ),
    GoRoute(
      path: Routes.signinRoute,
      builder: (context, state) => const SignInScreen(),
      redirect: (context, state) {
        if (client.auth.isAuthenticated) {
          return Routes.rootRoute;
        }
        return null; // Stay on the current route
      },
    ),
  ],
);
