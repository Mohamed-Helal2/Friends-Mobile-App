import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/theme/cubit/theme_cubit.dart';
import 'package:test1/core/utils/extension.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';
import 'package:test1/feature/home/presentation/post_screen.dart';
import 'package:test1/feature/search/logic/cubit/search_cubit.dart';
import 'package:test1/feature/search/logic/search_user_repo.dart';
import 'package:test1/feature/search/presentation/search_user_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = SearchCubit(UserService());
  }

  @override
  void dispose() {
    _searchCubit.close();
    super.dispose();
  }

  Widget _buildUserAvatar({
    required String? photoUrl,
    required bool isDarkMode,
    double radius = 30,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
      backgroundImage:
          photoUrl != null && photoUrl.isNotEmpty
              ? NetworkImage(photoUrl)
              : null,
      child:
          photoUrl == null || photoUrl.isEmpty
              ? Icon(
                Icons.person,
                size: radius * 1.2,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Friends",
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xff0766ff),
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xff0766ff),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchUserDelegate(searchCubit: _searchCubit),
              );
            },
            icon: Icon(
              Icons.search,
              size: 35,
              color: isDarkMode ? Colors.white : const Color(0xff0766ff),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Dynamic DrawerHeader with user data
            StreamBuilder<Map<String, dynamic>?>(
              stream: context.read<HomeCubit>().getCurrentUserDataStream(),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                final userName = userData?['name'] ?? 'User';
                final userPhotoUrl = userData?['photoURL'];

                return DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [Colors.grey[800]!, Colors.grey[700]!]
                              : [Colors.blue, Colors.blue[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUserAvatar(
                        photoUrl: userPhotoUrl,
                        isDarkMode: isDarkMode,
                        radius: 35,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                );
              },
            ),

            // Theme Toggle
            SwitchListTile(
              secondary: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  );
                },
              ),
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              activeColor: isDarkMode ? Colors.blue[300] : Colors.blue,
              value: context.watch<ThemeCubit>().state == ThemeMode.dark,
              onChanged: (val) {
                context.read<ThemeCubit>().toggleTheme(val);
              },
            ),

            ListTile(
              leading: Icon(
                Icons.person,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                context.pushNamed(
                  Routes.profileScreen,
                  arguments: FirebaseAuth.instance.currentUser!.uid,
                );
              },
            ),

            // Logout ListTile
            ListTile(
              leading: Icon(
                Icons.logout,
                color: isDarkMode ? Colors.red[300] : Colors.red,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: const PostScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(Routes.addPostScreen);
        },
        backgroundColor: const Color(0xff0766ff),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            title: Text(
              'Logout',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await FacebookAuth.instance.logOut();
                  Navigator.pop(context);
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: isDarkMode ? Colors.red[300] : Colors.red,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
