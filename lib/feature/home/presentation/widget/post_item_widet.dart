import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/utils/extension.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';
import 'package:test1/feature/home/logic/model/post_model.dart';
import 'package:test1/feature/home/presentation/widget/comment_widget.dart';
import 'package:test1/feature/home/presentation/widget/likes_dialog_widget.dart';

class PostItemWidget extends StatelessWidget {
  const PostItemWidget({super.key, required this.post});
  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    print("->>>>>>>>>>>>>>> ");
    print(post.userImageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? const Color(0xFF1E1E1E) // Dark card background
                : Colors.white, // Light card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF333333) // Dark border
                  : const Color(0xFFE5E5E5), // Light border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.15),
            blurRadius: isDark ? 8 : 6,
            offset: const Offset(0, 3),
            spreadRadius: isDark ? 1 : 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark
                              ? const Color(0xFF444444)
                              : const Color(0xFFDDDDDD),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFFF0F0F0),
                    backgroundImage:
                        post.userImageUrl.isNotEmpty
                            ? NetworkImage(post.userImageUrl)
                            : null,
                    child:
                        post.userImageUrl.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 24,
                              color:
                                  isDark
                                      ? const Color(0xFF888888)
                                      : const Color(0xFF666666),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      print(" -------------------- ${post.userid}");
                      context.pushNamed(
                        Routes.profileScreen,
                        arguments: post.userid,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color:
                                  isDark
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            post.postDate.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDark
                                      ? const Color(0xFF999999)
                                      : const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              post.postContent,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color:
                    isDark ? const Color(0xFFE5E5E5) : const Color(0xFF2A2A2A),
              ),
            ),
          ),

          // Post image (if available)
          if (post.postImageUrl != null && post.postImageUrl!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.postImageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isDark
                                  ? const Color(0xFF444444)
                                  : const Color(0xFFDDDDDD),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color:
                                  isDark
                                      ? const Color(0xFF666666)
                                      : const Color(0xFF999999),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image failed to load',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? const Color(0xFF888888)
                                        : const Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
          ),

          // Interaction buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInteractionButtons(context, isDark),
                const SizedBox(height: 12),
                _buildLikesCount(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButtons(BuildContext context, bool isDark) {
    // Safely check if HomeCubit is available
    try {
      final cubit = context.read<HomeCubit>();

      return Row(
        children: [
          Expanded(
            child: StreamBuilder<bool>(
              stream: cubit.getLikeStatusStream(post.postId),
              initialData: post.isLikedByCurrentUser,
              builder: (context, snapshot) {
                final isLiked = snapshot.data ?? false;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      cubit.toggleLike(post.postId);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isLiked
                                ? (isDark
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFF1976D2))
                                : (isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF8F8F8)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isLiked
                                  ? (isDark
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF1565C0))
                                  : (isDark
                                      ? const Color(0xFF444444)
                                      : const Color(0xFFDDDDDD)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 18,
                            color:
                                isLiked
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFFBBBBBB)
                                        : const Color(0xFF666666)),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isLiked ? 'Liked' : 'Like',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  isLiked
                                      ? Colors.white
                                      : (isDark
                                          ? const Color(0xFFBBBBBB)
                                          : const Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showCommentsBottomSheet(context, post.postId);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isDark
                              ? const Color(0xFF444444)
                              : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 18,
                        color:
                            isDark
                                ? const Color(0xFFBBBBBB)
                                : const Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder<int>(
                        stream: cubit.getCommentsCountStream(post.postId),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text(
                            count > 0 ? 'Comments ($count)' : 'Comment',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? const Color(0xFFBBBBBB)
                                      : const Color(0xFF666666),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      // If HomeCubit is not available, show basic buttons
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFDDDDDD),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 18,
                    color:
                        isDark
                            ? const Color(0xFF666666)
                            : const Color(0xFF999999),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Like',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF444444)
                          : const Color(0xFFDDDDDD),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color:
                        isDark
                            ? const Color(0xFF666666)
                            : const Color(0xFF999999),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comment',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLikesCount(BuildContext context, bool isDark) {
    try {
      final cubit = context.read<HomeCubit>();

      return StreamBuilder<int>(
        stream: cubit.getLikesCountStream(post.postId),
        builder: (context, snapshot) {
          final likesCount = snapshot.data ?? 0;

          if (likesCount == 0) {
            return Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color:
                      isDark
                          ? const Color(0xFF666666)
                          : const Color(0xFF999999),
                ),
                const SizedBox(width: 6),
                Text(
                  "No likes yet",
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFF666666),
                  ),
                ),
              ],
            );
          }

          return GestureDetector(
            onTap: () => _showLikesDialog(context, post.postId),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                          : [const Color(0xFF1976D2), const Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? Colors.blue.shade800
                            : Colors.blue.shade300)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thumb_up, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    "$likesCount ${likesCount == 1 ? 'like' : 'likes'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.visibility, size: 14, color: Colors.white70),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      return Row(
        children: [
          Icon(
            Icons.thumb_up_outlined,
            size: 16,
            color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
          ),
          const SizedBox(width: 6),
          Text(
            "No likes yet",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF666666),
            ),
          ),
        ],
      );
    }
  }

  void _showCommentsBottomSheet(BuildContext context, String postId) {
    try {
      final homeCubit = context.read<HomeCubit>();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return BlocProvider.value(
            value: homeCubit,
            child: CommentsWidget(postId: postId),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening comments: $e'),
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF333333)
                  : const Color(0xFF424242),
        ),
      );
    }
  }

  void _showLikesDialog(BuildContext context, String postId) {
    try {
      final homeCubit = context.read<HomeCubit>();

      showDialog(
        context: context,
        builder: (context) {
          return BlocProvider.value(
            value: homeCubit,
            child: LikesDialog(postId: postId),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening likes: $e'),
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF333333)
                  : const Color(0xFF424242),
        ),
      );
    }
  }
}
