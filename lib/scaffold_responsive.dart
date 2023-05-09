import 'dart:async';

import 'package:flutter/material.dart';

/// The [ResponsiveScaffold] wraps a [Scaffold].
/// The drawer is replaced by the [menu] [Widget].
/// See [Scaffold] class for the documentation of most of the parameters.
/// The following parameters are specific to the [ResponsiveScaffold]:
/// * [menu]
/// * [menuController]
/// * [minimumWidthForPermanentVisibleMenu]
class ResponsiveScaffold extends StatefulWidget {
  /// See [Scaffold.appBar]
  final PreferredSizeWidget? appBar;

  /// See Scaffold.body]
  final Widget body;

  /// See [Scaffold.floatingActionButton]
  final Widget? floatingActionButton;

  /// See [Scaffold.floatingActionButtonLocation]
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// See [Scaffold.floatingActionButtonAnimator]
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// See [Scaffold.persistentFooterButtons]
  final List<Widget>? persistentFooterButtons;

  /// See [Scaffold.persistentFooterAlignment]
  final AlignmentDirectional persistentFooterAlignment;

  /// See [Scaffold.endDrawer]
  final Widget? endDrawer;

  /// See [Scaffold.onEndDrawerChanged]
  final DrawerCallback? onEndDrawerChanged;

  /// See [Scaffold.backgroundColor]
  final Color? backgroundColor;

  /// See [Scaffold.bottomNavigationBar]
  final Widget? bottomNavigationBar;

  /// See [Scaffold.bottomSheet]
  final Widget? bottomSheet;

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// See [Scaffold.primary]
  final bool primary;

  /// See [Scaffold.drawerEdgeDragWidth]
  final double? drawerEdgeDragWidth;

  /// See [Scaffold.drawerEnableOpenDragGesture]
  final bool drawerEnableOpenDragGesture;

  /// See [Scaffold.endDrawerEnableOpenDragGesture]
  final bool endDrawerEnableOpenDragGesture;

  /// See [Scaffold.restorationId]
  final String? restorationId;

  /// See [Scaffold.extendBody]
  final bool extendBody;

  /// See [Scaffold.extendBodyBehindAppBar]
  final bool extendBodyBehindAppBar;

  ///  Your custom widget that will be shown as the menu.
  final Widget menu;

  /// * [ResponsiveScaffold] < [minimumWidthForPermanentVisibleMenu]
  ///   Drawer mode: the menu will be hidden when not used because there is not
  /// * [ResponsiveScaffold] >= [minimumWidthForPermanentVisibleMenu]
  ///   Permanent Visible mode: The menu can stay visible
  ///
  /// Default value = 700, which is about 18.5 cm or about 7.3 inch
  final double minimumWidthForPermanentVisibleMenu;

  /// The [menuController] is used to open or close the menu
  /// from outside of the [ResponsiveScaffold].
  final ResponsiveMenuController menuController;

