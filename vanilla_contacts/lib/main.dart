import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage(), routes: {
      '/new-contact': (context) => const NewContactView(),
    });
  }
}

class Contact {
  final String id;
  final String name;

  Contact({required this.name}) : id = const Uuid().v4();
}

class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._() : super([]);
  static final ContactBook _instance = ContactBook._();
  factory ContactBook() => _instance;

  int get length => value.length;

  void add({required Contact contact}) {
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (context, value, child) {
          final contacts = value;
          return ListView.builder(
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                onDismissed: (direction) {
                  ContactBook().remove(contact: contact);
                },
                key: ValueKey(contact.id),
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
              );
            },
            itemCount: contacts.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/new-contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Contact')),
      body: Column(children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter a new contact name',
          ),
        ),
        TextButton(
          onPressed: () {
            final contact = Contact(name: _nameController.text);
            ContactBook().add(contact: contact);
            Navigator.pop(context);
          },
          child: const Text('Add contact'),
        )
      ]),
    );
  }
}
