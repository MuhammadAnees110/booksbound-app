import 'dart:convert';

import 'package:booksbound_app/features/admin/manage_users/providers/admin_users_provider.dart';
import 'package:booksbound_app/models/user_model.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Consumer<AdminUsersProvider>(
        builder: (_, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: provider.users.length,
            itemBuilder: (_, index) {
              final user = provider.users[index];
              return _buildUserTile(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    final provider = context.read<AdminUsersProvider>();
    final avatarUrl = user.photoUrl ?? "";
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl.isNotEmpty
              ? MemoryImage(base64Decode(avatarUrl))
              : null,
          child: avatarUrl.isEmpty ? Text(user.name[0].toUpperCase()) : null,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(user.email), Text('Role: ${user.role}')],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            Result result;
            if (value == 'block') {
              result = await provider.toggleBlock(user);
            } else if (value == 'makeAdmin') {
              result = await provider.makeAdmin(user);
            } else if (value == 'makeUser') {
              result = await provider.makeUser(user);
            } else {
              return;
            }
            if (!result.isSuccess && context.mounted) {
              ErrorPresenter.show(context, result);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'block',
              child: Text(user.isBlocked ? 'Unblock' : 'Block'),
            ),
            const PopupMenuItem(
              value: 'makeAdmin',
              child: Text('Make Admin'),
            ),
            const PopupMenuItem(
              value: 'makeUser',
              child: Text('Make User'),
            ),
          ],
        ),
      ),
    );
  }
}
