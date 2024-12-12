import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/firebase_options.dart';
import 'package:fitness/login/forgotpassword.dart'; // Ensure this file exists and is correctly named
import 'package:fitness/login/profilepage.dart';
import 'package:fitness/screens/home_screen/admin_panel.dart';
import 'package:fitness/screens/profilepage/basic_plan.dart';
import 'package:fitness/screens/profilepage/premium_plans.dart';
import 'package:fitness/setting_categories.dart/services/sleep_tracker.dart';
import 'package:fitness/tip/tips_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness/screens/OnboardingScreen/on_boarding_view.dart';
import 'package:fitness/screens/activityscreen/activityscreen.dart';
import 'package:fitness/screens/agescreen/agescreen.dart';
import 'package:fitness/screens/genderscreen/gender_screen.dart';
import 'package:fitness/screens/goalscreen/goalscreen.dart';
import 'package:fitness/screens/heightscreen/heightscreen.dart';
import 'package:fitness/screens/home_screen/bottom_navigationbar.dart';
import 'package:fitness/screens/home_screen/home_screen.dart';
import 'package:fitness/screens/home_screen/notifications.dart';
import 'package:fitness/screens/home_screen/workout_progress.dart';
import 'package:fitness/login/sign_page.dart';
import 'package:fitness/login/login_page.dart';

import 'package:fitness/screens/profilepage/privacy_policy.dart';
import 'package:fitness/screens/profilepage/settings_page.dart';
import 'package:fitness/screens/profilepage/subscription.dart';
import 'package:fitness/screens/weightscreen/weight_screen.dart';
import 'package:fitness/screens/workoutcategories/workout_categories.dart';
import 'package:fitness/setting_categories.dart/contact.dart';

import 'package:fitness/setting_categories.dart/unit.dart';
import 'package:fitness/screens/profilepage/UserProvider.dart'; // Make sure this path is correct
import 'package:get/get.dart';
import 'controller/auth_controller.dart'; // Adjust the import to your controller's path
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  // Initialize the AuthController
  Get.put(AuthController());

  // Configure ChannelBuffers
  ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler('flutter/lifecycle', (message) async {
    // Handle lifecycle messages
    return null;
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Ensure GetMaterialApp is used
      color: Colors.black,
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/gender': (context) => const GenderPage(),
        '/age': (context) => const Agescreen(),
        '/weight': (context) => const WeightScreen(),
        '/height': (context) => const Heightscreen(),
        '/goal': (context) => const Goalscreen(),
        '/activity': (context) => const Activityscreen(),
        '/sign': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const AdminHomeScreen(),
        '/notifications': (context) => const NotificationPage(),
        '/workoutCategories': (context) => const WorkoutCategories(),
        '/bottomNavigationbar': (context) => const HomepageNavbar(),
        '/admin': (context) => const AdminPage(),
      
        '/profile': (context) => const ProfilePage(),
        
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/settings': (context) => const SettingsPage(),
        '/unit': (context) => const UnitOfMeasureForm(),
        
        '/contact': (context) => const ContactUsPage(),
        '/basic': (context) => const BasicPlanPage(),
        '/premium': (context) => const PremiumPlanPage(),
        '/subscription': (context) => const SubscriptionPage(),
        '/workoutprogress': (context) => const WorkoutProgress(),
        '/tips': (context) => const TipsView(),
        '/sleep': (context) => const SleepTrackerHome(),
      },
      debugShowCheckedModeBanner: false,
      home: Obx(() {
        final authController = Get.find<AuthController>();
        return authController.isLoggedIn.value ? const HomepageNavbar() : const LoginPage();
      }),
    );
  }
}
