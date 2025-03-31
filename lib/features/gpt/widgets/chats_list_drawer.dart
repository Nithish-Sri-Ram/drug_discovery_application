import 'package:drug_discovery/core/common/loader.dart';
import 'package:drug_discovery/core/common/sign_in_button.dart';
import 'package:drug_discovery/features/auth/repository/auth_repository.dart';
import 'package:drug_discovery/features/gpt/controller/chat_controller.dart';
import 'package:drug_discovery/features/gpt/screens/gpt_screen.dart';
import 'package:drug_discovery/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:routemaster/routemaster.dart';
import 'package:drug_discovery/models/chat_model.dart';

class ChatListDrawer extends ConsumerWidget {
  const ChatListDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final chatController = ref.watch(chatControllerProvider.notifier);

    final chats = chatController.cachedChats;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? const SignInButton()
                : ListTile(
                    title: Text('New Chat'),
                    leading: Icon(Icons.chat),
                    onTap: () async {
                      // Create a new chat
                      final chatController =
                          ref.read(chatControllerProvider.notifier);
                      final email = ref
                          .read(authRepositoryProvider)
                          .getCurrentUserEmail();
                      if (email == null) {
                        print('Email not available');
                        return;
                      }

                      final newChat = ChatModel(
                        useremail: email,
                        title: "New Chat",
                        createdAt: DateTime.now(),
                      );

                      String chatId =
                          await chatController.createNewChat(newChat);
                      if (chatId.isEmpty) return;

                      Routemaster.of(context).push('/chat');
                    },
                  ),
            if (!isGuest)
              Expanded(
                child: chats.isEmpty
                    ? const Loader()
                    : ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, int index) {
                          final chat = chats[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Pallete.whiteColor,
                              child: const Icon(Icons.message),
                            ),
                            title: Text(chat.title),
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: GptScreen(chatId: chat.chatId),
                                withNavBar: true,
                              );
                            },
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
