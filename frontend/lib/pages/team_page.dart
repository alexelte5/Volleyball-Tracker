import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

int? jersey_number = null;
String? first_name = null;
String? last_name = null;
String? birth_date = null;
String? position = null;

List<Team> teams = [];
List<Player> players = [];

class Team {
  // Eigenschaften (Felder)
  int id;
  String name;
  //image

  // Konstruktor
  Team(this.id, this.name);
}

class Player {
  // Eigenschaften (Felder)
  int id;
  String? firstName;
  String? lastName;
  String? birthDate;
  int? jerseyNumber;
  String? position;

  // Konstruktor
  Player(
    this.id,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.jerseyNumber,
    this.position,
  );
}

class _TeamPageState extends State<TeamPage> {
  String? selectedDate; // Moved selectedDate to the state
  Team? selectedTeam; // Track the selected team
  final Map<String, List<String>> teamPlayers = {
    'Team A': ['Player 1', 'Player 2', 'Player 3'],
    'Team B': ['Player 4', 'Player 5', 'Player 6'],
    'Team C': ['Player 7', 'Player 8', 'Player 9'],
    // Add more teams and players as needed
  };

  @override
  void initState() {
    super.initState();
    getTeamData();
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
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/players/${selectedTeam?.id}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> teamsResponse = List.from(
          jsonDecode(response.body),
        );
        setState(() {
          players =
              teamsResponse
                  .map(
                    (players) => Player(
                      players['id'],
                      players['first_name'],
                      players['last_name'],
                      players['birth_date'],
                      players['jersey_number'],
                      players['position'],
                    ),
                  )
                  .toList();
        });
      } else {
        print('Failed to load players. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching players: $e');
    }
  }

  Future<void> addPlayer() async {
    if (jersey_number == null) {
      debugPrint('Jersey Number ist NULL !!!!!!!!!!!', wrapWidth: 1024);
    }
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/players'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          if (first_name != null) 'first_name': first_name,
          if (last_name != null) 'last_name': last_name,
          if (selectedDate != null) 'birth_date': selectedDate,
          if (jersey_number == 0) 'jersey_number': null,
          if (jersey_number != null) 'jersey_number': jersey_number,
          if (position != null) 'position': position,
          'team_id': selectedTeam?.id,
        }),
      );
      if (response.statusCode == 201) {
        print('Player added successfully!');
        getPlayerDataFromTeam(); // Refresh player list after adding
      } else {
        print('Failed to add player. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Left side: List of players
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      selectedTeam?.name ??
                          'No Team Selected', // Display selected team name
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8.0),
                      children:
                          players
                              .map(
                                (player) => ListTile(
                                  title: Text(
                                    player.lastName == null
                                        ? "${player.firstName}"
                                        : "${player.firstName} ${player.lastName}",
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side: Form
          Expanded(
            flex: 2,
            child: SizedBox.expand(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Team page', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Team',
                          ),
                          items:
                              teams
                                  .map(
                                    (team) => DropdownMenuItem(
                                      value: team.name,
                                      child: Text(team.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              // Handle team selection
                              players.clear();
                              selectedTeam = teams.firstWhere(
                                (team) => team.name == value,
                                orElse: () => Team(0, ''),
                              );
                              getPlayerDataFromTeam();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                          onChanged: (value) {
                            first_name = value;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          onChanged: (value) {
                            last_name = value;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            hintText:
                                'Select a date', // Remove selectedDate from hintText
                          ),
                          controller: TextEditingController(
                            text:
                                selectedDate, // Display selected date in the field
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate =
                                    '${pickedDate.toLocal()}'.split(' ')[0];
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Jersey Number',
                          ),
                          onChanged: (value) {
                            setState(() {
                              print(value);
                              jersey_number =
                                  value.isEmpty ? 0 : int.tryParse(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Position',
                          ),

                          items:
                              [
                                    'Außenangreifer',
                                    'Mittelbocker',
                                    'Diagonal',
                                    'Zuspieler',
                                    'Libero',
                                  ]
                                  .map(
                                    (position) => DropdownMenuItem(
                                      value: position,
                                      child: Text(position),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              // Handle position selection
                              position = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle button press
                          addPlayer();
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
