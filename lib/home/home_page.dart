import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    final _reminderStream =
        FirebaseFirestore.instance.collection("target_collection").snapshots();
    _reminderStream.listen((event) {
      Future.delayed(Duration.zero, () {
        reminderDialog(context);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _taskStream =
        FirebaseFirestore.instance.collection("queued_writes").snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text('home'),
      ),
      floatingActionButton: _FloatingActionButton(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final _data = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: _TaskCard(data: _data),
          );
        },
      ),
    );
  }

  Future<void> reminderDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("リマインダー"),
        content: Text("This is a reminder"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Ok"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    Key? key,
    required QuerySnapshot<Object?>? data,
  })  : _data = data,
        super(key: key);

  final QuerySnapshot<Object?>? _data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _data!.docs.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.check),
                title: Text('TODOリスト'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final now = DateTime.now();
        final targetTime = now.add(Duration(minutes: 1));
        final data = {
          'state': "PENDING",
          'deliverTime': targetTime,
        };
        await FirebaseFirestore.instance.collection("queued_writes").add(data);
      },
      child: Icon(Icons.add),
    );
  }
}
