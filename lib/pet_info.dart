import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

class PetInformationPage extends StatelessWidget {
  final String petName;
  final String petType;
  final int id;

  const PetInformationPage({
    Key? key,
    required this.petName,
    required this.petType,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Information'),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.blue[200],
        icon: Icons.menu,
        children: [
          SpeedDialChild(
            child: Icon(Icons.pending_actions),
            backgroundColor: Colors.green,
            label: 'Log Feeding Time',
            onTap: () {
              showLastFoodDialog(context);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.pending_actions),
            backgroundColor: Colors.orange,
            label: 'Log Shedding Time',
            onTap: () {
              _showSheddingDateTimePicker(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: $petName',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Type: $petType',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'ID: $id',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            // Add other cards here
            FutureBuilder<List<String>?>(
              future: fetchLastFed(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<String>? lastFed = snapshot.data;
                  if (lastFed != null && lastFed.isNotEmpty) {
                    return Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FEEDING INFORMATION',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: lastFed.map((timestamp) {
                                return Text(
                                  "• $timestamp",
                                  style: TextStyle(fontSize: 18),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No feeding information available.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            FutureBuilder<List<String>?>(
              future: fetchLastShed(id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<String>? lastFed = snapshot.data;
                  if (lastFed != null && lastFed.isNotEmpty) {
                    return Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SHEDDING INFORMATION',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: lastFed.map((timestamp) {
                                return Text(
                                  "• $timestamp",
                                  style: TextStyle(fontSize: 18),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No Shedding information available.',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showFeedingDateTimePicker(
      BuildContext context, String food) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Handle the selected date and time
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        addFeedingTime(id, selectedDateTime, food);
        // You can use the selectedDateTime for further processing
        print('Selected Date and Time: $selectedDateTime');
        return selectedDateTime;
      }
    }
    // If the user cancels, return null
    return null;
  }

  void showLastFoodDialog(BuildContext context) {
    String thefood = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              thefood = value;
            },
            decoration: InputDecoration(hintText: 'Enter text here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Call _showFeedingDateTimePicker without await
                _showFeedingDateTimePicker(context, thefood)
                    .then((selectedDateTime) {
                  if (selectedDateTime != null) {
                    // Optionally, you can handle the selectedDateTime here
                  }
                  Navigator.of(context).pop(); // Close the dialog
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSheddingDateTimePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Handle the selected date and time
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        addSheddingTime(id, selectedDateTime);
        // You can use the selectedDateTime for further processing
        print('Selected Date and Time: $selectedDateTime');
      }
    }
  }

  Future<List<String>?> fetchLastFed(int petid) async {
    var link = "http://192.168.1.3/exopet/pet.php/";

    final Map<String, dynamic> json = {"pet_id": petid};
    final query = {
      "operation": "getlastfed",
      "json": jsonEncode(json),
    };

    try {
      final response =
          await http.get(Uri.parse(link).replace(queryParameters: query));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res is List && res.isNotEmpty) {
          // Extract all the last fed timestamps from the entries
          final timestamps = res.map((entry) {
            final String lastfed = entry['lastfed'] as String;
            final String? food = entry['typeof_food']
                as String?;
            return food != null ? "Last fed: $lastfed (Type of food: $food)" : lastfed;
          }).toList();

          return timestamps;
        } else {
          print("Invalid data format received from API");
          return null;
        }
      }
    } catch (error) {
      print("Runtime Error: $error");
    }
    return null;
  }

  Future<List<String>?> fetchLastShed(int petid) async {
    var link = "http://192.168.1.3/exopet/pet.php/";

    final Map<String, dynamic> json = {"pet_id": petid};
    final query = {
      "operation": "getlastshed",
      "json": jsonEncode(json),
    };

    try {
      final response =
          await http.get(Uri.parse(link).replace(queryParameters: query));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("DATA RESPONSE: $res");
        if (res is List && res.isNotEmpty) {
          final timestamps = res
              .map((entry) => entry['lastshed'] != null
                  ? entry['lastshed'] as String
                  : null)
              .where((timestamp) => timestamp != null)
              .cast<String>()
              .toList();
          return timestamps;
        } else {
          print("Invalid data format received from API");
          return null;
        }
      }
    } catch (error) {
      print("Runtime Error: $error");
    }
    return null;
  }

  Future<void> addFeedingTime(int petid, DateTime lastfed, String food) async {
    var link = "http://192.168.1.3/exopet/pet.php";

    // Convert DateTime to a string representation
    String formattedDate = lastfed.toIso8601String();

    final Map<String, dynamic> json = {
      "petid": petid,
      "lastfed": formattedDate,
      "food": food
    };
    final Map<String, dynamic> query = {
      "operation": "addlastfed",
      "json": jsonEncode(json)
    };
    try {
      final response = await http.post(Uri.parse(link), body: query);
      if (response.statusCode == 200) {
        print('Added last fed successfully!');
      } else {
        print('Failed to add fed successfully: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error adding last fed: $error');
    }
  }

  Future<void> addSheddingTime(int petid, DateTime lastfed) async {
    var link = "http://192.168.1.3/exopet/pet.php";

    // Convert DateTime to a string representation
    String formattedDate = lastfed.toIso8601String();

    final Map<String, dynamic> json = {
      "petid": petid,
      "lastshed": formattedDate
    };
    final Map<String, dynamic> query = {
      "operation": "addlastshed",
      "json": jsonEncode(json)
    };
    try {
      final response = await http.post(Uri.parse(link), body: query);
      if (response.statusCode == 200) {
        print('Added last fed successfully!');
      } else {
        print('Failed to add fed successfully: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error adding last fed: $error');
    }
  }
}
