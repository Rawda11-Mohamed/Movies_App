import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/shared_prefs_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
      gradientColors: [Colors.black87, Colors.black54],
    ),
    _OnboardingData(
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
      gradientColors: [Colors.black87, Colors.black54],
    ),
    _OnboardingData(
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
      gradientColors: [Colors.black87, Colors.black54],
    ),
    _OnboardingData(
      title: AppStrings.onboarding4Title,
      description: AppStrings.onboarding4Desc,
      gradientColors: [Colors.black87, Colors.black54],
    ),
    _OnboardingData(
      title: AppStrings.onboarding5Title,
      description: AppStrings.onboarding5Desc,
      gradientColors: [Colors.black87, Colors.black54],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPrefsHelper.getInstance();
    await prefs.setHasSeenOnboarding(true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: _pages[index], pageIndex: index);
            },
          ),
          _buildBottomOverlay(),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay() {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == _pages.length - 1;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87, Colors.black],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(
                  isLast
                      ? AppStrings.startWatchingNow
                      : isFirst
                          ? AppStrings.exploreNow
                          : AppStrings.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isFirst) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _prevPage,
                  child: const Text(AppStrings.back),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final int pageIndex;

  const _OnboardingPage({required this.data, required this.pageIndex});

  // Movie poster colors to simulate backdrop (since no actual images yet)
  static const List<List<Color>> _pageColors = [
    [Color(0xFF1a1a2e), Color(0xFF16213e)],
    [Color(0xFF0f3460), Color(0xFF533483)],
    [Color(0xFF2d132c), Color(0xFF1a1a2e)],
    [Color(0xFF0d7377), Color(0xFF14274e)],
    [Color(0xFF2c3e50), Color(0xFF4ca1af)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _pageColors[pageIndex % _pageColors.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.movie_creation_outlined,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final List<Color> gradientColors;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}
