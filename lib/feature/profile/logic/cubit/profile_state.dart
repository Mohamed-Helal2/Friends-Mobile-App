part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final Stream<List<PostModel>> postsStream;
  final bool isImageUploading;

  ProfileLoaded({
    required this.user,
    required this.postsStream,
    this.isImageUploading = false,
  });

  ProfileLoaded copyWith({
    UserModel? user,
    Stream<List<PostModel>>? postsStream,
    bool? isImageUploading,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      postsStream: postsStream ?? this.postsStream,
      isImageUploading: isImageUploading ?? this.isImageUploading,
    );
  }
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              