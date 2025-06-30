import 'package:test1/feature/auth/logic/model/user_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<UserModel> users;
  
  SearchSuccess(this.users);
}

class SearchError extends SearchState {
  final String message;
  
  SearchError(this.message);
}