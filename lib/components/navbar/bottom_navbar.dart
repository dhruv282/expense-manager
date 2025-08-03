import 'package:expense_manager/pages/dashboard.dart';
import 'package:expense_manager/pages/expenses.dart';
import 'package:expense_manager/components/navbar/navbar_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentPageIndex;
  final Function(int)? onPageChanged;
  const BottomNavBar({super.key, required this.currentPageIndex, required this.onPageChanged});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: widget.onPageChanged,
        selectedIndex: widget.currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.paid_outlined),
            selectedIcon: Icon(Icons.paid),
            label: 'Expenses',
          ),
        ],
      ),
      body: <Widget>[
        /// Dashboard page
        const NavbarPage(body: Dashboard()),

        /// Expenses page
        const NavbarPage(body: ExpensePage()),
      ][widget.currentPageIndex],
    );
  }
}
