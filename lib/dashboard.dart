import 'dart:convert';
import 'package:exopet/pet_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final String username;
  Dashboard({Key? key, required this.username}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> pets = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>?> fetchPets() async {
    var link = "http://192.168.1.7/exopet/pet.php/";

    final query = {
      "operation": "getpets",
      "json": jsonEncode(""),
    };

    try {
      final response =
          await http.get(Uri.parse(link).replace(queryParameters: query));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("DATA RESPONSE: $res");
        if (res is List && res.isNotEmpty && res[0] is Map<String, dynamic>) {
          return List<dynamic>.from(res);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.username}'s Pets"),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            showAddPetsDialog(context);
          },
          child: Icon(Icons.add),
        ),
      ),
      body: FutureBuilder<List<dynamic>?>(
        future: fetchPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final petData = snapshot.data![index] as Map<String, dynamic>;
                  final petName = petData['petname'] as String;
                  final petType = petData['pettype'] as String;
                  final petId = petData['id'];
                  final petSpecs = petData['pettype'] as String;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PetInformationPage(
                                    petName: petName,
                                    petType: petType,
                                    id: petId,
                                    petSpecies: petSpecs,
                                  )));
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(
                          "$index Petname: $petName",
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(petType, style: TextStyle(fontSize: 18)),
                        trailing: Wrap(
                          children: <Widget>[
                            IconButton(
                                onPressed: () async {
                                  deletePet(petId);
                                  final List<dynamic>? petsData =
                                      await fetchPets();

                                  if (petsData != null) {
                                    setState(() {
                                      pets = petsData
                                          .map(
                                              (pet) => pet['petname'] as String)
                                          .toList();
                                    });
                                  }
                                },
                                icon: const Icon(Icons.delete)),
                            IconButton(
                                onPressed: () {
                                  showUpdatePetDialog(
                                      context, petId, petName, petType);
                                },
                                icon: const Icon(Icons.edit))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              print('Snapshot data: ${snapshot.data}');
              return Center(child: Text('Unexpected data format'));
            }
          }
        },
      ),
    );
  }

  void showUpdatePetDialog(BuildContext context, int petId,
      String currentPetName, String currentPetType) {
    String newPetName = currentPetName;
    String newPetType = currentPetType;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newPetName = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter pet name',
                ),
                controller: TextEditingController(text: currentPetName),
              ),
              TextField(
                onChanged: (value) {
                  newPetType = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter pet type',
                ),
                controller: TextEditingController(text: currentPetType),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPetName.isNotEmpty || newPetType.isNotEmpty) {
                  updatePet(petId, newPetName, newPetType);

                  final List<dynamic>? petsData = await fetchPets();

                  if (petsData != null) {
                    setState(() {
                      pets = petsData
                          .map((pet) => pet['petname'] as String)
                          .toList();
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void showAddPetsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPetName = '';
        String newPetType = '';
        return AlertDialog(
          title: Text('Add New Pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newPetName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter pet name',
                ),
              ),
              TextField(
                onChanged: (value) {
                  newPetType = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter pet type',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newPetName.isNotEmpty || newPetType.isNotEmpty) {
                  addPet(newPetName, newPetType);

                  final List<dynamic>? petsData = await fetchPets();

                  if (petsData != null) {
                    setState(() {
                      pets = petsData
                          .map((pet) => pet['petname'] as String)
                          .toList();
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> addPet(String petName, String petType) async {
  var link = "http://192.168.1.7/exopet/pet.php";

  final Map<String, dynamic> json = {"petname": petName, "pettype": petType};
  final Map<String, dynamic> query = {
    "operation": "addpet",
    "json": jsonEncode(json)
  };
  try {
    final response = await http.post(Uri.parse(link), body: query);
    if (response.statusCode == 200) {
      print('Pet added successfully!');
    } else {
      print('Failed to add pet: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error adding pet: $error');
  }
}

Future<void> deletePet(int petId) async {
  var link = "http://192.168.1.7/exopet/pet.php";

  final Map<String, dynamic> json = {"pet_id": petId};
  final Map<String, dynamic> query = {
    "operation": "deletepet",
    "json": jsonEncode(json)
  };
  try {
    final response = await http.post(Uri.parse(link), body: query);
    if (response.statusCode == 200) {
      print('Pet deleted successfully!');
    } else {
      print('Failed to deleted pet: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error deleted pet: $error');
  }
}

Future<void> updatePet(int petId, String name, String pettype) async {
  var link = "http://192.168.1.7/exopet/pet.php";

  final Map<String, dynamic> json = {
    "pet_id": petId,
    "new_petname": name,
    "new_pettype": pettype
  };
  final Map<String, dynamic> query = {
    "operation": "updatepet",
    "json": jsonEncode(json)
  };
  try {
    final response = await http.post(Uri.parse(link), body: query);
    if (response.statusCode == 200) {
      print('Pet deleted successfully!');
    } else {
      print('Failed to deleted pet: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error deleted pet: $error');
  }
}
