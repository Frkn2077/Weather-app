import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherResultScreen extends StatefulWidget {
  final String cityName;

  const WeatherResultScreen({super.key, required this.cityName});

  @override
  State<WeatherResultScreen> createState() => _WeatherResultScreenState();
}

class _WeatherResultScreenState extends State<WeatherResultScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  String? errorMessage;
  final String apiKey = 'deneme key';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url =
    "https://api.openweathermap.org/data/2.5/weather?q=${widget.cityName}&appid=$apiKey&units=metric&lang=tr";

      print('API isteği gönderiliyor: $url'); // Debug için
      
      final response = await http.get(Uri.parse(url));
      
      print('Yanıt kodu: ${response.statusCode}'); // Debug için
      print('Yanıt gövdesi: ${response.body}'); // Debug için
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          isLoading = false;
          weatherData = null;
          errorMessage = errorData['message'] ?? 'Bilinmeyen hata oluştu';
        });
      }
    } catch (e) {
      print('Hata: $e'); // Debug için
      setState(() {
        isLoading = false;
        weatherData = null;
        errorMessage = 'Bağlantı hatası: ${e.toString()}';
      });
    }
  }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherColor(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFFB74D);
      case 'clouds':
        return const Color(0xFF90A4AE);
      case 'rain':
      case 'drizzle':
        return const Color(0xFF42A5F5);
      case 'thunderstorm':
        return const Color(0xFF5C6BC0);
      case 'snow':
        return const Color(0xFFE1F5FE);
      default:
        return const Color(0xFF74C0FC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.cityName} Hava Durumu",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchWeather,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF74C0FC)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Hava durumu verisi yükleniyor...',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            )
          : weatherData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Veri Alınamadı',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage ?? 'Bilinmeyen hata oluştu',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: fetchWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF74C0FC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Ana hava durumu kartı
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getWeatherColor(weatherData!['weather'][0]['main']),
                              _getWeatherColor(weatherData!['weather'][0]['main']).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _getWeatherColor(weatherData!['weather'][0]['main']).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getWeatherIcon(weatherData!['weather'][0]['main']),
                              size: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${weatherData!['main']['temp'].round()}°C",
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              weatherData!['weather'][0]['description'],
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Hissedilen: ${weatherData!['main']['feels_like'].round()}°C",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Detay bilgileri
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.water_drop,
                              title: 'Nem',
                              value: '${weatherData!['main']['humidity']}%',
                              color: const Color(0xFF42A5F5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.air,
                              title: 'Rüzgar',
                              value: '${weatherData!['wind']['speed']} m/s',
                              color: const Color(0xFF66BB6A),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.compress,
                              title: 'Basınç',
                              value: '${weatherData!['main']['pressure']} hPa',
                              color: const Color(0xFFAB47BC),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailCard(
                              icon: Icons.visibility,
                              title: 'Görüş',
                              value: weatherData!['visibility'] != null 
                                  ? '${(weatherData!['visibility'] / 1000).toStringAsFixed(1)} km'
                                  : 'N/A',
                              color: const Color(0xFFFF7043),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B3B5C),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
