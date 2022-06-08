import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fake WebSocket to simulate handling stream of data in the provider
abstract class WebSocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebSocketClient implements WebSocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    // we added optional parameter to start from specific number
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}

// provider to access webSocket to get data from there
final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  return FakeWebSocketClient();
});

// default Provider is readonly
//final counterProvider = Provider((ref) => 0);

// to update the data in the provider, use StateProvider
// final counterProvider = StateProvider((ref) => 0);

// we can add autoDispose to reset counter when we go back to home page
// final counterProvider = StateProvider.autoDispose((ref) => 0);

// we use StreamProvider to handle stream of data
// final counterProvider = StreamProvider<int>((ref) {
//   final wsClient = ref.watch(webSocketClientProvider);
//   return wsClient.getCounterStream();
// });

// we used family to pass an initial value for the counter
// first int for the provider type
// second int for the passed initial counter
final counterProvider = StreamProvider.family<int, int>((ref , start) {
  final wsClient = ref.watch(webSocketClientProvider);
  return wsClient.getCounterStream(start);
});

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Riverpod',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          surface: const Color(0xff003909),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: ((context) => const CounterPage()),
            ));
          },
          child: const Text('Go to counter page'),
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // we use watch to listen for every change in the provider data
    final AsyncValue<int> counter = ref.watch(counterProvider(5));

    // we use listen to listen for the changes in the provider
    // in order to show alert dialog under certain condition
    // we use listen<int> to listen to int value
    // ref.listen<int>(counterProvider, (previous, next) {
    //   if (next >= 5) {
    //     showDialog(
    //         context: context,
    //         builder: (context) {
    //           return AlertDialog(
    //             title: const Text('Warning'),
    //             content: const Text(
    //                 'Counter dangerously high, Consider resetting it'),
    //             actions: [
    //               TextButton(
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                   child: const Text('Ok'))
    //             ],
    //           );
    //         });
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // we use invalidate to reset the value in the provider
        //       ref.invalidate(counterProvider);
        //     },
        //     icon: const Icon(
        //       Icons.refresh,
        //     ),
        //   ),
        // ],
      ),
      body: Center(
        child: Text(
          // counter.toString(),

          // we used when to listen to the data whether it came data of error or it's loading
          counter
              .when(
                  data: (int value) => value,
                  error: (Object e, _) => e,
                  loading: () => 5)
              .toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // we use read to just get the value of the provider once just to update it
      //     ref.read(counterProvider.notifier).state++;
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
