import 'package:flutter/material.dart';

class RecurringTransactions extends StatefulWidget {
  const RecurringTransactions({super.key});

  @override
  State<StatefulWidget> createState() => _RecurringTransactionsState();
}

class _RecurringTransactionsState extends State<RecurringTransactions> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Center(child: Text("Under Contruction")),
          )),
    );
  }
}
