import 'package:flutter/material.dart';

typedef void OnItemChanged(int newPosition);

class NavBar extends StatefulWidget {
  final OnItemChanged onItemChanged;
  final List<NavBarData> navBarItems;

  const NavBar({
    super.key,
    required this.navBarItems,
    required this.onItemChanged,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(32, 0, 32, 24),
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...widget.navBarItems
              .map((item) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = widget.navBarItems.indexOf(item);
                      });

                      widget.onItemChanged(_selectedIndex);
                    },
                    child: NavBarItem(
                      key: UniqueKey(),
                      data: item,
                      isSelected:
                          widget.navBarItems.indexOf(item) == _selectedIndex,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final NavBarData data;
  final bool isSelected;

  const NavBarItem({
    super.key,
    required this.data,
    required this.isSelected,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> sizeAnimation;
  late Animation<Color?> colorAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));

    sizeAnimation = Tween<double>(
      begin: 0,
      end: widget.isSelected ? 48 : 26,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    colorAnimation = ColorTween(
      begin: widget.isSelected ? Colors.black : Colors.white,
      end: widget.isSelected ? Colors.white : Colors.black,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    if (widget.isSelected) {
      _controller.forward();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: sizeAnimation.value,
              width: sizeAnimation.value,
              decoration: widget.isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: colorAnimation.value,
                    )
                  : null,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: widget.data.icon != null
                ? Icon(
                    widget.data.icon,
                    color: widget.isSelected ? Colors.black : Colors.white,
                    size: 24,
                  )
                : Image.asset(
                    widget.data.iconPath!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class NavBarData {
  final IconData? icon;
  final String? iconPath;

  NavBarData({this.icon, this.iconPath}) {
    assert(icon != null || iconPath != null, "Icon or IconPath must be set.");
  }
}
