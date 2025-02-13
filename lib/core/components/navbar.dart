import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:client/core/theme/theme.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  final Widget child;

  const BottomNavBar({super.key, required this.child});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _tabIndex = 0;

  final List<String> routes = [
    '/home',
    '/map',
    '/tutorial-category',
    '/chat',
    '/settings',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final newIndex = routes.indexOf(currentRoute);

    if (newIndex != _tabIndex) {
      setState(() {
        _tabIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          _buildNavBarIcon('GrayHome', MainTheme.white),
          _buildNavBarIcon('GrayHospital', MainTheme.white),
          _buildNavBarIcon('GrayScan', MainTheme.white),
          _buildNavBarIcon('GrayChat', MainTheme.white),
          _buildNavBarIcon('GraySetting', MainTheme.white),
        ],
        inactiveIcons: [
          _buildNavBarIcon('GrayHome', MainTheme.navbarText),
          _buildNavBarIcon('GrayHospital', MainTheme.navbarText),
          _buildNavBarIcon('GrayScan', MainTheme.navbarText),
          _buildNavBarIcon('GrayChat', MainTheme.navbarText),
          _buildNavBarIcon('GraySetting', MainTheme.navbarText),
        ],
        height: 60,
        circleWidth: 50,
        circleColor: MainTheme.navbarFocusText,
        color: MainTheme.navbarBackground,
        levels: const ["หน้าแรก", "แผนที่", "สแกนตา", "แชท", "การตั้งค่า"],
        activeLevelsStyle: const TextStyle(
          fontSize: 10,
          color: MainTheme.navbarFocusText,
          fontFamily: 'BaiJamjuree',
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        inactiveLevelsStyle: const TextStyle(
          fontSize: 10,
          color: MainTheme.navbarText,
          fontFamily: 'BaiJamjuree',
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        shadowColor: const Color.fromRGBO(158, 158, 158, 1).withOpacity(0.5),
        elevation: 15,
        tabCurve: Curves.decelerate,
        tabDurationMillSec: 0,
        iconDurationMillSec: 0,
        activeIndex: _tabIndex,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
          context.go(routes[_tabIndex]);
        },
      ),
      body: widget.child,
    );
  }

  Widget _buildNavBarIcon(String assetName, Color color) {
    return Image(
      image: AssetImage('assets/icon/$assetName.png'),
      width: 25,
      height: 25,
      color: color,
    );
  }
}
