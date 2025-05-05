import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hava/services/env_service.dart';

class WeatherNewsScreen extends StatefulWidget {
  const WeatherNewsScreen({super.key});

  @override
  State<WeatherNewsScreen> createState() => _WeatherNewsScreenState();
}

class _WeatherNewsScreenState extends State<WeatherNewsScreen> {
  List<Map<String, dynamic>> newsItems = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasReachedMax = false;
  final ScrollController _scrollController = ScrollController();
  int totalNewsGenerated = 0;

  @override
  void initState() {
    super.initState();
    fetchNews(7); // Fetch initial 7 news items
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore && !hasReachedMax) {
      fetchMoreNews();
    }
  }

  String cleanText(String text) {
    return text.replaceAll('*', '').trim();
  }
  
  // Method to determine weather icon based on content
  IconData getWeatherIcon(String headline, String description) {
    final combinedText = (headline + ' ' + description).toLowerCase();
    
    if (combinedText.contains('thunder') || combinedText.contains('lightning') || combinedText.contains('storm')) {
      return Icons.bolt;
    } else if (combinedText.contains('rain') || combinedText.contains('shower') || combinedText.contains('precipitat')) {
      return Icons.water_drop;
    } else if (combinedText.contains('snow') || combinedText.contains('blizzard') || combinedText.contains('frost')) {
      return Icons.ac_unit;
    } else if (combinedText.contains('cloud')) {
      return Icons.cloud;
    } else if (combinedText.contains('fog') || combinedText.contains('mist') || combinedText.contains('haz')) {
      return Icons.cloud_queue;
    } else if (combinedText.contains('wind') || combinedText.contains('gust')) {
      return Icons.air;
    } else if (combinedText.contains('sun') || combinedText.contains('clear') || combinedText.contains('hot')) {
      return Icons.wb_sunny;
    } else if (combinedText.contains('flood') || combinedText.contains('tsunami')) {
      return Icons.warning_amber;
    } else if (combinedText.contains('heat') || combinedText.contains('warm')) {
      return Icons.thermostat;
    } else if (combinedText.contains('cold') || combinedText.contains('chill') || combinedText.contains('freez')) {
      return Icons.ac_unit;
    } else if (combinedText.contains('hurricane') || combinedText.contains('typhoon') || combinedText.contains('cyclon')) {
      return Icons.cyclone;
    } else {
      return Icons.cloud_circle; // Default icon
    }
  }
  
  // Method to determine icon color based on content
  Color getIconColor(String headline, String description) {
    final combinedText = (headline + ' ' + description).toLowerCase();
    
    if (combinedText.contains('thunder') || combinedText.contains('lightning') || combinedText.contains('warning') || 
        combinedText.contains('danger') || combinedText.contains('severe')) {
      return Colors.orange;
    } else if (combinedText.contains('rain') || combinedText.contains('shower')) {
      return Colors.blue;
    } else if (combinedText.contains('snow') || combinedText.contains('cold') || combinedText.contains('freez')) {
      return Colors.lightBlue;
    } else if (combinedText.contains('cloud')) {
      return Colors.grey;
    } else if (combinedText.contains('sun') || combinedText.contains('clear') || combinedText.contains('hot')) {
      return Colors.amber;
    } else {
      return const Color(0xFF9E77E9); // Default theme color
    }
  }

  Future<void> fetchNews(int count) async {
    // Use the API key from the environment file
    final apiKey = EnvService.geminiApiKey;
    
    // Updated to use gemini-2.0-flash model which is available in the current API version
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );

    try {
      final prompt = 'Generate $count concise weather updates. Each update should have a bold headline and a description of 4-5 sentences. Do not number the updates or explicitly label headlines.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final newsText = response.text ?? '';
      if (newsText.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }
      
      final newsEntries = newsText.split('\n\n');

      setState(() {
        newsItems.addAll(newsEntries.map((entry) {
          final parts = entry.split('.');
          String headline = parts.isNotEmpty ? cleanText(parts[0]) : 'Weather Update';
          String description = parts.length > 1 ? cleanText(parts.sublist(1).join('.')) : '';
          
          return {
            'headline': headline,
            'description': description,
            // Add icon and color data
            'icon': getWeatherIcon(headline, description),
            'iconColor': getIconColor(headline, description),
          };
        }).where((item) => 
  item['headline'] != null && 
  item['headline'] is String && 
  (item['headline'] as String).isNotEmpty && 
  item['description'] != null && 
  item['description'] is String && 
  (item['description'] as String).isNotEmpty
));
        totalNewsGenerated += count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching news: $e');
      
      // Add a fallback news item if the API fails
      if (newsItems.isEmpty) {
        setState(() {
          newsItems.add({
            'headline': 'Weather Updates Currently Unavailable',
            'description': 'We\'re experiencing some technical difficulties with our weather news service. Please check back later for the latest weather updates and news.',
            'icon': Icons.cloud_off,
            'iconColor': Colors.grey,
          });
        });
      }
    }
  }

  Future<void> fetchMoreNews() async {
    if (isLoadingMore || hasReachedMax || totalNewsGenerated >= 18) {
      setState(() {
        hasReachedMax = true;
      });
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    final count = 5;
    await fetchNews(count);

    setState(() {
      isLoadingMore = false;
      if (totalNewsGenerated >= 18) {
        hasReachedMax = true;
      }
    });
  }

  Future<void> _refreshNews() async {
    setState(() {
      newsItems = [];
      isLoading = true;
      isLoadingMore = false;
      hasReachedMax = false;
      totalNewsGenerated = 0;
    });
    
    await fetchNews(7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EDFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFFF6EDFF),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Weather Updates',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D3FA),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9E77E9).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF6942B6),
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? _buildSkeletonLoading()
          : RefreshIndicator(
              onRefresh: _refreshNews,
              backgroundColor: Colors.white,
              color: const Color(0xFF9E77E9),
              strokeWidth: 3.0,
              edgeOffset: 20.0,
              displacement: 50.0,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: newsItems.length + (isLoadingMore ? 1 : 0) + (hasReachedMax ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == newsItems.length) {
                    if (isLoadingMore) {
                      return _buildLoadingMoreIndicator();
                    } else if (hasReachedMax) {
                      return _buildNoMoreUpdatesIndicator();
                    }
                  }

                  if (index >= newsItems.length) {
                    return null;
                  }

                  final newsItem = newsItems[index];
                  return _buildNewsCard(newsItem);
                },
              ),
            ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 7, // Show 7 skeleton items
      itemBuilder: (context, index) {
        return Shimmer(
          child: NewsCardSkeleton(),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          color: Color(0xFF9E77E9),
        ),
      ),
    );
  }

  Widget _buildNoMoreUpdatesIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEADDFF),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9E77E9).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: const Text(
            'No more updates available',
            style: TextStyle(
              color: Color(0xFF6942B6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> newsItem) {
    final IconData icon = newsItem['icon'] ?? Icons.cloud_circle;
    final Color iconColor = newsItem['iconColor'] ?? const Color(0xFF9E77E9);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF0E4FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E77E9).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Add functionality if needed
          borderRadius: BorderRadius.circular(22),
          splashColor: const Color(0xFFD0BCFF).withOpacity(0.3),
          highlightColor: const Color(0xFFD0BCFF).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        newsItem['headline'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  newsItem['description'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 16,
                    height: 1.4,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer effect widget for skeleton loading
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Updated News Card Skeleton for loading state (now with icon placeholder)
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0E4FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E77E9).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}