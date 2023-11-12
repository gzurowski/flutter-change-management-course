import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectProvider(),
      child: const MaterialApp(
        home: Scaffold(
          body: HomePage(),
        ),
      ),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(),
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => super.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapObjectStreamSubscription;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveObjectStreamSubscription;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  void start() {
    _cheapObjectStreamSubscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      // every seconds create a new object (could be API call, etc.)
      _cheapObject = CheapObject();
      notifyListeners();
    });

    _expensiveObjectStreamSubscription =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapObjectStreamSubscription.cancel();
    _expensiveObjectStreamSubscription.cancel();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(children: [
        const Row(children: [
          Expanded(child: CheapWidget()),
          Expanded(child: ExpensiveWidget()),
        ]),
        const Row(
          children: [
            Expanded(child: ObjectProviderWidget()),
          ],
        ),
        Row(children: [
          TextButton(
              onPressed: () {
                context.read<ObjectProvider>().stop();
              },
              child: const Text('Stop')),
          TextButton(
              onPressed: () {
                context.read<ObjectProvider>().start();
              },
              child: const Text('Start'))
        ])
      ]),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (provider) => provider.cheapObject,
    );
    return Container(
        height: 100,
        color: Colors.yellow,
        child: Column(
          children: [
            const Text('Cheap Widget'),
            const Text('Last updated'),
            Text(cheapObject.lastUpdated),
          ],
        ));
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );
    return Container(
        height: 100,
        color: Colors.blue,
        child: Column(
          children: [
            const Text('Expensive Widget'),
            const Text('Last updated'),
            Text(expensiveObject.lastUpdated),
          ],
        ));
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final objectProvider = context.watch<ObjectProvider>();
    return Container(
        height: 100,
        color: Colors.green,
        child: Column(
          children: [
            const Text('Object Provider Widget'),
            const Text('ID'),
            Text(objectProvider.id),
          ],
        ));
  }
}
