import 'package:flutter/material.dart';

class GoogleSignInWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var assetsImage = new AssetImage('google_signin_buttons/web/1x/btn_google_signin_light_normal_web.png');
    var image = new Image(image: assetsImage, fit: BoxFit.cover,);
    return image;
  }
}