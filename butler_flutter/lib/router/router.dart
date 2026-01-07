import 'package:butler_flutter/screens/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:butler_flutter/main.dart';
import 'package:butler_flutter/router/routes.dart';
import 'package:butler_flutter/screens/pre_auth/sign_in_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'; // For auth

final router = GoRouter(
  initialLocation: Routes.rootRoute,
  refreshListenable: client.auth.authInfoListenable,
  routes: [
    GoRoute(
      path: Routes.rootRoute,
      builder: (context, state) => HomePage(),
      redirect: (context, state) {
        if (!client.auth.isAuthenticated) {
          return Routes.signinRoute;
        }
        return null;
      },
    ),
    GoRoute(
      path: Routes.signinRoute,
      builder: (context, state) => const SignInScreen(),
      redirect: (context, state) {
        if (client.auth.isAuthenticated) {
          return Routes.rootRoute;
        }
        return null;
      },
    ),
  ],
);
