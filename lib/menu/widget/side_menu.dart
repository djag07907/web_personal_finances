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
  final List<MenuOptions> _navItems = <MenuOptions>[
    MenuOptions(
      title: 'home',
      icon: Icons.home,
      pagePath: homeRoute,
    ),
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
  ];
  double get _menuHeight {
    return _isCollapsed ? 440.0 : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(final BuildContext context) {
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
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 4,
              color: black.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: SideMenu(
          minWidth: 80.0,
          maxWidth: 300.0,
          hasResizer: false,
          hasResizerToggle: false,
          mode: SideMenuMode.compact,
          controller: _menuController,
          backgroundColor: white,
          builder: (final SideMenuBuilderData data) {
            return SideMenuData(
              header: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16.0,
                  children: <Widget>[
                    CircularImageBorder(
                      minHeight: 95.0,
                      minWidth: 95.0,
                      imagePath: '${imagePath}logo.jpg',
                    ),
                    Text(
                      _isCollapsed ? emptyString : 'Daniel Alvarez',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: fontSize20,
                            color: LightColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              items: _buildMenuItems(context),
              footer: Visibility(
                visible: !_isCollapsed,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.asset(
                    '${imagePath}logo.jpg',
                    height: 45.0,
                  ),
                ),
              ),
              defaultTileData: SideMenuItemTileDefaults(
                hoverColor: LightColors.primary.withValues(alpha: 0.6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(22.5),
                    bottomRight: Radius.circular(22.5),
                  ),
                ),
                selectedDecoration: BoxDecoration(
                  color: _isCollapsed
                      ? white
                      : LightColors.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(22.5),
                    bottomRight: Radius.circular(22.5),
                  ),
                ),
                titleStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: LightColors.textSecondary,
                    ),
                selectedTitleStyle:
                    Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: white,
                        ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<SideMenuItemData> _buildMenuItems(final BuildContext context) {
    if (_options.isNotEmpty) return _options;
    for (MenuOptions item in _navItems) {
      final int index = _navItems.indexOf(item);
      _options.add(
        SideMenuItemDataTile(
          hasSelectedLine: false,
          title: context.translate(item.title),
          isSelected: _currentPage == index,
          icon: Icon(item.icon),
          selectedIcon: Icon(
            item.icon,
            color: LightColors.primary,
          ),
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
        divider: SizedBox(
          height: 100.0,
        ),
      ),
    );
    _options.addAll(<SideMenuItemData>[
      SideMenuItemDataTile(
        onTap: () {
          //TODO: Implement theme change
        },
        isSelected: false,
        hasSelectedLine: false,
        hoverColor: LightColors.primary.withValues(alpha: 0.6),
        title: context.translate('change_theme'),
        icon: Icon(
          Icons.dark_mode,
          color: LightColors.textSecondary,
        ),
      ),
      SideMenuItemDataTile(
        onTap: () {
          context.go(profileRoute);
        },
        isSelected: false,
        hasSelectedLine: false,
        hoverColor: LightColors.primary.withValues(alpha: 0.6),
        title: context.translate('profile'),
        icon: CircularImageBorder(
          minHeight: 50.0,
          minWidth: 50.0,
          labelImage: context.translate('Daniel Alvarez'),
          borderWidth: 3,
        ),
      ),
      SideMenuItemDataTile(
        onTap: _handleLogout,
        isSelected: false,
        hasSelectedLine: false,
        hoverColor: LightColors.primary.withValues(alpha: 0.6),
        title: context.translate('logout'),
        icon: Icon(
          Icons.logout_outlined,
          color: LightColors.textSecondary,
        ),
      ),
    ]);

    return _options;
  }

  void _handleNavigationMenu({
    required final String routePath,
    required final int page,
    required final BuildContext context,
  }) {
    setState(() => _currentPage = page);
    _options.clear();
    context.go(routePath);
  }

  Future<void> _handleLogout() async {
    await RepositoryProvider.of<AuthRepository>(context).signOut();
    context.go(rootRoute);
  }
}
