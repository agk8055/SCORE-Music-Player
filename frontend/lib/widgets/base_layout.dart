import 'package:flutter/material.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final bool showSearch;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final ValueChanged<String>? onSearchChanged;

  const BaseLayout({
    Key? key,
    required this.child,
    required this.title,
    this.showSearch = false,
    this.actions,
    this.bottomNavigationBar,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
  }

  void _handleSearchClear() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
    setState(() {
      _isSearchExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      bottomNavigationBar: widget.bottomNavigationBar,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: widget.showSearch ? 0.0 : 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black,
              leading: _isSearchExpanded ? null : IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFFFDB4D)),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: _isSearchExpanded
                  ? Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFFFFDB4D)),
                            onPressed: _handleSearchClear,
                          ),
                        ),
                        onChanged: _handleSearchChanged,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
              actions: [
                if (widget.showSearch && !_isSearchExpanded)
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFFFFDB4D)),
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = true;
                      });
                    },
                  ),
                ...?widget.actions,
              ],
              flexibleSpace: widget.showSearch
                  ? null
                  : FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFDB4D),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ];
        },
        body: widget.child,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFFDB4D),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, size: 40, color: Color(0xFFFFDB4D)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Library',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0 songs',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFFFFDB4D)),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFFFDB4D)),
            title: const Text('Favorites', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFFFFDB4D)),
            title: const Text('Recently Played', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFFFFDB4D)),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
} 