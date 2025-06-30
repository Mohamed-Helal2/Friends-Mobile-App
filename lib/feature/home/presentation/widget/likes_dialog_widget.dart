import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/utils/extension.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';
import 'package:test1/feature/home/logic/model/likes_model.dart';

class LikesDialog extends StatelessWidget {
  final String postId;

  const LikesDialog({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Likes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            Divider(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
            ),

            // Likes list
            Expanded(
              child: StreamBuilder<List<UserLikeModel>>(
                stream: context.read<HomeCubit>().getUsersWhoLikedStream(
                  postId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.blue[300] : Colors.blue,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading likes',
                        style: TextStyle(
                          color: isDarkMode ? Colors.red[300] : Colors.red,
                        ),
                      ),
                    );
                  }

                  final likes = snapshot.data ?? [];

                  if (likes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 48,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No likes yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: likes.length,
                    itemBuilder: (context, index) {
                      final like = likes[index];
                      return LikeItem(like: like);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => LikesDialog(postId: postId),
    );
  }
}

class LikeItem extends StatelessWidget {
  final UserLikeModel like;

  const LikeItem({super.key, required this.like});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isDarkMode 
            ? Colors.grey[800]?.withOpacity(0.3)
            : Colors.grey[50],
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          backgroundImage: like.userImageUrl.isNotEmpty
              ? NetworkImage(like.userImageUrl)
              : null,
          child: like.userImageUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                )
              : null,
        ),
        title: Text(
          like.userName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          _formatTime(like.likedAt),
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.thumb_up,
          color: isDarkMode ? Colors.blue[300] : Colors.blue,
          size: 20,
        ),
        onTap: () {
          context.pushNamed(Routes.profileScreen, arguments: like.userId);
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}