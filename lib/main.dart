import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:tes/contact.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:tes/profile.dart';
import 'package:http/http.dart' as http;

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController nomorController = TextEditingController();

  Future<Profile> getProfile() async {
    final data =
        await http.get(Uri.parse('https://api.github.com/users/orvalaam'));
    if (data.statusCode == 200) {
      dynamic jsonData = json.decode(data.body);
      Profile hasil = Profile(
        id: jsonData['id'],
        name: jsonData['login'],
        bio: jsonData['bio'],
        avatarUrl: jsonData['avatar_url'],
      );
      return hasil;
    } else {
      debugPrint('Request failed with status: ${data.statusCode}');
      return Profile();
    }
  }

  Future<void> getContacts() async {
    final data = await http.get(Uri.parse(
        'https://oprecppb-default-rtdb.firebaseio.com/contacts.json'));
    if (data.statusCode == 200) {
      var response = jsonDecode(data.body) as Map<String, dynamic>;
      List<Contact> temp = [];
      response.forEach((key, value) {
        temp.add(Contact(id: key, nama: value["nama"], nomor: value["nomor"]));
      });
      setState(() {
        listContact = temp;
      });
    }
  }

  Future<void> addContact(String nama, nomor) async {
    http
        .post(
            Uri.parse(
                "https://oprecppb-default-rtdb.firebaseio.com/contacts.json"),
            body: json.encode({"nama": nama, "nomor": nomor}))
        .then((response) {
      setState(() {
        listContact.add(Contact(
            id: json.decode(response.body)["name"].toString(),
            nama: nama,
            nomor: nomor));
      });
    });
  }

  Future<void> editContact(String id, String nama, String nomor) async {
    http
        .put(
            Uri.parse(
                "https://oprecppb-default-rtdb.firebaseio.com/contacts/$id.json"),
            body: json.encode({"nama": nama, "nomor": nomor}))
        .then((response) {
      setState(() {
        Contact kontak = listContact.firstWhere((element) => element.id == id);
        kontak.nama = nama;
        kontak.nomor = nomor;
      });
    });
  }

  Future<void> deleteContact(String id) async {
    http
        .delete(Uri.parse(
            "https://oprecppb-default-rtdb.firebaseio.com/contacts/$id.json"))
        .then((response) {
      setState(() {
        listContact.removeWhere((element) => element.id == id);
      });
    });
  }

  List<Contact> listContact = [];
  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Your Contact List"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
              future: getProfile(),
              builder: (context, snapshot) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        '${snapshot.data?.avatarUrl}',
                        height: 100,
                      ),
                      Text('${snapshot.data?.name} (${snapshot.data?.id})'),
                      Text('${snapshot.data?.bio}')
                    ]);
              },
            ),
          ),
          listContact.isEmpty
              ? const Center(
                  child: Text("No data"),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: listContact.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${listContact[index].nama}'),
                      subtitle: Text('${listContact[index].nomor}'),
                      leading: const CircleAvatar(backgroundColor: Colors.blue),
                      onTap: () {
                        namaController.text = '${listContact[index].nama}';
                        nomorController.text = '${listContact[index].nomor}';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit Contact'),
                              content: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: namaController,
                                      decoration: const InputDecoration(
                                        hintText: "Nama",
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: nomorController,
                                      decoration: const InputDecoration(
                                        hintText: "Nomor",
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.yellow),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue),
                                      onPressed: () {
                                        editContact(
                                            '${listContact[index].id}',
                                            namaController.text,
                                            nomorController.text);
                                        namaController.text = "";
                                        nomorController.text = "";
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Contact'),
                              content: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: const Text(
                                      "Ingin menghapus kontak ini?")),
                              actions: <Widget>[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () {
                                    deleteContact('${listContact[index].id}');
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add New Contact'),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          hintText: "Nama",
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: nomorController,
                        decoration: const InputDecoration(
                          hintText: "Nomor",
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        onPressed: () {
                          addContact(namaController.text, nomorController.text);
                          namaController.text = "";
                          nomorController.text = "";
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
