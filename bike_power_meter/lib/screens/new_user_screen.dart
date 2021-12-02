import 'package:flutter/material.dart';

class NewUserScreen extends StatefulWidget {
  static const routeName = '/new-user-screen';
  const NewUserScreen({Key? key}) : super(key: key);

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _titleController = TextEditingController();

  String _user = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Power Meter'),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Enter the following fields',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'UserName'),
            controller: _titleController,
            onChanged: (val) => _user = val,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(_user);
                },
                child: const Text('Add User')),
          ),
        ],
      ),
    );
  }
}
