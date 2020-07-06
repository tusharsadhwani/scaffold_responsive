library scaffold_responsive;

import 'package:flutter/material.dart';
import 'package:flutter_sidebar/flutter_sidebar.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget title;
  final Widget body;
  final List<Map<String, dynamic>> tabs;
  final void Function(String) onTabChanged;

  const ResponsiveScaffold({
    Key key,
    @required this.title,
    @required this.body,
    @required this.tabs,
    this.onTabChanged,
  }) : super(key: key);

  @override
  _ResponsiveScaffoldState createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold>
    with SingleTickerProviderStateMixin {
  static const _mobileThreshold = 700.0;
  bool isMobile = false;
  bool sidebarOpen = false;
  bool canBeDragged = false;

  GlobalKey _sidebarKey;

  AnimationController _animationController;
  Animation _animation;

  String activeTab;
  void setTab(String newTab) {
    setState(() {
      activeTab = newTab;
    });
  }

  @override
  void initState() {
    super.initState();
    _sidebarKey = GlobalKey();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutQuad);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      isMobile = mediaQuery.size.width < _mobileThreshold;
      sidebarOpen = !isMobile;
      _animationController.value = isMobile ? 0 : 1;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      sidebarOpen = !sidebarOpen;
      if (sidebarOpen)
        _animationController.forward();
      else
        _animationController.reverse();
    });
  }

  void onDragStart(DragStartDetails details) {
    bool isClosed = _animationController.isDismissed;
    bool isOpen = _animationController.isCompleted;
    canBeDragged = (isClosed && details.globalPosition.dx < 60) || isOpen;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double delta = details.primaryDelta / 300;
      _animationController.value += delta;
    }
  }

  void dragCloseDrawer(DragUpdateDetails details) {
    double delta = details.primaryDelta;
    if (delta < 0) {
      sidebarOpen = false;
      _animationController.reverse();
    }
  }

  void onDragEnd(DragEndDetails details) async {
    double _kMinFlingVelocity = 365.0;

    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / 300;

      await _animationController.fling(velocity: visualVelocity);
      if (_animationController.isCompleted) {
        setState(() {
          sidebarOpen = true;
        });
      } else {
        setState(() {
          sidebarOpen = false;
        });
      }
    } else {
      if (_animationController.value < 0.5) {
        _animationController.reverse();
        setState(() {
          sidebarOpen = false;
        });
      } else {
        _animationController.forward();
        setState(() {
          sidebarOpen = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sidebar = Sidebar.fromJson(
      key: _sidebarKey,
      tabs: widget.tabs,
      onTabChanged: widget.onTabChanged,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.menu), onPressed: _toggleSidebar),
        title: widget.title,
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => isMobile
            ? Stack(
                children: [
                  GestureDetector(
                    onHorizontalDragStart: onDragStart,
                    onHorizontalDragUpdate: onDragUpdate,
                    onHorizontalDragEnd: onDragEnd,
                  ),
                  widget.body,
                  if (_animation.value > 0)
                    Container(
                      color: Colors.black
                          .withAlpha((150 * _animation.value).toInt()),
                    ),
                  if (_animation.value == 1)
                    GestureDetector(
                      onTap: _toggleSidebar,
                      onHorizontalDragUpdate: dragCloseDrawer,
                    ),
                  ClipRect(
                    child: SizedOverflowBox(
                      size: Size(300 * _animation.value, double.infinity),
                      child: sidebar,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  ClipRect(
                    child: SizedOverflowBox(
                      size: Size(300 * _animation.value, double.infinity),
                      child: sidebar,
                    ),
                  ),
                  Expanded(child: widget.body),
                ],
              ),
      ),
    );
  }
}
