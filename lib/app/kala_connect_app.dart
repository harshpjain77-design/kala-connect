import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/home/home_screen.dart';
import '../features/auth/phone_auth_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/product/product_template.dart';
import '../services/audio_insight_service.dart';
import '../services/edge_pipeline_service.dart';
import '../services/device_capture_service.dart';
import '../services/image_analysis_service.dart';
import '../services/voice_assistant_service.dart';
import '../data/auth/auth_repository.dart';
import '../data/auth/demo_auth_repository.dart';
import '../data/auth/firebase_auth_repository.dart';
import '../data/products/firebase_product_repository.dart';
import '../data/products/local_product_repository.dart';
import '../data/products/product_repository.dart';
import '../data/profile/firebase_profile_repository.dart';
import '../data/profile/local_profile_repository.dart';
import '../data/profile/profile_repository.dart';
import '../state/app_flow_controller.dart';
import '../state/auth_controller.dart';
import '../state/product_controller.dart';
import '../state/voice_controller.dart';
import '../theme/kala_theme.dart';

/// Global application shell. All copy is intentionally short because the
/// product is designed to be usable through visuals and voice guidance.
class KalaConnectApp extends StatelessWidget {
  const KalaConnectApp({required this.firebaseReady, super.key});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => firebaseReady ? FirebaseAuthRepository() : DemoAuthRepository(),
        ),
        Provider<ProductRepository>(
          create: (_) => firebaseReady ? FirebaseProductRepository() : LocalProductRepository(),
        ),
        Provider<ProfileRepository>(
          create: (_) => firebaseReady ? FirebaseProfileRepository() : LocalProfileRepository(),
        ),
        Provider<EdgePipelineService>(create: (_) => EdgePipelineService()),
        Provider<DeviceCaptureService>(create: (_) => DeviceCaptureService()),
        Provider<ImageAnalysisService>(create: (_) => ImageAnalysisService()),
        Provider<AudioInsightService>(create: (_) => AudioInsightService()),
        Provider<VoiceAssistantService>(create: (_) => VoiceAssistantService()),
        ChangeNotifierProvider<AppFlowController>(
          create: (context) => AppFlowController(context.read<ProfileRepository>()),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(context.read<AuthRepository>())..start(),
        ),
        ChangeNotifierProvider<ProductController>(
          create: (context) => ProductController(context.read<ProductRepository>()),
        ),
        ChangeNotifierProvider<VoiceController>(
          create: (context) => VoiceController(
            assistant: context.read<VoiceAssistantService>(),
            insights: context.read<AudioInsightService>(),
            products: context.read<ProductController>(),
            appFlow: context.read<AppFlowController>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'कला connect',
        debugShowCheckedModeBanner: false,
        theme: KalaTheme.light(),
        home: const ViewportSafetyGate(child: _AppRouter()),
      ),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  String? _bindingUserId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.phase == AuthPhase.loading) return const ColoredBox(color: KalaColors.ink);
    if (!auth.isSignedIn) {
      context.read<AppFlowController>().unbindArtisan();
      return context.watch<AppFlowController>().entryStage == EntryStage.authentication
          ? const PhoneAuthScreen()
          : const LandingScreen();
    }
    final appFlow = context.watch<AppFlowController>();
    final userId = auth.identity!.uid;
    if (!appFlow.isBoundTo(userId)) {
      if (_bindingUserId != userId) {
        _bindingUserId = userId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<AppFlowController>().bindArtisan(userId);
        });
      }
      return const ColoredBox(color: KalaColors.ink);
    }
    _bindingUserId = null;
    if (appFlow.isLoadingProfile) return const ColoredBox(color: KalaColors.ink);
    if (!appFlow.isOnboarded) return const OnboardingFlow();
    if (context.watch<ProductController>().product != null) return const ProductDetailsView();
    return const HomeScreen();
  }
}

/// Prevents expensive animation trees from being built during the first frame
/// when a platform briefly reports a zero-width viewport.
class ViewportSafetyGate extends StatelessWidget {
  const ViewportSafetyGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width == 0) {
      return const ColoredBox(color: KalaColors.ink);
    }
    return child;
  }
}
