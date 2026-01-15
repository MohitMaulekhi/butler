import 'package:serverpod/serverpod.dart';

/// Health check widget that returns server status information
class HealthWidget extends JsonWidget {
  HealthWidget()
    : super(
        object: {
          'status': 'ok',
          'timestamp': DateTime.now().toIso8601String(),
          'server': 'butler_server',
        },
      );
}

/// Health check route for monitoring and testing
class HealthRoute extends WidgetRoute {
  @override
  Future<WebWidget> build(Session session, Request request) async {
    return HealthWidget();
  }
}

/// Registers a health check REST endpoint.
///
/// This endpoint can be used by load balancers, monitoring tools,
/// or for manual testing via curl/browser.
void registerHealthRoute(Serverpod server) {
  server.webServer.addRoute(HealthRoute(), '/health');
}
