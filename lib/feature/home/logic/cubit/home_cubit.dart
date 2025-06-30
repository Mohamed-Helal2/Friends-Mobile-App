import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test1/feature/home/logic/add_post_repo.dart';
import 'package:test1/feature/home/logic/home_repo.dart';
import 'package:test1/feature/home/logic/model/comment_model.dart';
import 'package:test1/feature/home/logic/model/likes_model.dart';
import 'package:test1/feature/home/logic/model/post_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  
  StreamSubscription<List<PostModel>>? _postsSubscription;
final HomeRepo _homeRepo;
  final AddPostRepo _addPostRepo;

  HomeCubit(this._homeRepo, this._addPostRepo) : super(HomeInitial());

  void test() {
    print("-- home cubit");
  }

  // NEW: Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      return await _homeRepo.getCurrentUserData();
    } catch (e) {
      print('Error in cubit getting user data: $e');
      return null;
    }
  }

  // NEW: Stream current user data
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    return _homeRepo.getCurrentUserDataStream();
  }

 Future<void> addPost(String content, File? image) async {
    emit(HomeLoading());
    try {
      await _addPostRepo.addPost(content: content, image: image);
      emit(HomeSuccess());
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Initialize stream listening for posts
  void startListeningToPosts() {
    emit(HomeLoading());
    _postsSubscription?.cancel(); // Cancel any existing subscription
    
    _postsSubscription = _homeRepo.getPostsStream().listen(
      (posts) {
        emit(HomeLoaded(posts: posts));
      },
      onError: (error) {
        emit(HomeError(error.toString()));
      },
    );
  }

  // Stop listening to posts stream
  void stopListeningToPosts() {
    _postsSubscription?.cancel();
    _postsSubscription = null;
  }

  Future<void> getPosts() async {
    emit(HomeLoading());
    try {
      final posts = await _homeRepo.getPosts();
      emit(HomeLoaded(posts: posts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _homeRepo.likePost(postId);
      // No need to call getPosts() anymore - the stream will automatically update
    } catch (e) {
      emit(HomeError("Failed to like post: $e"));
    }
  }

  Future<int> getaccountLikes(String postId) async {
    try {
      return await _homeRepo.getLikesCount(postId);
    } catch (e) {
      emit(HomeError("Failed to get likes count: $e"));
      return 0;
    }
  }

  Stream<int> getLikesCountStream(String postId) {
    return _homeRepo.getLikesCountStream(postId);
  }

  Stream<bool> getLikeStatusStream(String postId) {
    return _homeRepo.getLikeStatusStream(postId);
  }

  // comment 
  Future<void> addComment(String postId, String content) async {
    try {
      await _homeRepo.addComment(postId: postId, content: content);
    } catch (e) {
      emit(HomeError("Failed to add comment: $e"));
    }
  }

  // Get comments
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      return await _homeRepo.getComments(postId);
    } catch (e) {
      emit(HomeError("Failed to get comments: $e"));
      return [];
    }
  }

  // Stream comments
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _homeRepo.getCommentsStream(postId);
  }

  // Get comments count
  Future<int> getCommentsCount(String postId) async {
    try {
      return await _homeRepo.getCommentsCount(postId);
    } catch (e) {
      emit(HomeError("Failed to get comments count: $e"));
      return 0;
    }
  }

  // Stream comments count
  Stream<int> getCommentsCountStream(String postId) {
    return _homeRepo.getCommentsCountStream(postId);
  }

  Future<List<UserLikeModel>> getUsersWhoLiked(String postId) async {
    try {
      return await _homeRepo.getUsersWhoLiked(postId);
    } catch (e) {
      print('Error getting users who liked: $e');
      return [];
    }
  }

  // NEW: Stream users who liked a post for real-time updates
  Stream<List<UserLikeModel>> getUsersWhoLikedStream(String postId) {
    return _homeRepo.getUsersWhoLikedStream(postId);
  }

  @override
  Future<void> close() {
    stopListeningToPosts();
    return super.close();
  }
}