part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}
final class HomeLoading extends HomeState {}
final class HomeSuccess extends HomeState {}
final class HomeError extends HomeState {
  final String error;

  HomeError(this.error);
}


final class HomeLoaded extends HomeState {
  final List<PostModel> posts;

  HomeLoaded({required this.posts});
  
}
