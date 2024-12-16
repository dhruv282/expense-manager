import 'package:expense_manager/pages/dashboard.dart';
import 'package:expense_manager/pages/expenses.dart';
import 'package:expense_manager/components/navbar/navbar_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money),
            label: 'Expenses',
          ),
        ],
      ),
      body: <Widget>[
        /// Charts page
        const NavbarPage(body: Dashboard()),

        /// Expenses page
        const NavbarPage(body: ExpensePage()),
      ][currentPageIndex],
    );
  }
}
