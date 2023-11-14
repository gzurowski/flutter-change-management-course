import 'package:flutter/material.dart';

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
  final String name;

  const Contact({required this.name});
}

class ContactBook {
  ContactBook._();
  static final ContactBook _instance = ContactBook._();
  factory ContactBook() => _instance;

  final List<Contact> _contacts = [];

  int get length => _contacts.length;

  void add({required Contact contact}) {
    _contacts.add(contact);
  }

  void remove({required Contact contact}) {
    _contacts.remove(contact);
  }

  Contact? contact({required int atIndex}) =>
      _contacts.length > atIndex ? _contacts[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contactBook = ContactBook();
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final contact = contactBook.contact(atIndex: index)!;
          return ListTile(
            title: Text(contact.name),
          );
        },
        itemCount: contactBook.length,
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