  const ResponsiveScaffold({
    super.key,
    required this.menu,
    required this.menuController,
    this.minimumWidthForPermanentVisibleMenu = 700.0,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold>
    with SingleTickerProviderStateMixin {
  bool isMobile = false;
  bool menuVisible = false;
  bool canBeDragged = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutQuad);
    widget.menuController
        .addListener((command) => _menuControllerListener(command));
  }

  void _menuControllerListener(MenuCommand command) {
    switch (command) {
      case MenuCommand.open:
        _openMenu();
        break;
      case MenuCommand.close:
        _closeMenu();
        break;
      case MenuCommand.toggle:
        _toggleMenu();
        break;
      case MenuCommand.closeIfNeeded:
        _closeMenuIfNeeded();
        break;
      default:
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    setState(() {
      isMobile =
          mediaQuery.size.width < widget.minimumWidthForPermanentVisibleMenu;
      menuVisible = !isMobile;
      _animationController.value = isMobile ? 0 : 1;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.menuController.closeController();
    super.dispose();
  }

  void _toggleMenu() {
    if (menuVisible) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _closeMenuIfNeeded() {
    if (isMobile) {
      _closeMenu();
    }
  }

  void _closeMenu() {
    setState(() {
      _animationController.reverse();
      menuVisible = false;
    });
  }

  void _openMenu() {
    setState(() {
      _animationController.forward();
      menuVisible = true;
    });
  }

  void onDragStart(DragStartDetails details) {
    bool isClosed = _animationController.isDismissed;
    bool isOpen = _animationController.isCompleted;
    canBeDragged = (isClosed && details.globalPosition.dx < 60) || isOpen;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (canBeDragged) {
      double delta = details.primaryDelta! / 300;
      _animationController.value += delta;
    }
  }

  void dragCloseDrawer(DragUpdateDetails details) {
    double delta = details.primaryDelta!;
    if (delta < 0) {
      menuVisible = false;
      _animationController.reverse();
    }
  }

  void onDragEnd(DragEndDetails details) async {
    const double minFlingVelocity = 365.0;

    if (details.velocity.pixelsPerSecond.dx.abs() >= minFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx / 300;

      await _animationController.fling(velocity: visualVelocity);
      if (_animationController.isCompleted) {
        setState(() {
          menuVisible = true;
        });
      } else {
        setState(() {
          menuVisible = false;
        });
      }
    } else {
      if (_animationController.value < 0.5) {
        _animationController.reverse();
        setState(() {
          menuVisible = false;
        });
      } else {
        _animationController.forward();
        setState(() {
          menuVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      persistentFooterButtons: widget.persistentFooterButtons,
      persistentFooterAlignment: widget.persistentFooterAlignment,
      endDrawer: widget.endDrawer,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      bottomNavigationBar: widget.bottomNavigationBar,
      bottomSheet: widget.bottomSheet,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      primary: widget.primary,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      restorationId: widget.restorationId,
      body: _createMenuAndBody(),
    );
  }

  Widget _createMenuAndBody() => AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => isMobile
            ? _createBodyOverlappedByMenu()
            : _createMenuAndBodySideBySide(),
      );

  Row _createMenuAndBodySideBySide() {
    return Row(
      children: [
        ClipRect(
          child: SizedOverflowBox(
            size: Size(300 * _animation.value, double.infinity),
            child: widget.menu,
          ),
        ),
        Expanded(child: widget.body),
      ],
    );
  }

  /// Also known as a side drawer:
  Stack _createBodyOverlappedByMenu() {
    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragStart: onDragStart,
          onHorizontalDragUpdate: onDragUpdate,
          onHorizontalDragEnd: onDragEnd,
        ),
        widget.body,
        if (_animation.value > 0)
          Container(
            color: Colors.black.withAlpha((150 * _animation.value).toInt()),
          ),
        if (_animation.value == 1)
          GestureDetector(
            onTap: _toggleMenu,
            onHorizontalDragUpdate: dragCloseDrawer,
          ),
        ClipRect(
          child: SizedOverflowBox(
            size: Size(300 * _animation.value, double.infinity),
            child: widget.menu,
          ),
        ),
      ],
    );
  }
}

/// Used to send [MenuCommand]s to the [ResponsiveScaffold]
class ResponsiveMenuController {
  final _controller = StreamController<MenuCommand>.broadcast();

  open() {
    _controller.sink.add(MenuCommand.open);
  }

  close() {
    _controller.sink.add(MenuCommand.close);
  }

  toggle() {
    _controller.sink.add(MenuCommand.toggle);
  }

  closeIfNeeded() {
    _controller.sink.add(MenuCommand.closeIfNeeded);
  }

  closeController() {
    _controller.close();
  }

  void addListener(void Function(dynamic command) commandListener) {
    _controller.stream.listen(commandListener);
  }
}

/// A [MenuCommand] can be send to a [ResponsiveScaffold]
/// using the [ResponsiveMenuController]
enum MenuCommand {
  // Show the menu
  open,

  // Hide the menu
  close,

  // If the menu is open then close it or vise versa
  toggle,

  // Close the menu when a menu item is selected
  // and the menu is in drawer mode.
  closeIfNeeded
}
