import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;

class PetInformationPage extends StatelessWidget {
  final String petName;
  final String petType;
  final String petSpecies;
  final int id;

  const PetInformationPage({
    Key? key,
    required this.petName,
    required this.petType,
    required this.petSpecies,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset('assets/logo.png', width: 60)),
        backgroundColor: Color.fromARGB(255, 13, 132, 17),
        centerTitle: true,
        title: Text('Pet Information'),
      ),
      backgroundColor: Color.fromARGB(255, 13, 132, 17),
      floatingActionButton: SpeedDial(
        backgroundColor: const Color.fromARGB(255, 0, 140, 255),
        icon: Icons.menu,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.pending_actions),
            backgroundColor: const Color.fromARGB(
              255,
              13,
              132,
              17,
            ),
            label: 'Feeding Time Log',
            onTap: () {
              showLastFoodDialog(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.pending_actions),
            backgroundColor: Colors.orange,
            label: 'Molt/Shed Log',
            onTap: () {
              _showSheddingDateTimePicker(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.date_range),
            backgroundColor: Colors.yellow,
            label: 'Breeding/Clutch Date',
            onTap: () {
              _showBreedingDatePicker(context);
            },
          )
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
                      'Common Name: $petName',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Species/Scientific Name: $petSpecies',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Type: $petType',
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

            FutureBuilder<List<String>?>(
              future: fetBreedingInfo(id),
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
                              'BREEDING INFORMATION',
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
                          'No Breeding information available.',
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
          title: Text('Food Type:'),
          content: TextField(
            onChanged: (value) {
              thefood = value;
            },
            decoration: InputDecoration(hintText: ''),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _showFeedingDateTimePicker(context, thefood)
                    .then((selectedDateTime) {
                  if (selectedDateTime != null) {}
                  Navigator.of(context).pop();
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

  void _showBreedingDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      _showClutchDatePicker(context, pickedDate);
      print('Selected Date: $pickedDate');
    }
  }

  void _showClutchDatePicker(BuildContext context, DateTime breedDate) async {
    final DateTime? cdate = await showDatePicker(
      context: context,
      initialDate: breedDate,
      firstDate: breedDate,
      lastDate: DateTime(2025),
    );

    if (cdate != null) {
      addBreedingDate(id, breedDate, cdate);
      print('Selected Clutch Date: $cdate');
    }
  }
}

Future<List<String>?> fetchLastFed(int petid) async {
  var link = "http://192.168.1.7/exopet/pet.php/";

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
          final String? food = entry['typeof_food'] as String?;
          return food != null
              ? "Last fed: $lastfed (Type of food: $food)"
              : lastfed;
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
  var link = "http://192.168.1.7/exopet/pet.php/";

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
            .map((entry) =>
                entry['lastshed'] != null ? entry['lastshed'] as String : null)
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
  var link = "http://192.168.1.7/exopet/pet.php";

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
  var link = "http://192.168.1.7/exopet/pet.php";

  String formattedDate = lastfed.toIso8601String();

  final Map<String, dynamic> json = {"petid": petid, "lastshed": formattedDate};
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

Future<List<String>?> fetBreedingInfo(int petid) async {
  var link = "http://192.168.1.7/exopet/pet.php/";

  final Map<String, dynamic> json = {"pet_id": petid};
  final query = {
    "operation": "getbreed",
    "json": jsonEncode(json),
  };

  try {
    final response =
        await http.get(Uri.parse(link).replace(queryParameters: query));

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res is List && res.isNotEmpty) {
        final timestamps = res.map((entry) {
          final String breeddate = entry['bdate'] as String;
          final String? cdate = entry['cdate'] as String?;
          return cdate != null
              ? "Breeding Date: $breeddate (Clutch Date: $cdate)"
              : breeddate;
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

Future<void> addBreedingDate(int petid, DateTime bdate, DateTime cdate) async {
  var link = "http://192.168.1.7/exopet/pet.php";

  String formattedBDate = bdate.toIso8601String();
  String formattedCDate = cdate.toIso8601String();

  final Map<String, dynamic> json = {
    "petid": petid,
    "bdate": formattedBDate,
    "cdate": formattedCDate
  };
  final Map<String, dynamic> query = {
    "operation": "addbreed",
    "json": jsonEncode(json)
  };
  try {
    final response = await http.post(Uri.parse(link), body: query);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);

      if (res == "1") {
        print('Added Breeding data successfully!');
      } else {
        print("Something went wrong: $res");
      }
    } else {
      print('Failed to add Breeding data: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error adding Breeding data: $error');
  }
}
