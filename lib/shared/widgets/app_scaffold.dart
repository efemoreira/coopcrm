import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';

/// Estrutura de navegação principal da aplicação.
/// Envolve o [child] com uma [NavigationBar] de 4 destinos:
/// Oportunidades, Comunicados, Cotas e Perfil.
/// O destino ativo é derivado do `matchedLocation` atual do go_router.
class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({required this.child, super.key});

  static const _destinations = [
    _NavItem(icon: Icons.work_outline, activeIcon: Icons.work, label: 'Oportunidades', route: AppRoutes.feed),
    _NavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign, label: 'Comunicados', route: AppRoutes.comunicados),
    _NavItem(icon: Icons.payment_outlined, activeIcon: Icons.payment, label: 'Cotas', route: AppRoutes.cotas),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil', route: AppRoutes.perfil),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.route));
    final index = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_destinations[i].route),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.route});
}
