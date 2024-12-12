import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/setting_categories.dart/services/firestore_services.dart';
import 'package:flutter/material.dart';
// Import the FirestoreService

class UnitOfMeasureForm extends StatefulWidget {
  const UnitOfMeasureForm({super.key});

  @override
  _UnitOfMeasureFormState createState() => _UnitOfMeasureFormState();
}

class _UnitOfMeasureFormState extends State<UnitOfMeasureForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double? _bmi; // Define _bmi as a nullable double
  final FirestoreService _firestoreService = FirestoreService(); // Create an instance of FirestoreService
  List<Map<String, dynamic>> _bmiHistory = []; // To store fetched BMI history

  @override
  void initState() {
    super.initState();
    fetchBMHistory(); // Fetch BMI history when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit of Measure Form'),
        backgroundColor: const Color(0xFF4CAF50), // Primary Color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Existing Value and Unit Fields
              // TextFormField(
              //   controller: _valueController,
              //   decoration: const InputDecoration(
              //     labelText: 'Enter Value',
              //     border: OutlineInputBorder(),
              //     filled: true,
              //     fillColor: Color(0xFFF5F5F5), // Light Gray
              //   ),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a value';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 16),
              // TextFormField(
              //   controller: _unitController,
              //   decoration: const InputDecoration(
              //     labelText: 'Enter Unit (e.g., kilometer, meter, pound)',
              //     border: OutlineInputBorder(),
              //     filled: true,
              //     fillColor: Color(0xFFF5F5F5), // Light Gray
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter a unit';
              //     }
              //     return null;
              //   },
              // ),
             // const SizedBox(height: 16),
              // Move Save Unit Button below Value and Unit Fields
              //ElevatedButton(
              //  onPressed: _saveEntry,
              //  style: ElevatedButton.styleFrom(
                //  backgroundColor: const Color(0xFF4CAF50), // Primary Color
              //  ),
                //child: const Text('Save Unit'),
               //),
             // const SizedBox(height: 16),
              // Weight and Height Fields
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Enter Weight (kg)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Enter Height (cm)', // Change to cm
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Light Gray
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 11, 230, 153), // Primary Color
                ),
                child: const Text('Calculate BMI',style: TextStyle(color: Colors.black),),
              ),
              if (_bmi != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // Light Blue background
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    'Your BMI is: ${_bmi!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00796B), // Darker Blue
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'BMI History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_bmiHistory.isNotEmpty) 
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bmiHistory.length,
                  itemBuilder: (context, index) {
                    final record = _bmiHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        title: Text('BMI: ${record['bmi']}'),
                        subtitle: Text('Recorded on: ${record['timestamp'].toDate()}'),
                      ),
                    );
                  },
                ),
              // Removed Saved Entries section
              // const Text(
              //   'Saved Entries:',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('unitofmeasure')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No entries found.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      try {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          color: const Color(0xFFFFFFFF), // White
                          child: ListTile(
                            title: Text(
                              'Value: ${doc['value']}, Unit: ${doc['unit']}',
                              style: const TextStyle(color: Color(0xFF212121)), // Dark Gray
                            ),
                            subtitle: Text(
                              'Saved on: ${(doc['timestamp'] as Timestamp).toDate()}',
                              style: const TextStyle(color: Color(0xFF757575)), // Gray
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)), // Primary Color
                                  onPressed: () => _updateEntry(doc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEntry(doc.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        
                      }
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('unitofmeasure').add({
        'value': _valueController.text,
        'unit': _unitController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _valueController.clear();
      _unitController.clear();
    }
  }

  void _deleteEntry(String id) {
    FirebaseFirestore.instance.collection('unitofmeasure').doc(id).delete();
  }

  void _updateEntry(DocumentSnapshot doc) {
    _valueController.text = doc['value'];
    _unitController.text = doc['unit'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Entry'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
                  validator: (value) => value!.isEmpty ? 'Please enter a value' : null,
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('unitofmeasure').doc(doc.id).update({
                    'value': _valueController.text,
                    'unit': _unitController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                  _valueController.clear();
                  _unitController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = _heightController.text.isNotEmpty ? double.tryParse(_heightController.text)! / 100 : 0; // Added null check
    if (weight != null && height > 0) { // Remove height != null check
      setState(() {
        _bmi = weight / (height * height); // BMI formula
      });
      // Store the BMI in Firestore
      _firestoreService.storeBMI('userId', _bmi!); // Replace 'userId' with the actual user ID
    } else {
      // Handle invalid input
      setState(() {
        _bmi = null; // Reset BMI if input is invalid
      });
    }
  }

  Future<void> fetchBMHistory() async {
    try {
      // Replace 'userId' with the actual user ID
      List<Map<String, dynamic>> bmiHistory = await _firestoreService.getBMHistory('userId');
      setState(() {
        _bmiHistory = bmiHistory; // Update the state with fetched BMI history
      });
    } catch (e) {
      print('Failed to fetch BMI history: $e');
    }
  }
}
