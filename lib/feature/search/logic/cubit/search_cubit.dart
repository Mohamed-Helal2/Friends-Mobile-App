import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/feature/search/logic/cubit/search_state.dart';
import 'package:test1/feature/search/logic/search_user_repo.dart';

class SearchCubit extends Cubit<SearchState> {
  final UserService _userService;

  SearchCubit(this._userService) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    emit(SearchLoading());
    
    try {
      final users = await _userService.searchUsers(query);
      emit(SearchSuccess(users));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> getAllUsers() async {
    emit(SearchLoading());
    
    try {
      final users = await _userService.getAllUsers();
      emit(SearchSuccess(users));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}