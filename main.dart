
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

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
      debugShowCheckedModeBanner: false,
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {

  TextEditingController nameController =
      TextEditingController();

  TextEditingController ageController =
      TextEditingController();

  // POST DATA TO FIREBASE
  Future<void> addStudent() async {

    String name = nameController.text.trim();
    int? age = int.tryParse(ageController.text.trim());

    if (name.isEmpty || age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid name and age")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('students')
        .add({
      'name': name,
      'age': age,
    });

    nameController.clear();
    ageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student Added Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Firebase App"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Age",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: addStudent,
              child: const Text("POST DATA"),
            ),

            const Divider(height: 30),

            const Text(
              "Student Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // GET DATA FROM FIREBASE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  var students = snapshot.data!.docs;

                  if (students.isEmpty) {
                    return const Text("No Students Found");
                  }

                  return ListView.builder(
                    itemCount: students.length,

                    itemBuilder: (context, index) {

                      var student = students[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),

                          title: Text(student['name']),

                          subtitle: Text(
                            "Age: ${student['age']}",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
