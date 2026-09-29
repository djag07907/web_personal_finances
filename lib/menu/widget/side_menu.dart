part of 'menu_body.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  final SideMenuController _menuController = SideMenuController();
  final List<SideMenuItemData> _options = <SideMenuItemData>[];
  int _currentPage = emptyInt;
  bool _isCollapsed = true;
  bool _isHoveringLogout = false;
  final List<MenuOptions> _navItems = <MenuOptions>[
    MenuOptions(title: 'home', icon: Icons.home, pagePath: homeRoute),
    MenuOptions(
      title: 'incomes',
      icon: Icons.trending_up,
      pagePath: incomesRoute,
    ),
    MenuOptions(
      title: 'expenses',
      icon: Icons.trending_down,
      pagePath: expensesRoute,
    ),
    MenuOptions(
      title: 'accounts_to_pay',
      icon: Icons.receipt_long,
      pagePath: accountsToPayRoute,
    ),
    MenuOptions(
      title: 'accounts_receivable',
      icon: Icons.request_quote,
      pagePath: accountsReceivableRoute,
    ),
    MenuOptions(title: 'savings', icon: Icons.savings, pagePath: savingsRoute),
  ];
  double get _menuHeight {
    return _isCollapsed ? 530.0 : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(final BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.path;
    return MouseRegion(
      onEnter: (final PointerEvent event) {
        setState(() {
          _isCollapsed = false;
        });
        _menuController.open();
      },
      onExit: (final PointerEvent event) {
        setState(() {
          _isCollapsed = true;
        });
        _menuController.close();
      },
      child: Container(
        height: _menuHeight,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          boxShadow: <BoxShadow>[BoxShadow(blurRadius: 4, color: shadowLight)],
        ),
        child: SideMenu(
          minWidth: 80.0,
          maxWidth: 300.0,
          hasResizer: false,
          hasResizerToggle: false,
          mode: SideMenuMode.compact,
          controller: _menuController,
          backgroundColor: surfaceDark,
          builder: (final SideMenuBuilderData data) {
            return SideMenuData(
              header: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16.0,
                  children: <Widget>[
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        color: transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CircularImageBorder(
                          minHeight: 85.0,
                          minWidth: 85.0,
                          imagePath: '${imagePath}logo.jpg',
                        ),
                      ),
                    ),
                    _isCollapsed
                        ? const SizedBox.shrink()
                        : Text(
                            'Daniel Alvarez',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontSize: fontSize20,
                                  color: white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ],
                ),
              ),
              items: _buildMenuItems(currentLocation),
              footer: Visibility(
                visible: !_isCollapsed,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '$appName v1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: textSecondaryDark),
                  ),
                ),
              ),
              defaultTileData: SideMenuItemTileDefaults(
                hoverColor: white.withValues(alpha: 0.5),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(22.5),
                    bottomRight: Radius.circular(22.5),
                  ),
                ),
                selectedDecoration: BoxDecoration(
                  color: white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22.5),
                    bottomRight: Radius.circular(22.5),
                  ),
                ),
                titleStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: textMedium),
                selectedTitleStyle: Theme.of(context).textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.w700, color: primaryColor),
              ),
            );
          },
        ),
      ),
    );
  }

  List<SideMenuItemData> _buildMenuItems(final String currentLocation) {
    _options.clear();

    for (MenuOptions item in _navItems) {
      final int index = _navItems.indexOf(item);
      final bool isSelected = item.pagePath == homeRoute
          ? currentLocation == homeRoute
          : currentLocation.startsWith(item.pagePath);

      _options.add(
        SideMenuItemDataTile(
          hasSelectedLine: false,
          title: context.translate(item.title),
          isSelected: isSelected,
          icon: Icon(item.icon),
          selectedIcon: Icon(item.icon, color: primaryColor),
          onTap: () => _handleNavigationMenu(
            routePath: item.pagePath,
            page: index,
            context: context,
          ),
        ),
      );
    }

    _options.add(
      SideMenuItemDataDivider(
        divider: SizedBox(height: _isCollapsed ? 20.0 : 100.0),
      ),
    );

    final bool isProfileSelected = currentLocation.startsWith(profileRoute);

    _options.add(
      SideMenuItemDataTile(
        onTap: () {
          context.go(profileRoute);
        },
        isSelected: isProfileSelected,
        hasSelectedLine: false,
        hoverColor: white.withValues(alpha: 0.5),
        title: context.translate('profile'),
        icon: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProfileSelected
                ? primaryColor.withValues(alpha: 0.4)
                : primaryColor.withValues(alpha: 0.2),
            border: Border.all(
              color: isProfileSelected ? white : primaryColor,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Icon(
              Icons.person,
              color: isProfileSelected ? white : primaryColor,
            ),
          ),
        ),
      ),
    );

    if (!_isCollapsed) {
      _options.add(
        SideMenuItemDataTile(
          onTap: _handleLogout,
          isSelected: false,
          hasSelectedLine: false,
          hoverColor: redAccentColor.withValues(alpha: 0.6),
          title: context.translate('logout'),
          titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: _isHoveringLogout ? white : textMedium,
          ),
          icon: IconTheme(
            data: IconThemeData(color: _isHoveringLogout ? white : textMedium),
            child: const Icon(Icons.logout_outlined),
          ),
          tooltipBuilder: (final Widget tile) => MouseRegion(
            onEnter: (_) => setState(() => _isHoveringLogout = true),
            onExit: (_) => setState(() => _isHoveringLogout = false),
            child: tile,
          ),
        ),
      );
    }

    return _options;
  }

  void _handleNavigationMenu({
    required final String routePath,
    required final int page,
    required final BuildContext context,
  }) {
    if (_currentPage != page) {
      setState(() => _currentPage = page);
    }
    if (mounted) {
      context.go(routePath);
    }
  }

  Future<void> _handleLogout() async {
    await RepositoryProvider.of<AuthRepository>(context).signOut();
    context.go(rootRoute);
  }
}
