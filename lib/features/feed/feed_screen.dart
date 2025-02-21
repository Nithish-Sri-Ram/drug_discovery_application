import 'package:drug_discovery/core/common/error_text.dart';
import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/post_card.dart';
import 'package:drug_discovery/features/community/controller/community_controller.dart';
import 'package:drug_discovery/features/posts/controller/post_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
          data: (communities) => ref.watch(userPostsProvider(communities)).when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = data[index];
                    return PostCard(post: post);
                  },
                );
              },
              error: (error, stackTrace) {
                print(error);
                return ErrorText(
                  error: error.toString(),
                );
              },
              loading: () => const Loader()),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
