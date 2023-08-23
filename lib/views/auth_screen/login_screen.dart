import 'package:zaisystems/consts/imports.dart';
import 'package:zaisystems/controllers/app_routes.dart';
import 'package:zaisystems/services/firebase_services/firebase_service.dart';
import 'package:zaisystems/utils/snackbar.dart';
import 'package:zaisystems/widget_common/bg_widget.dart';
import 'package:zaisystems/widget_common/custom_button.dart';
import 'package:zaisystems/widget_common/custom_textfield.dart';
import 'package:zaisystems/widget_common/dialog_boxs.dart';
import 'package:zaisystems/widget_common/loading/loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService.instance();
  final loader = LoadingScreen.instance();
  bool passVis = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showSnack({required String message}) => showSnackbar(
        context: context,
        message: message,
      );

  void showError({required String message, required String title}) =>
      errorDialogue(
        context: context,
        message: message,
        title: title,
      );

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      loader.show(context: context, text: "Please wait...", title: "Login-in");
      try {
        final email = _emailController.text.toLowerCase().trim();
        final password = _passwordController.text;

        final response = await FirebaseService.instance()
            .signInWithEmailPassword(email: email, password: password);
        handleResponse(response);
      } catch (e) {
        loader.hide();
        showError(message: e.toString(), title: "Error");
      }
    }
  }

  void googleSignIn() async {
    loader.show(context: context, text: "Please wait...", title: "Login-in");
    try {
      final response = await _firebaseService.signInWithGoogle();
      handleResponse(response);
    } catch (e) {
      showError(message: e.toString(), title: "Error");
    }
  }

  void handleResponse(final response) async {
    loader.hide();
    if (response != null) {
      showError(message: response.dialogText, title: response.dialogTitle);
    } else {
      showSnack(message: "Login Successfully");
      await Get.offAllNamed(AppRoutes.drawerScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              "Welcome Back".text.bold.white.size(20).make(),
              5.heightBox,
              "Log In!".text.bold.white.size(46).make(),
              (context.screenHeight * 0.2).heightBox,
              customTextField(
                controller: _emailController,
                hint: email,
              ),
              12.heightBox,
              customTextField(
                controller: _passwordController,
                hint: password,
                obsecure: !passVis,
                onPress: () => setState(() => passVis = !passVis),
                suffixIcon: passVis ? Icons.visibility : Icons.visibility_off,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(forgetPassword),
                ),
              ),
              customButton(
                onPress: loginUser,
                title: login,
                btnColor: mehroonColor,
                textColor: whiteColor,
              ).box.width(context.screenWidth - 50).make(),
              8.heightBox,
              Align(
                alignment: Alignment.center,
                child: createNewAccount.text
                    .color(fontGrey)
                    .fontFamily(semibold)
                    .make(),
              ),
              8.heightBox,
              customButton(
                onPress: () => Get.toNamed(AppRoutes.signUpScreen),
                title: signup,
                btnColor: lightGolden,
                textColor: mehroonColor,
              ).box.width(context.screenWidth - 50).make(),
              5.heightBox,
              Align(
                alignment: Alignment.center,
                child:
                    loginWith.text.color(fontGrey).fontFamily(semibold).make(),
              ),
              5.heightBox,
              socialBtns(),
            ],
          )
              .box
              .padding(const EdgeInsets.symmetric(horizontal: 30))
              .margin(
                EdgeInsets.only(top: context.screenHeight * 0.1, bottom: 20),
              )
              .make(),
        ),
      ).onTap(() {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }),
    );
  }

  Row socialBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        socialButton(onClick: () {}, icon: socialIconList[0]),
        socialButton(
          onClick: googleSignIn,
          icon: socialIconList[1],
        ),
        socialButton(onClick: () {}, icon: socialIconList[2]),
      ],
    );
  }

  Widget socialButton({Function()? onClick, required String icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: lightGrey,
        radius: 25,
        child: Image.asset(
          icon,
          width: 30,
        ),
      ),
    ).onTap(onClick);
  }
}
