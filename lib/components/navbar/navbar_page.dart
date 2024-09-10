import 'package:expense_manager/pages/add_expense.dart';
import 'package:flutter/material.dart';

class NavbarPage extends StatelessWidget {
  final Widget body;

  const NavbarPage({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddExpensePage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
