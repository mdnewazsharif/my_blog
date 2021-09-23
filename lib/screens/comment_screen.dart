import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/comment.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/services/comment_service.dart';
import 'package:blog/services/user_services.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatefulWidget {
  final int postId;
  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<dynamic> _commentList = [];
  bool _loading = true;
  int userId = 0;
  int _editCommentId = 0;

  TextEditingController _txtCommentController = TextEditingController();

  // get all comment
  Future _getComments() async {
    userId = await getUserId();
    ApiResponse response = await getComments(widget.postId);
    if (response.error == null) {
      setState(() {
        _commentList = response.data as List<dynamic>;
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

  // create comment
  void _createComment() async {
    ApiResponse response =
        await createComment(widget.postId, _txtCommentController.text);

    if (response.error == null) {
      _getComments();
      _txtCommentController.clear();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  // edit comment
  void _editComment() async {
    ApiResponse response =
        await editComment(_editCommentId, _txtCommentController.text);
    if (response.error == null) {
      _editCommentId = 0;
      _txtCommentController.clear();
      _getComments();
    } else if (response.error == unauthorized) {
      logout().then((value) => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Login()), (route) => false));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // delete comment
  void _handleDeleteComment(int commentId) async {
    ApiResponse response = await deleteComment(commentId);
    if (response.error == null) {
      _getComments();
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
    _getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    child: ListView.builder(
                      itemCount: _commentList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Comment comment = _commentList[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(width: 0.5, color: Colors.black26),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          image: comment.user!.image != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      '${comment.user!.image}'),
                                                  fit: BoxFit.cover)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '${comment.user!.name}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  comment.user!.id == userId
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
                                              setState(() {
                                                _editCommentId =
                                                    comment.id ?? 0;
                                                _txtCommentController.text =
                                                    comment.comment ?? '';
                                              });
                                            } else {
                                              _handleDeleteComment(
                                                  comment.id ?? 0);
                                            }
                                          },
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('${comment.comment}'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onRefresh: () {
                      return _getComments();
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black26, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: kInputDecoration('Comment'),
                          controller: _txtCommentController,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_txtCommentController.text.isNotEmpty) {
                            setState(() {
                              _loading = true;
                            });
                            if (_editCommentId > 0) {
                              _editComment();
                            } else {
                              _createComment();
                            }
                          }
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
