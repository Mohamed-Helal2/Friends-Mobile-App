import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/feature/home/logic/cubit/home_cubit.dart';
import 'package:test1/feature/home/presentation/widget/post_item_widet.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to posts stream when screen loads
    context.read<HomeCubit>().startListeningToPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeError) {
          return Center(child: Text(state.error));
        } else if (state is HomeLoaded) {
          final posts = state.posts;
          if (posts.isEmpty) {
            return const Center(child: Text("No posts yet."));
          }
        
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
               
              return PostItemWidget(post: posts[index]);
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
