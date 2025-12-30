import 'package:butler_client/butler_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'config/app_config.dart';
import 'screens/greetings_screen.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  // AppConfig loads the API server URL from the assets/config.json file.
  // When the app runs in a browser, this file is fetched from the server,
  // allowing the server to change the API URL at runtime.
  // This ensures the app always uses the correct API URL,
  // no matter which environment it is running in.
  final config = await AppConfig.loadConfig();
  final serverUrl = serverUrlFromEnv.isEmpty
      ? config.apiUrl ?? 'http://$localhost:8080/'
      : serverUrlFromEnv;

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  /// Holds the last result or null if no result exists yet.
  String? _resultMessage;

  /// Holds the last error message that we've received from the server or null
  /// if no error exists yet.
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  bool _loading = false;

  void _callGenerateRecipe() async {
    try {
      // Reset the state.
      setState(() {
        _errorMessage = null;
        _resultMessage = null;
        _loading = true;
      });

      // Call our `generateRecipe` method on the server.
      final result = await client.test.generateRecipe(
        _textEditingController.text,
      );

      // Update the state with the recipe we got from the server.
      setState(() {
        _errorMessage = null;
        _resultMessage = result;
        _loading = false;
      });
    } catch (e) {
      // If something goes wrong, set an error message.
      setState(() {
        _errorMessage = '$e';
        _resultMessage = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter your ingredients',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _loading ? null : _callGenerateRecipe,
                child: _loading
                    ? const Text('Loading...')
                    : const Text('Generate Recipe'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResultDisplay(
                  resultMessage: _resultMessage,
                  errorMessage: _errorMessage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
