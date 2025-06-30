import 'package:flutter/material.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/utils/extension.dart';
import 'package:test1/feature/home/logic/model/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final String postId;

  const CommentItem({super.key, required this.comment, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.pushNamed(Routes.profileScreen, arguments: comment.userId);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              backgroundImage: comment.userImageUrl.isNotEmpty
                  ? NetworkImage(comment.userImageUrl)
                  : null,
              child: comment.userImageUrl.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.grey[800]?.withOpacity(0.6)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode 
                        ? Colors.grey[700]!.withOpacity(0.3)
                        : Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[200] : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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