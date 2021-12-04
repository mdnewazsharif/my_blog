import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/post.dart';
import 'package:blog/screens/comment_screen.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/screens/post_form.dart';
import 'package:blog/services/post_service.dart';
import 'package:blog/services/user_services.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;

  // get all post

  Future retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();
    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // handle post like dislike
  void _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // handle delete post
  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => retrievePosts(),
            child: ListView.builder(
              itemCount: _postList.length,
              itemBuilder: (BuildContext context, int index) {
                Post post = _postList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        image: post.user!.image != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    '${post.user!.image}'),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(25),
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '${post.user!.name}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                              post.user!.id == userId
                                  ? PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          child: Text('Edit'),
                                          value: 'edit',
                                        ),
                                        const PopupMenuItem(
                                          child: Text('Delete'),
                                          value: 'delete',
                                        ),
                                      ],
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(Icons.more_vert,
                                            color: Colors.black),
                                      ),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => PostForm(
                                                title: 'Edit Post',
                                                post: post,
                                              ),
                                            ),
                                          );
                                        } else {
                                          _handleDeletePost(post.id ?? 0);
                                        }
                                      },
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(child: Text('${post.body}')),
                              ],
                            ),
                          ),
                          post.image != null
                              ? Container(
                                  height: 180,
                                  padding: const EdgeInsets.all(8),
                                  width: MediaQuery.of(context).size.width - 20,
                                  margin: const EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage('${post.image}'),
                                        fit: BoxFit.cover),
                                  ))
                              : SizedBox(
                                  height: post.image != null ? 0 : 10,
                                ),
                          Row(
                            children: [
                              kLikeAndComment(
                                post.likesCount ?? 0,
                                post.selfLiked == true
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                post.selfLiked == true
                                    ? Colors.red
                                    : Colors.black38,
                                () {
                                  _handlePostLikeDislike(post.id ?? 0);
                                },
                              ),
                              Container(
                                height: 25,
                                width: 0.5,
                                color: Colors.black38,
                              ),
                              kLikeAndComment(
                                post.commentsCount ?? 0,
                                Icons.sms_outlined,
                                Colors.black54,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CommentScreen(
                                        postId: post.id ?? 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            height: 25,
                            width: 0.5,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
