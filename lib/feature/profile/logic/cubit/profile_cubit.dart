import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/feature/auth/logic/model/user_model.dart';
import 'package:test1/feature/home/logic/model/post_model.dart';
import 'package:test1/feature/profile/logic/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

void test(){
  print("----------- profile cubit");
}
  Future<void> fetchProfile(String userId) async {
    print("user id is ------------>> ${userId}");
    try {
      emit(ProfileLoading());
            final user = await _repository.getUserData(userId);
      if (user == null) {
        emit(ProfileError('User not found'));
        return;
      }
      final postsStream = _repository.getUserPosts(userId);
          
      emit(ProfileLoaded(user: user, postsStream: postsStream));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }
 Future<void> updateProfilePhoto(String userId, File imageFile) async {
  if (state is! ProfileLoaded) return;
  final currentState = state as ProfileLoaded;

  emit(currentState.copyWith(isImageUploading: true));
  try {
    final success = await _repository.updateProfilePhoto(userId, imageFile);
    if (!success) {
      emit(ProfileError("Image upload failed"));
      return;
    }

    final user = await _repository.getUserData(userId);
    if (user == null) {
      emit(ProfileError("User not found after updating image"));
      return;
    }

    emit(ProfileLoaded(
      user: user,
      postsStream: currentState.postsStream,
      isImageUploading: false,
    ));
  } catch (e) {
    emit(ProfileError("Failed to update image: $e"));
  }
}

}