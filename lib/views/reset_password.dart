import 'package:flutter/material.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';

class ResetPwdView extends StatefulWidget {
  const ResetPwdView({super.key});

  @override
  State<ResetPwdView> createState() => _ResetPwdViewState();
}

const String pwdLengthErrorHint = "密碼長度不足 4 位英/數字";
const String pwdConfirmErrorHint = "確認密碼錯誤";

class _ResetPwdViewState extends State<ResetPwdView> {

  bool showPasswordHint = false;
  bool pwdVisible = false; 
  bool confirmPwdVisible = false;
  String showErrorHint = "";
  TextEditingController pwdController = TextEditingController();
  TextEditingController confirmPwdController = TextEditingController();

  @override
  void initState(){
    super.initState();
    pwdVisible = true; 
    confirmPwdVisible = true;
    showErrorHint = "";
  }  

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    User user = obj['user'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: deviceHeight * 0.08),
            Text(
              '重設密碼',
              style: TextStyle(
                color: '#F5F5DC'.toColor(),
                fontSize: 46.0,
              )
            ),
    
            SizedBox(height: deviceHeight * 0.08),
            Visibility(
              visible: showPasswordHint,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                height: 24,
                width: 303,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  '至少4個數字',
                  style: TextStyle(
                    color: '#F5F5DC'.toColor(),
                    fontSize: 14,
                  )
                )
              )
            ),
            Container(
                height: 60.0,
                width: 303.0,
                decoration: BoxDecoration(
                    color: '#7DDEF8'.toColor(),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Focus(
                    onFocusChange: (hasFocus){
                      setState(() {
                        showPasswordHint = !showPasswordHint;
                        if (showErrorHint == pwdLengthErrorHint && pwdController.text.length >= 4){
                          showErrorHint = "";
                        }}
                      );
                    },
                    child: TextField(
                      controller: pwdController,
                      obscureText: pwdVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 30.0,
                          color: '#1C1B1F'.toColor(),
                        ),
                        hintText: '密碼',
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: '#013E6D'.toColor()
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(pwdVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              pwdVisible = !pwdVisible;
                            });
                          },
                        ),
                      )
                    ),
                  ),
                )
            ),
            SizedBox(height: deviceHeight * 0.0343),
            Container(
                height: 60.0,
                width: 303.0,
                decoration: BoxDecoration(
                    color: '#7DDEF8'.toColor(),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    controller: confirmPwdController,
                    obscureText: confirmPwdVisible,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 30.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      hintText: '確認密碼',
                      hintStyle: TextStyle(
                          fontSize: 20.0,
                          color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(confirmPwdVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            confirmPwdVisible = !confirmPwdVisible;
                          });
                        },
                      ),
                    )
                  ),
                )
            ),
            Visibility(
              visible: (showErrorHint != ""),
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                height: 24,
                width: 303,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  showErrorHint,
                  style: TextStyle(
                    color: '#F5F5DC'.toColor(),
                    fontSize: 14,
                  )
                )
              )
            ),
            SizedBox(height: deviceHeight * 0.0627),
            TextButton(
              onPressed: () {
                if (pwdController.text.length < 4){
                  setState(() {
                    showErrorHint = pwdLengthErrorHint;
                  });
                }
                else if (pwdController.text != confirmPwdController.text){
                  setState(() {
                    showErrorHint = pwdConfirmErrorHint;
                  });
                }
                else{
                  user.password = pwdController.text;
                  UserProvider.updateUser(user: user);
                  Navigator.of(context).pushNamed('/mainPage');
                }
              },
              child: Text(
                '完成',
                style: TextStyle(
                  fontSize: 24.0,
                  color: '#F5F5DC'.toColor(),
                )
              )
            )
          ]
        ),
      ),
    );
  }
}
