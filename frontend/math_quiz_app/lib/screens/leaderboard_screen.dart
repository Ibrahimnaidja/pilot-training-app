import 'package:flutter/material.dart';

import '../services/api_client.dart';

class LeaderboardScreen extends StatefulWidget {
  final ApiClient api;
  const LeaderboardScreen({super.key, required this.api});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry>? _entries;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await widget.api.fetchLeaderboard();
      if (!mounted) return;
      setState(() => _entries = entries);
    } catch (e) {
      if (mounted) setState(() => _error = "Couldn't load the leaderboard.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red.shade700)))
              : _entries == null
                  ? const Center(child: CircularProgressIndicator())
                  : _entries!.isEmpty
                      ? const Center(child: Text('No one has a streak yet — be the first!'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _entries!.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = _entries![index];
                            final isMe = entry.username == widget.api.username;
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(
                                entry.username,
                                style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
                              ),
                              subtitle: Text('${entry.totalCorrect}/${entry.totalAttempts} correct'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${entry.bestStreak}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('best streak', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
