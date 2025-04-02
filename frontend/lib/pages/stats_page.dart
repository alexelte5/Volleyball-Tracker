// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

Player? selectedPlayer;

List<Team> teams = [];
List<Player> players = [];
List<Match> matches = [];

class Match {
  int id;
  String? date;
  Team team1;
  Team team2;
  int finalScoreTeam1;
  int finalScoreTeam2;

  Match(
    this.id,
    this.date,
    this.team1,
    this.team2,
    this.finalScoreTeam1,
    this.finalScoreTeam2,
  );
}

class Team {
  int id;
  String name;

  Team(this.id, this.name);
}

class Player {
  int id;
  String? firstName;
  String? lastName;
  String? birthDate;
  int? jerseyNumber;
  String? position;
  PlayerStats? playerRatings;

  Player(
    this.id,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.jerseyNumber,
    this.position,
    this.playerRatings,
  );
}

class PlayerStats {
  int playerId;
  int matchId = 1;
  Map<String, int> stats = {
    'service_pp': 0,
    'service_p': 0,
    'service_n': 0,
    'service_m': 0,
    'attack_pp': 0,
    'attack_p': 0,
    'attack_n': 0,
    'attack_m': 0,
    'block_pp': 0,
    'block_n': 0,
    'block_m': 0,
    'receive_p': 0,
    'receive_n': 0,
    'receive_m': 0,
    'defense_p': 0,
    'defense_n': 0,
    'defense_m': 0,
  };

  PlayerStats({
    required this.playerId,
    required this.matchId,
    this.stats = const {},
  });

  // Convert to JSON for database transfer
  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'match_id': matchId,
      ...stats, // Spread operator to include all stats in the JSON
    };
  }

  // Method to increase a specific stat
}

class _StatsPageState extends State<StatsPage> {
  Team? selectedTeam;

  @override
  void initState() {
    super.initState();
    getTeamData();
  }

  void increaseStatOfSelectedPlayer(String stat) {
    if (selectedPlayer?.playerRatings?.stats.containsKey(stat) ?? false) {
      selectedPlayer?.playerRatings?.stats[stat] =
          (selectedPlayer?.playerRatings?.stats[stat] ?? 0) + 1;
      addRatings();
    } else {
      print('Stat $stat does not exist.');
    }
  }

  void loadStatsOfPlayer(Player player) {
    setState(() {
      getRatings(player.id);
    });
  }

  Future<void> getRatings(int playerId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/ratings'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> statsResponse = List.from(
          jsonDecode(response.body),
        );
        for (var player in players) {
          for (var stat in statsResponse) {
            if (stat['player_id'] == player.id) {
              setState(() {
                player.playerRatings = PlayerStats(
                  playerId: stat['player_id'],
                  matchId: stat['match_id'],
                  stats:
                      Map<String, int>.from(stat)
                        ..remove('player_id')
                        ..remove('match_id'),
                );
              });
              break;
            }
          }
        }
      } else {
        print(
          'Failed to load player stats. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching player stats: $e');
    }
  }

  Future<void> getTeamData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/teams'));
      if (response.statusCode == 200) {
        final List<dynamic> teamsResponse = List.from(
          jsonDecode(response.body),
        );
        setState(() {
          teams =
              teamsResponse
                  .map((team) => Team(team['id'], team['team_name']))
                  .toList();
        });
      } else {
        print('Failed to load teams. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  Future<void> getPlayerDataFromTeam() async {
    if (selectedTeam == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/players/${selectedTeam!.id}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> playersResponse = List.from(
          jsonDecode(response.body),
        );
        setState(() {
          players =
              playersResponse.map((player) {
                return Player(
                  player['id'],
                  player['first_name'],
                  player['last_name'],
                  player['birth_date'],
                  player['jersey_number'],
                  player['position'],
                  null, // Stats will be fetched separately
                );
              }).toList();

          for (var player in players) {
            setState(() {
              getRatings(player.id);
            });
          }
        });
      } else {
        print('Failed to load players. Status code: ${response.statusCode}');
        players.clear();
        setState(() {});
      }
    } catch (e) {
      print('Error fetching players: $e');
    }
  }

  Future<void> getMatchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/match'));
      if (response.statusCode == 200) {
        final List<dynamic> matchesResponse = List.from(
          jsonDecode(response.body),
        );
        setState(() {
          matches =
              matchesResponse.map((match) {
                return Match(
                  match['id'],
                  match['date'],
                  Team(match['team1_id'], match['team1_name']),
                  Team(match['team2_id'], match['team2_name']),
                  match['final_score_team1'],
                  match['final_score_team2'],
                );
              }).toList();
        });
      } else {
        print('Failed to load matches. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  Future<void> addRatings() async {
    if (selectedPlayer == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/ratings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(selectedPlayer!.playerRatings?.toJson()),
      );
      if (response.statusCode == 200) {
        print('Ratings added successfully!');
      } else {
        print('Failed to add ratings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding ratings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats Page')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<Match>(
              items:
                  matches
                      .map(
                        (match) => DropdownMenuItem<Match>(
                          value: match,
                          child: Text(
                            '${match.team1.name} : ${match.team2.name}  ${match.date}',
                          ),
                        ),
                      )
                      .toList(),
              value: null, // Add a default value or manage state for selection
              hint: const Text('Select a match'),
              onChanged: (Match? selectedMatch) {
                // Handle match selection
              },
            ),
            // Dropdown for selecting a team
            DropdownButton<Team>(
              value: selectedTeam,
              hint: const Text('Select a team'),
              items:
                  teams
                      .map(
                        (team) => DropdownMenuItem(
                          value: team,
                          child: Text(team.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) async {
                selectedTeam = value;
                players.clear(); // Clear players when a new team is selected
                await getPlayerDataFromTeam();
                setState(() {});
              },
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.center,
              child: Align(
                alignment: const Alignment(-0.7, 0.0),
                child: const Text(
                  "SERVICE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 8.0,
                  columns: [
                    const DataColumn(
                      label: SizedBox(width: 150.0, child: Text('Player')),
                    ),
                    DataColumn(
                      label: ElevatedButton(
                        onPressed: () {
                          print(
                            "Stats:$selectedPlayer.stats SelectedPlayer:$selectedPlayer",
                          );
                          setState(() {
                            increaseStatOfSelectedPlayer('service_pp');
                          });
                        },
                        child: const Text('++'),
                      ),
                    ),
                    DataColumn(
                      label: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            increaseStatOfSelectedPlayer('service_p');
                          });
                        },
                        child: const Text('+'),
                      ),
                    ),
                    DataColumn(
                      label: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            increaseStatOfSelectedPlayer('service_n');
                          });
                        },
                        child: const Text('o'),
                      ),
                    ),
                    DataColumn(
                      label: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            increaseStatOfSelectedPlayer('service_m');
                          });
                        },
                        child: const Text('-'),
                      ),
                    ),
                    const DataColumn(label: Text('Attack')),
                  ],
                  rows:
                      players
                          .map(
                            (player) => DataRow(
                              cells: [
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        // Fetch player stats when a player is selected
                                        loadStatsOfPlayer(player);
                                        selectedPlayer = player;
                                      });
                                    },
                                    child: Text(
                                      '${player.firstName ?? ''} ${player.lastName ?? ''}',
                                    ),
                                  ),
                                ),
                                ...[
                                  'service_pp',
                                  'service_p',
                                  'service_n',
                                  'service_m',
                                  'attack_pp',
                                ].map(
                                  (stat) => DataCell(
                                    Center(
                                      child: Text(
                                        player.playerRatings?.stats[stat]
                                                .toString() ??
                                            '0',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
