import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50, // set the size of the profile picture
                  backgroundImage: AssetImage(
                      'path/to/profile/image.jpg'), // replace with the path to the actual profile picture
                ),
                SizedBox(width: 20),
                // add some spacing between the profile picture and the user information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('유저 이름'),
                    Text('아이디'),
                    Text('가입 날짜'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            // add a horizontal line between the user information and the buttons
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('개인 정보 수정'),
              onTap: () {
                // navigate to the user information editing page
              },
            ),
            Divider(),
            // add a horizontal line between each item in the list
            ListTile(
              leading: Icon(Icons.list),
              title: Text('작성한 의뢰 목록'),
              onTap: () {
                // navigate to the page showing the list of requests created by the user
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('진행한 의뢰 목록'),
              onTap: () {
                // navigate to the page showing the list of requests the user has worked on
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
