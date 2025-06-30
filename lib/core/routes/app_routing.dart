import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/feature/auth/logic/auth_repo.dart';
import 'package:test1/feature/auth/logic/cubit/auth_cubit.dart';
import 'package:test1/feature/auth/presentation/login_screen.dart';
import 'package:test1/feature/auth/presentation/signup_screen.dart';
import 'package:test1/feature/home/home_screen.dart';
import 'package:test1/feature/home/logic/add_post_repo.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';
import 'package:test1/feature/home/logic/home_repo.dart';
import 'package:test1/feature/home/presentation/addpost_screen.dart';
import 'package:test1/feature/profile/logic/cubit/profile_cubit.dart';
import 'package:test1/feature/profile/logic/profile_repo.dart';
import 'package:test1/feature/profile/presentation/profile_screen.dart';
import 'package:test1/feature/splash/splash_screen.dart';

class AppRouter {
  final AuthRepo authRepo = AuthRepo(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
  final HomeRepo homeRepo = HomeRepo(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
  final AddPostRepo addpostRepo = AddPostRepo(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
  final ProfileRepo profilerepo = ProfileRepo(   
    firestore: FirebaseFirestore.instance,
  );
  late final AuthCubit authCubit = AuthCubit(authRepo);
  late final HomeCubit homeCubit = HomeCubit(homeRepo,addpostRepo);
  late final ProfileCubit profileCubit = ProfileCubit(profilerepo);

  Route generateRouter(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider.value(
                value: authCubit,
                child: const LoginScreen(),
              ),
        );

      case Routes.signupScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider.value(
                value: authCubit,
                child: const SignupScreen(),
              ),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder:
              (context) =>
                  BlocProvider(               
                   create: (context) => HomeCubit(homeRepo,addpostRepo)..getPosts(),
                   child: HomeScreen()) 
        );
      case Routes.addPostScreen:
        return MaterialPageRoute(
          builder:
              (context) =>
                  BlocProvider(               
                   create: (context) => HomeCubit(homeRepo,addpostRepo),
                   child: AddPostScreen()) 
        );
    case Routes.profileScreen:
        final String userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ProfileCubit(profilerepo)..fetchProfile(userId),
              ),
              BlocProvider.value(
                value: homeCubit, 
              ),
            ],
            child: ProfileScreen(userId: userId),
          ),
        );
          case Routes.splashScreen:
          return MaterialPageRoute(builder: (context) => SplashScreen());
      default:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: 
                 
                  Center(
                    child: Text('No Route Defined for ${settings.name}'),
                  ),
                
              ),
        );
    }
  }
}
