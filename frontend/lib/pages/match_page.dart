// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<Match> matches = [];
List<Team> teams = [];

Team? selectedTeam1;
Team? selectedTeam2;
String? matchDate;
String? matchScore1;
String? matchScore2;

class Match {
  int? id;
  Team team1;
  Team team2;
  String date;
  int? score1;
  int? score2;

  Match({
    this.id,
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
    fetchTeams().then((_) {
      setState(() {}); // Update the UI after fetching teams
    });
    fetchMatches().then((_) {
      matches = sortMatchesByDate(matches);
      setState(() {}); // Update the UI after fetching matches
    });
  }

  Future<void> fetchTeams() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/teams'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        teams =
            jsonData
                .map((team) => Team(team['id'], team['team_name']))
                .toList();
      } else {
        throw Exception(
          'Failed to load teams. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  Future<void> fetchMatches() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/matches'),
      );
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
                  return Match(
                    id: match['id'],
                    team1:
                        getTeamByTeamId(match['team_id1']) ??
                        Team(0, 'Unknown Team'),
                    team2:
                        getTeamByTeamId(match['team_id2']) ??
                        Team(0, 'Unknown Team'),
                    date: match['match_day'],
                    score1: match['set_score1'],
                    score2: match['set_score2'],
                  );
                })
                .whereType<Match>() // Entferne `null`-Einträge aus der Liste
                .toList();
      } else {
        throw Exception(
          'Failed to load matches. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  Future<void> addMatch(Match match) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/matches'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'team_id1': selectedTeam1?.id.toString() ?? '0',
          'team_id2': selectedTeam2?.id.toString() ?? '0',
          'match_day': matchDate ?? 'Unknown Date',
          'set_score1': matchScore1 ?? '0',
          'set_score2': matchScore2 ?? '0',
        }),
      );

      if (response.statusCode == 201) {
        print('Match added successfully');
      } else {
        throw Exception(
          'Failed to add match. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error adding match: $e');
    }
  }

  Team? getTeamByTeamId(int teamId) {
    for (var team in teams) {
      if (team.id == teamId) {
        return team;
      }
    }
    return null; // Team not found
  }

  // Format the date from "2025-08-10T22:00:00.000Z" to DD.MM.YYYY
  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final String formattedDate =
        '${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}';
    return formattedDate;
  }

  List<Match> sortMatchesByDate(List<Match> matches) {
    matches.sort((a, b) {
      final DateTime dateA = DateTime.parse(a.date);
      final DateTime dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA);
    });
    return matches;
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
                matches[index].score1 != null && matches[index].score2 != null
                    ? '${matches[index].team1.name} vs ${matches[index].team2.name} (${matches[index].score1} : ${matches[index].score2})'
                    : '${matches[index].team1.name} vs ${matches[index].team2.name}',
              ),
              subtitle: Text(formatDate(matches[index].date)),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Match Date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    print(pickedDate);
                    matchDate =
                        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  });
                }
              },
              controller: TextEditingController(
                text: matchDate != null ? formatDate(matchDate!) : '',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Team>(
              decoration: const InputDecoration(
                labelText: 'Team 1',
                border: OutlineInputBorder(),
              ),
              items:
                  teams.map((team) {
                    return DropdownMenuItem<Team>(
                      value: team,
                      child: Text(team.name),
                    );
                  }).toList(),
              onChanged: (value) {
                selectedTeam1 = value;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Team>(
              decoration: const InputDecoration(
                labelText: 'Team 2',
                border: OutlineInputBorder(),
              ),
              items:
                  teams.map((team) {
                    return DropdownMenuItem<Team>(
                      value: team,
                      child: Text(team.name),
                    );
                  }).toList(),
              onChanged: (value) {
                selectedTeam2 = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Score 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                matchScore1 = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Score 2',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                matchScore2 = value;
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (selectedTeam1 == null ||
              selectedTeam2 == null ||
              matchDate == "" ||
              matchDate == null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Please fill the required fields.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            print('Please fill the required fields.');
            return;
          } else {
            addMatch(
              Match(
                team1: selectedTeam1 ?? Team(0, 'Unknown Team'),
                team2: selectedTeam2 ?? Team(0, 'Unknown Team'),
                date: matchDate ?? 'Unknown Date',
              ),
            ).then((_) {
              fetchMatches().then((_) {
                // Fetch matches again to update the list
                matches = sortMatchesByDate(matches);
                setState(() {}); // Update the UI after adding a match
              });
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
