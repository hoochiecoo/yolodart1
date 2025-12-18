import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 0;

  final pages = const [
    WebViewApp(),
    YoloCameraPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.public), label: 'Web'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Camera'),
        ],
      ),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  
  final String targetUrl = 'https://bowlmates.club/SU_OPEN/ST/b_logout.html';

  // Используем стандартный UserAgent Android Chrome, чтобы сайт доверял приложению
  // и корректно сохранял куки/localStorage.
  final String customUserAgent = 
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(customUserAgent) // Важно для сессий
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // Разрешаем все переходы внутри WebView, чтобы не выкидывало в браузер
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(controller: controller),
    );
  }
}

class YoloCameraPage extends StatelessWidget {
  const YoloCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: YOLOView(
        modelPath: 'yolo11n',
        task: YOLOTask.detect,
        onResult: (results) {
          debugPrint('Found ${results.length} objects!');
          for (final result in results) {
            debugPrint('${result.className}: ${result.confidence}');
          }
        },
      ),
    );
  }
}
