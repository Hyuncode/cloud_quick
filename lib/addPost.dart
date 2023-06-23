import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

Future<List> getLocation() async{
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high);

  List<String> location = [position.latitude.toString(), position.longitude.toString()];
  return location;
}

class PostForm extends StatefulWidget {

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(); // title
  final _contentController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String selectedCategory = '의류';
  String selectedOption = '의뢰';

  final userState = FirebaseAuth.instance.currentUser;
  final List<File> _imageFiles = [];

  void submitData() async {
    //firestore data upload
    CollectionReference firePost =
        FirebaseFirestore.instance.collection("list");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      await firePost.add({
        'postTitle': _titleController.text,
        'postStart': _startController.text,
        'postEnd': _endController.text,
        'content': _contentController.text,
        'postOption': selectedOption,
        'category': selectedCategory,
        'userId': userState?.uid,
        'position_lat': position.latitude,
        'position_lon': position.longitude,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('added')),
      );
      _titleController.clear();
      _startController.clear();
      _endController.clear();
      _contentController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('failed')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 제목 입력칸
            TextFormField(
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              controller: _titleController, // 추가
            ),

            const SizedBox(height: 16), // 간격 조절
            // 이미지 첨부 버튼과 이미지들을 감싸는 컨테이너
            Row(
              children: [
                GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _imageFiles.map((file) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            child: Image.file(file, fit: BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // 간격 조
            // 출발지 입력칸
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '출발지',
                      border: OutlineInputBorder(),
                    ),
                    controller: _startController,
                  ),
                ),
                const SizedBox(
                  width: 32,
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  flex: 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: '도착지',
                            border: OutlineInputBorder(),
                          ),
                          controller: _endController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            setState(() {
                              _selectedDate = selectedDate!;
                            });
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: '날짜',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                  text: _selectedDate == null
                                      ? ''
                                      : '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            setState(() {
                              _selectedTime = selectedTime!;
                            });
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: '시간',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                  text: _selectedTime == null
                                      ? ''
                                      : '${_selectedTime.hour}:${_selectedTime.minute}'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // 간격 조절
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16), // 간격 조절

            // 카테고리 선택

            Row(
              children: [
                // 카테고리 선택
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(),
                    ),
                    items: ['의류', '전자제품', '서적', '서류', '박스'].map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (selectedCategory) {
                      // 선택한 카테고리에 따라 동작
                    },
                  ),
                ),

                // '의뢰' 버튼
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: selectedOption == '의뢰' ? Colors.blue : Colors.white,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (selectedOption != '의뢰') {
                        setState(() {
                          selectedOption = '의뢰';
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '의뢰',
                        style: TextStyle(
                          color: selectedOption == '의뢰'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                // '배송' 버튼
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: selectedOption == '배송' ? Colors.blue : Colors.white,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (selectedOption != '배송') {
                        setState(() {
                          selectedOption = '배송';
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '배송',
                        style: TextStyle(
                          color: selectedOption == '배송'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // 간격 조절
            // 내용 입력칸
            TextFormField(
              decoration: const InputDecoration(
                labelText: '내용을 입력하세요.',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
              ),
              maxLines: null, // 다중 줄 입력 가능하도록 설정
              controller: _contentController, // 추가
            ),

            const SizedBox(height: 16), // 간격 조절
            // 게시글 업로드 버튼

            ElevatedButton(
              onPressed: () {
                if (userState != null) {
                  submitData(); // 게시글 업로드 처리
                  //Navigator.pop(context);
                }
                else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Text("로그인 후 이용해주세요."),
                        );
                      }
                  );
                }
              },
              child: const Text('게시글 업로드'),
            ),
          ],
        ),
      ),
    );
  }
}
