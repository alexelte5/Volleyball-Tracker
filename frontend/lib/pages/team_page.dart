import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? selectedDate; // Moved selectedDate to the state
  String? selectedTeam; // Track the selected team
  final Map<String, List<String>> teamPlayers = {
    'Team A': ['Alice', 'Bob', 'Charlie'],
    'Team B': ['David', 'Eve', 'Frank'],
    'Team C': ['Grace', 'Heidi', 'Ivan'],
  };

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
                      selectedTeam ??
                          'No Team Selected', // Display selected team name
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8.0),
                      children:
                          (teamPlayers[selectedTeam] ?? [])
                              .map((player) => ListTile(title: Text(player)))
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
                              teamPlayers.keys
                                  .map(
                                    (team) => DropdownMenuItem(
                                      value: team,
                                      child: Text(team),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeam = value; // Update selected team
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
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
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
                            // Handle position selection
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle button press
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
