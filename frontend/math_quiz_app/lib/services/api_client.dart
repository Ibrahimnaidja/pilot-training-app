import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/logic_puzzle.dart';

// For a deployed build, pass the real backend URL at build time:
//   flutter build web --dart-define=API_BASE_URL=https://your-backend.onrender.com
const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

String get _defaultBaseUrl {
  if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5080';
  }
  return 'http://localhost:5080';
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class Problem {
  final String id;
  final int num1;
  final int num2;
  final String operatorSymbol;
  final String displayExpression;
  final String createdByUsername;

  Problem({
    required this.id,
    required this.num1,
    required this.num2,
    required this.operatorSymbol,
    required this.displayExpression,
    required this.createdByUsername,
  });

  factory Problem.fromJson(Map<String, dynamic> json) => Problem(
        id: json['id'] as String,
        num1: json['num1'] as int,
        num2: json['num2'] as int,
        operatorSymbol: json['operator'] as String,
        displayExpression: json['displayExpression'] as String,
        createdByUsername: json['createdByUsername'] as String,
      );
}

class Stats {
  final int currentStreak;
  final int bestStreak;
  final int totalCorrect;
  final int totalAttempts;

  Stats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCorrect,
    required this.totalAttempts,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        currentStreak: json['currentStreak'] as int,
        bestStreak: json['bestStreak'] as int,
        totalCorrect: json['totalCorrect'] as int,
        totalAttempts: json['totalAttempts'] as int,
      );
}

class LeaderboardEntry {
  final String username;
  final int bestStreak;
  final int totalCorrect;
  final int totalAttempts;

  LeaderboardEntry({
    required this.username,
    required this.bestStreak,
    required this.totalCorrect,
    required this.totalAttempts,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        username: json['username'] as String,
        bestStreak: json['bestStreak'] as int,
        totalCorrect: json['totalCorrect'] as int,
        totalAttempts: json['totalAttempts'] as int,
      );
}

/// Handles talking to the backend and persisting the auth token between
/// app launches (SharedPreferences — fine for a personal-project JWT;
/// swap for flutter_secure_storage if this ever needs to be hardened).
class ApiClient {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  String baseUrl;
  String? token;
  String? username;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    username = prefs.getString(_usernameKey);
  }

  Future<void> _saveSession(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    this.token = token;
    this.username = username;
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    token = null;
    username = null;
  }

  bool get isLoggedIn => token != null;

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<void> register(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not create account'));
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveSession(data['token'] as String, data['username'] as String);
  }

  Future<void> logIn(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Incorrect username or password'));
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _saveSession(data['token'] as String, data['username'] as String);
  }

  Future<Problem> fetchRandomProblem() async {
    final res = await http.get(Uri.parse('$baseUrl/api/problems/random'), headers: _authHeaders);
    if (res.statusCode == 404) {
      throw ApiException('No problems exist yet — create one first.');
    }
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not load a problem'));
    }
    return Problem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Problem> createProblem(int num1, int num2, String operatorName) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/problems'),
      headers: _authHeaders,
      body: jsonEncode({'num1': num1, 'num2': num2, 'operator': operatorName}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not create problem'));
    }
    return Problem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Problem> updateProblem(String id, int num1, int num2, String operatorName) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/problems/$id'),
      headers: _authHeaders,
      body: jsonEncode({'num1': num1, 'num2': num2, 'operator': operatorName}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not update problem'));
    }
    return Problem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteProblem(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/problems/$id'), headers: _authHeaders);
    if (res.statusCode != 204) {
      throw ApiException(_extractError(res, 'Could not delete problem'));
    }
  }

  Future<List<Problem>> fetchMyProblems() async {
    final res = await http.get(Uri.parse('$baseUrl/api/problems/mine'), headers: _authHeaders);
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not load your problems'));
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Problem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Submits an answer (or a timeout). Returns updated stats plus whether it
  /// was correct and what the right answer was.
  Future<Map<String, dynamic>> submitAttempt({
    required String problemId,
    int? answer,
    bool timedOut = false,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/attempts'),
      headers: _authHeaders,
      body: jsonEncode({'problemId': problemId, 'answer': answer, 'timedOut': timedOut}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not submit answer'));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Stats> fetchStats() async {
    final res = await http.get(Uri.parse('$baseUrl/api/me/stats'), headers: _authHeaders);
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not load stats'));
    }
    return Stats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Stats> submitLogicAttempt(LogicCategory category, bool correct) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/logic/attempts'),
      headers: _authHeaders,
      body: jsonEncode({'category': category.apiValue, 'correct': correct}),
    );
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not submit answer'));
    }
    return Stats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Stats> fetchLogicStats() async {
    final res = await http.get(Uri.parse('$baseUrl/api/logic/stats'), headers: _authHeaders);
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not load stats'));
    }
    return Stats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final res = await http.get(Uri.parse('$baseUrl/api/leaderboard'), headers: _authHeaders);
    if (res.statusCode != 200) {
      throw ApiException(_extractError(res, 'Could not load leaderboard'));
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _extractError(http.Response res, String fallback) {
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['error'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
