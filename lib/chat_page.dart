import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'post.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlue[200],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Post>>(
                // stream プロパティに snapshots() を与えると、コレクションの中のドキュメントをリアルタイムで監視することができます。
                stream: postsReference.orderBy('createdAt').snapshots(),
                // ここで受け取っている snapshot に stream で流れてきたデータが入っています。
                builder: (context, snapshot) {
                  // docs には Collection に保存されたすべてのドキュメントが入ります。
                  // 取得までには時間がかかるのではじめは null が入っています。
                  // null の場合は空配列が代入されるようにしています。
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // data() に Post インスタンスが入っています。
                      // これは withConverter を使ったことにより得られる恩恵です。
                      // 何もしなければこのデータ型は Map になります。
                      final post = docs[index].data();
                      return Wrap(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              post.text,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Aa',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  fillColor: Colors.grey[200],
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1.0,
                    ),
                  ),
                ),
                onFieldSubmitted: (text) {
                  // まずは user という変数にログイン中のユーザーデータを格納します
                  final user = FirebaseAuth.instance.currentUser!;

                  final posterId = user.uid; // ログイン中のユーザーのIDがとれます
                  final posterName = user.displayName!; // Googleアカウントの名前がとれます
                  final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

                  // 先ほど作った postsReference からランダムなIDのドキュメントリファレンスを作成します
                  // doc の引数を空にするとランダムなIDが採番されます
                  final newDocumentReference = postsReference.doc();

                  final newPost = Post(
                    text: text,
                    createdAt: Timestamp.now(), // 投稿日時は現在とします
                    posterName: posterName,
                    posterImageUrl: posterImageUrl,
                    posterId: posterId,
                    reference: newDocumentReference,
                  );

                  // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
                  // 引数として Post インスタンスを渡します。
                  // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
                  newDocumentReference.set(newPost);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
