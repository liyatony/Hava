import 'package:flutter/material.dart';
import 'package:hava/pages/search/location_weather_page.dart';
import 'package:hava/services/external_weather_service.dart';


class SearchLocation extends StatefulWidget {
  final ExternalWeatherService weatherService;

  const SearchLocation({
    Key? key,
    required this.weatherService,
  }) : super(key: key);

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation controller for smooth transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Load initial random cities
    _loadInitialCities();
  }

  void _loadInitialCities() async {
    setState(() {
      _isSearching = true;
    });
    
    final cities = await widget.weatherService.searchCities('');
    
    setState(() {
      _searchResults = cities;
      _isSearching = false;
    });
  }

  void _onSearch(String query) async {
    setState(() {
      _isSearching = true;
    });
    
    // Add a small delay to make the search feel more responsive
    // and avoid excessive API calls while typing
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (_searchController.text == query) {
        final results = await widget.weatherService.searchCities(query);
        
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectCity(String cityName) async {
    setState(() {
      _isSearching = true;
    });
    
    final weather = await widget.weatherService.getWeatherByCity(cityName);
    
    if (mounted) {
      setState(() {
        _isSearching = false;
      });
      
      if (weather.isNotEmpty) {
        // Add a smooth transition when navigating
        _animationController.reverse().then((_) {
          Navigator.pop(context);
          Navigator.push(
            context, 
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => LocationWeatherPage(
                weatherData: weather,
                weatherService: widget.weatherService,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                
                return SlideTransition(position: offsetAnimation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          // Prevent a RenderOverflow by setting a minimum height
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            minHeight: 200,
          ),
          height: MediaQuery.of(context).size.height * 0.6 * _animation.value,
          decoration: const BoxDecoration(
            color: Color(0xFFF6EDFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull handle indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Search for a city',
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF2E004E),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                      ),
                      autofocus: true, // Auto-focus for immediate typing
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _animationController.reverse().then((_) {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(
                    color: Color(0xFF2E004E),
                  ))
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _searchResults.isEmpty
                        ? const Center(
                            child: Text(
                              "No cities found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E004E),
                              ),
                            ),
                          )
                        : ListView.builder(
                            key: ValueKey<int>(_searchResults.length),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final city = _searchResults[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF2E004E),
                                ),
                                title: Text(city['name'] ?? ''),
                                subtitle: Text(city['country'] ?? ''),
                                onTap: () => _selectCity(city['name'] ?? ''),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}