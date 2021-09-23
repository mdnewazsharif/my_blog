import 'dart:io';

import 'package:blog/constant.dart';
import 'package:blog/models/api_response.dart';
import 'package:blog/models/post.dart';
import 'package:blog/screens/login.dart';
import 'package:blog/services/post_service.dart';
import 'package:blog/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String title;
  const PostForm({Key? key, this.post, required this.title}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final txtControllerBody = TextEditingController();
  bool _loading = false;

  File? _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(txtControllerBody.text, image);

    if (response.error == null) {
      Navigator.of(context).pop();
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

  // edit post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, txtControllerBody.text);
    if (response.error == null) {
      Navigator.of(context).pop();
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

  @override
  void initState() {
    if (widget.post != null) {
      txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                widget.post != null
                    ? const SizedBox()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        decoration: BoxDecoration(
                          image: _imageFile == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(
                                    _imageFile ?? File(''),
                                  ),
                                  fit: BoxFit.cover),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              getImage();
                            },
                            icon: const Icon(Icons.image,
                                size: 50, color: Colors.black38),
                          ),
                        ),
                      ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: txtControllerBody,
                      keyboardType: TextInputType.multiline,
                      maxLines: 9,
                      validator:
                          RequiredValidator(errorText: 'Post body is requried'),
                      decoration: const InputDecoration(
                          hintText: 'Post body...',
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.black38),
                          )),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: kTextButton(
                    'Post',
                    () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = !_loading;
                        });
                        if (widget.post == null) {
                          _createPost();
                        } else {
                          _editPost(widget.post!.id ?? 0);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
