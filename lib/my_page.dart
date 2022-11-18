import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'main.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // ユーザーアイコン画像
            CircleAvatar(
              backgroundImage: NetworkImage(user?.photoURL ?? ''),
              radius: 40,
            ),
            // ユーザー名
            Text(
              user?.displayName ?? '名無し',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            // 部分的に左寄せにしたい場合の書き方
            Align(
              alignment: Alignment.centerLeft,
              // ユーザー ID
              child: Text('ユーザーID：${user?.uid}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              // 登録日
              child: Text('登録日：${user?.metadata.creationTime!}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Google からサインアウト
                await GoogleSignIn().signOut();
                // Firebase からサインアウト
                await FirebaseAuth.instance.signOut();
                // SignInPage に遷移
                // このページには戻れないようにします。
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return const SignInPage();
                  }),
                  (route) => false,
                );
              },
              child: const Text('サインアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
