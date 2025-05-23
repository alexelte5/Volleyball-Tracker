// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

int? jersey_number;
String? first_name;
String? last_name;
String? birth_date;
String? position;

String? team_name;

bool addTeamSelected = false;
bool addPlayerSelected = true;

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
        players.clear(); // Clear players if the request fails
        setState(() {});
      }
    } catch (e) {
      print('Error fetching players: $e');
    }
  }

  Future<void> addPlayer() async {
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

  Future<void> addTeam() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/teams'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'team_name': team_name}),
      );
      if (response.statusCode == 201) {
        print('Team added successfully!');
        getTeamData(); // Refresh team list after adding
      } else {
        print('Failed to add team. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding team: $e');
    }
  }

  Future<void> deletePlayer(int playerId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/players/$playerId'),
      );
      if (response.statusCode == 200) {
        print('Player deleted successfully!');
        getPlayerDataFromTeam();
        setState(() {});
      } else {
        print('Failed to delete player. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting player: $e');
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
              color: const Color.fromARGB(255, 255, 255, 255),
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
                          players.isEmpty
                              ? [
                                const ListTile(
                                  title: Text('No players found.'),
                                ),
                              ]
                              : players
                                  .map(
                                    (player) => ListTile(
                                      title: Text(
                                        "${player.firstName ?? ''} ${player.lastName ?? ''}${player.jerseyNumber != null ? ' (#${player.jerseyNumber})' : ''}"
                                            .trim(),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Handle delete player action
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Delete Player',
                                                ),
                                                content: Text(
                                                  player.jerseyNumber != null &&
                                                          player.lastName !=
                                                              null &&
                                                          player.firstName !=
                                                              null
                                                      ? 'Are you sure you want to delete ${player.firstName} ${player.lastName} with jersey number ${player.jerseyNumber}?'
                                                      : player.lastName !=
                                                              null &&
                                                          player.firstName !=
                                                              null &&
                                                          player.jerseyNumber ==
                                                              null
                                                      ? 'Are you sure you want to delete ${player.firstName} ${player.lastName}?'
                                                      : player.lastName ==
                                                              null &&
                                                          player.firstName !=
                                                              null &&
                                                          player.jerseyNumber ==
                                                              null
                                                      ? 'Are you sure you want to delete ${player.firstName} ?'
                                                      : player.lastName ==
                                                              null &&
                                                          player.firstName !=
                                                              null &&
                                                          player.jerseyNumber !=
                                                              null
                                                      ? 'Are you sure you want to delete ${player.firstName} with jersey number ${player.jerseyNumber}?'
                                                      : player.lastName ==
                                                              null &&
                                                          player.firstName ==
                                                              null &&
                                                          player.jerseyNumber !=
                                                              null
                                                      ? 'Are you sure you want to delete jersey number ${player.jerseyNumber} ?'
                                                      : player.lastName ==
                                                              null &&
                                                          player.firstName ==
                                                              null &&
                                                          player.jerseyNumber ==
                                                              null
                                                      ? 'Are you sure you want to delete ${player.id} ?'
                                                      : 'Are you sure you want to delete ${player.firstName} ?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      // Handle delete action
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      deletePlayer(player.id);
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
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
            child: Column(
              children: [
                // Navigation Bar
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Handle navigation to Home
                          setState(() {
                            addTeamSelected = false;
                            addPlayerSelected = true;
                          });
                        },
                        child: const Text('Add Player'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle navigation to Settings
                          setState(() {
                            addTeamSelected = true;
                            addPlayerSelected = false;
                          });
                        },
                        child: const Text('Add Team'),
                      ),
                    ],
                  ),
                ),
                //Form for adding teams
                if (addTeamSelected)
                  Expanded(
                    flex: 1,
                    child: SizedBox.expand(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Add Team',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Team Name',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      team_name = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle button press
                                  addTeam();
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                //Form for adding players
                if (addPlayerSelected)
                  Expanded(
                    flex: 2,
                    child: SizedBox.expand(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Team page',
                                style: theme.textTheme.titleLarge,
                              ),
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
                                  controller:
                                      TextEditingController()
                                        ..text =
                                            selectedDate ??
                                            '', // Display selected date in the field
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
                                            '${pickedDate.toLocal()}'.split(
                                              ' ',
                                            )[0];
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
                                      jersey_number =
                                          value.isEmpty
                                              ? 0
                                              : int.tryParse(value);
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
          ),
        ],
      ),
    );
  }
}
