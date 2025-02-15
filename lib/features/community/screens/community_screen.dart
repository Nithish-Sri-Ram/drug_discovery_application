import 'package:drug_discovery/core/common/error_text.dart';
import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/features/community/controller/community_controller.dart';
import 'package:drug_discovery/features/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({required this.name, super.key});

  void navigateToModTools(BuildContext context){
    Routemaster.of(context).push('/mod-tools/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunitiesByNameProvider(name)).when(
          data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150.0,
                    floating: false,
                    pinned: true,
                    // snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            Constants.bannerDefault,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  AssetImage(Constants.avatarDefault),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                community.name,
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              community.mods.contains(user.uid)
                                  ? OutlinedButton(
                                      onPressed: () => navigateToModTools(context),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text('Mod Tools'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                        community.members.contains(user.uid)
                                            ? 'Joined'
                                            : 'Join',
                                      ),
                                    )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${community.members.length} members',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Text('Displaying Posts')),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader()),
    );
  }
}
