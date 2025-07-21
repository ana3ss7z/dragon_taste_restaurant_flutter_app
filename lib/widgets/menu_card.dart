import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class MenuCard extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int likes;
  final int dislikes;

  MenuCard({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.likes,
    required this.dislikes,
  });

  @override
  _MenuCardState createState() => _MenuCardState();
}
class _MenuCardState extends State<MenuCard> {
  final _commentController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  bool _userLiked = false;
  bool _userDisliked = false;

  final Map<String, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserLikeStatus();
  }

  Future<void> _loadUserLikeStatus() async {
    if (_user == null) return;

    final docRef = _firestore.collection('menu').doc(widget.id);
    final likeDoc = await docRef.collection('likes').doc(_user!.uid).get();
    final dislikeDoc = await docRef.collection('dislikes').doc(_user!.uid).get();

    setState(() {
      _userLiked = likeDoc.exists;
      _userDisliked = dislikeDoc.exists;
    });
  }

  Future<String> _getUserName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null && doc.data()!['name'] != null) {
        final name = doc.data()!['name'] as String;
        _userNamesCache[userId] = name;
        return name;
      }
    } catch (_) {}
    return userId.substring(0, 6);
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty && _user != null) {
      await _firestore
          .collection('menu')
          .doc(widget.id)
          .collection('comments')
          .add({
        'text': _commentController.text,
        'userId': _user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
    }
  }

  void _toggleLike(bool isLike) async {
    if (_user == null) return;

    final docRef = _firestore.collection('menu').doc(widget.id);
    final userLikeRef = docRef.collection('likes').doc(_user!.uid);
    final userDislikeRef = docRef.collection('dislikes').doc(_user!.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int currentLikes = snapshot['likes'] ?? 0;
      int currentDislikes = snapshot['dislikes'] ?? 0;

      if (isLike) {
        final likeSnapshot = await transaction.get(userLikeRef);
        final dislikeSnapshot = await transaction.get(userDislikeRef);
        if (likeSnapshot.exists) {
          transaction.delete(userLikeRef);
          transaction.update(docRef, {'likes': currentLikes - 1});
          setState(() => _userLiked = false);
        } else {
          transaction.set(userLikeRef, {'liked': true});
          transaction.update(docRef, {'likes': currentLikes + 1});
          setState(() => _userLiked = true);
          if (dislikeSnapshot.exists) {
            transaction.delete(userDislikeRef);
            transaction.update(docRef, {'dislikes': currentDislikes - 1});
            setState(() => _userDisliked = false);
          }
        }
      } else {
        final dislikeSnapshot = await transaction.get(userDislikeRef);
        final likeSnapshot = await transaction.get(userLikeRef);
        if (dislikeSnapshot.exists) {
          transaction.delete(userDislikeRef);
          transaction.update(docRef, {'dislikes': currentDislikes - 1});
          setState(() => _userDisliked = false);
        } else {
          transaction.set(userDislikeRef, {'disliked': true});
          transaction.update(docRef, {'dislikes': currentDislikes + 1});
          setState(() => _userDisliked = true);
          if (likeSnapshot.exists) {
            transaction.delete(userLikeRef);
            transaction.update(docRef, {'likes': currentLikes - 1});
            setState(() => _userLiked = false);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            SizedBox(height: 10),
            Text(widget.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.description),
            Text('\$${widget.price.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up,
                      color: _userLiked ? Colors.blue : null),
                  onPressed: () => _toggleLike(true),
                ),
                Text('${widget.likes}'),
                IconButton(
                  icon: Icon(Icons.thumb_down,
                      color: _userDisliked ? Colors.blue : null),
                  onPressed: () => _toggleLike(false),
                ),
                Text('${widget.dislikes}'),
              ],
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
            ),
            SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('menu')
                  .doc(widget.id)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final userId = comment['userId'] as String;

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors
                                .primaries[userId.hashCode % Colors.primaries.length],
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(comment['text']),
                          subtitle: FutureBuilder<String>(
                            future: _getUserName(userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text('Loading...');
                              } else if (snapshot.hasError) {
                                return Text(
                                  'By User ${userId.substring(0, 6)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w200, fontSize: 12),
                                );
                              } else {
                                final name = snapshot.data!;
                                return Text(
                                  'By $name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w200, fontSize: 12),
                                );
                              }
                            },
                          ),
                        ),
                        Divider(thickness: 1),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
