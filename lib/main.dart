import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:Rehla/chatbot/model/chat_model.dart';
import 'package:Rehla/chatbot/provider/ai_provider.dart';
import 'package:Rehla/chatbot/provider/future_list_provider.dart';
import 'package:Rehla/chatbot/screens/start_screen.dart';
import 'package:Rehla/login_signup/signup_view.dart';

import 'package:Rehla/screens/profile/profile_edit_screen.dart';
import 'package:Rehla/screens/splash%20screen/splash_screen.dart';
import 'package:Rehla/screens/bookings/book_tour_screen.dart';
import 'package:Rehla/theme/theme_manager.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'component/admin_navigation_bar.dart';
import 'component/navigation_bar.dart';
import 'login_signup/login_view.dart';
import 'login_signup/reset_password.dart';
import 'providers/bookings.dart';
import 'providers/tours.dart';
import 'screens/admin/admin_home.dart';
import 'screens/admin/services/add_tour.dart';
import 'screens/bookings/booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/tours/detail_screen.dart';
import 'screens/tours/favourite_screen.dart';
import 'screens/tours/home_screen.dart';
import 'theme/theme.dart';
import 'widget/isnorth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env"); // Load .env file
  
  runApp(riverpod.ProviderScope(child: MyApp()));
  
  
}

ThemeManager themeManager = ThemeManager(ThemeMode.light);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    themeManager.removeListener(themelistener);

    super.dispose();
  }

  @override
  void initState() {
    themeManager.loadTheme();
    themeManager.addListener(themelistener);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
     // final toursData = Provider.of<Tours>(context, listen: false);
      _getAllApi(context); // Call your API method here
    });
  }

  themelistener() {
    if (mounted) {
      setState(() {});
    }
  }



_getAllApi(BuildContext context) async {
    final ref = riverpod.ProviderScope.containerOf(context, listen: false);
    final List<Content> geminiList = await getGeminiHistory(); // Example API call from your chatbot app
    ref.read(geminiListProvider.notifier).updateState(geminiList);

   

    // Manually specify the API keys if required
    // ref.read(geminiKey.notifier).update((state) => 'AIzaSyA7XeCOTJJ9VtPEBiJwAqEFROkQato3Oz0');

  }






  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(430, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: Tours()),
              ChangeNotifierProvider.value(value: Bookings()),
            ],
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeManager.themeMode,
              routes: {
                SplashScreen.routeName: (ctx) => const SplashScreen(),
                HomeScreen.routeName: (ctx) => const HomeScreen(),
                BookingScreen.routeName: (ctx) =>  BookingScreen(),
                FavouriteScreen.routeName: (ctx) => const FavouriteScreen(),
                // DetailScreen.routeName: (ctx) => DetailScreen(imageUrl: [],),
                ProfileScreen.routeName: (ctx) => const ProfileScreen(),
                ProfileEditScreen.routeName: (ctx) => const ProfileEditScreen(),
                IsNorth.routeName: (ctx) => const IsNorth(true),
                //AdminHome.routeName: (context) => AdminHome(),
                AddTour.routeName: (context) => const AddTour(),
                NavigationBars.routeName: (context) => const NavigationBars(),
                LoginView.routeName: (context) =>  LoginView(),
                SignUpView.routeName: (context) => const SignUpView(),
                AdminNavigationBars.routeName: (context) =>
                    const AdminNavigationBars(),
                ResetPassword.routeName: (context) => const ResetPassword(),
                StartScreen.routeName: (context) => const StartScreen(),
                
              },
            ),
          );
        });
  }
}
