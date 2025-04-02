// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<Match> matches = [];

class Match {
  int id;
  Team team1;
  Team team2;
  String date;
  int? score1;
  int? score2;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    required this.date,
    this.score1,
    this.score2,
  });
}

class Team {
  // Eigenschaften (Felder)
  int id;
  String name;
  //image

  // Konstruktor
  Team(this.id, this.name);
}

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  void initState() {
    super.initState();
    fetchMatches().then((_) {
      setState(() {}); // Update the UI after fetching matches
    });
  }

  Future<void> fetchMatches() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/matches'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        matches =
            jsonData
                .map((match) {
                  // Überprüfe, ob die Felder vorhanden sind
                  if (match['team_id1'] == null || match['team_id2'] == null) {
                    print('Fehler: Team-Daten fehlen in der API-Antwort.');
                    return null; // Überspringe ungültige Einträge
                  }

                  final team1 = Team(
                    match['team_id1'] ?? 0, // Fallback-Wert, falls 'id' fehlt
                    "Real Madrid",
                  );
                  final team2 = Team(match['team_id2'] ?? 0, "Bayern");

                  return Match(
                    id: match['id'] ?? 0, // Fallback-Wert
                    team1: team1,
                    team2: team2,
                    date: match['match_day'] ?? 'Unknown Date', // Fallback-Wert
                    score1: match['score1'] ?? 0, // Fallback-Wert
                    score2: match['score2'] ?? 0, // Fallback-Wert
                  );
                })
                .whereType<Match>()
                .toList(); // Entferne `null`-Einträge aus der Liste

        print(matches);
      } else {
        throw Exception(
          'Failed to load matches. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Page')),
      body: Center(
        child: ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                '${matches[index].team1.name} vs ${matches[index].team2.name}',
              ),
              subtitle: Text(matches[index].date),
            );
          },
        ),
      ),
    );
  }
}
