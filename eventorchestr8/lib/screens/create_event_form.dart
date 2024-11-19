import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/screens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CreateEventPage extends StatefulWidget {
  final String communityId; // Assuming communityId is passed to this screen

  CreateEventPage({required this.communityId});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  FilePickerResult? _filePickerResult;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _googleFormLinkController =
      TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _theme = TextEditingController();
  final TextEditingController _days = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  final TextEditingController _minutes = TextEditingController();
  final TextEditingController _name2Controller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isUploading = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to select Date and Time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
      }
    }
  }

  // Open file picker to select event image
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    setState(() {
      _filePickerResult = result;
    });
  }
  // void selectImage() async {
  //   image = await pickImage(context);
  //   setState(() {});
  // }

  // Function to create event and store it in Firebase

  Future<void> _createEvent() async {
    if (_nameController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _dateTimeController.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _theme.text.isNotEmpty &&
        _days.text.isNotEmpty &&
        _hours.text.isNotEmpty &&
        _minutes.text.isNotEmpty &&
        _name2Controller.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      try {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        String createdBy = userId ?? 'Unknown User';
        String communityId = widget.communityId;
        String googleFormLink = _googleFormLinkController.text;
        if (!Uri.tryParse(googleFormLink)!.hasAbsolutePath ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Google Form link")),
          );
          return;
        }

        // Prepare the event data
        Map<String, dynamic> eventData = {
          'title': _nameController.text,
          'description': _descController.text,
          'location': _locationController.text,
          'dateTime': DateTime.parse(_dateTimeController
              .text), // Use current time or set specific time
          'created_at': FieldValue.serverTimestamp(),
          'created_by': createdBy,
          'community_id': communityId,
          'price': _price.text, // Example price
          'peopleRegistered': 0, // Example number of people registered
          'theme': _theme.text, // Example theme
          'postTime': DateTime.now().millisecondsSinceEpoch,
          // Timestamp for post time
          'duration': {'hours': 1},
          'googleFormUrl': googleFormLink,
          'duration': {
            'days': int.tryParse(_days.text) ?? 0,
            'hours': int.tryParse(_hours.text) ?? 0,
            'minutes': int.tryParse(_minutes.text) ?? 0,
          },
          "contacts": {
            "name": _name2Controller.text,
            "email": _emailController.text,
            "phone": _phoneController.text
          }

          // Example duration in hours
        };
        print(DateTime.now().millisecondsSinceEpoch);

        // If image is selected, upload it to Firebase Storage and add the URL
        String? imageUrl;
        if (_filePickerResult != null) {
          File imageFile = File(_filePickerResult!.files.first.path!);
          String imagePath =
              'event_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
          UploadTask uploadTask =
              FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Add image URL to the event data if available
        if (imageUrl != null) {
          eventData['imageUrl'] = imageUrl;
        }

        // Store event data in Firestore
        await firestore.collection('events').add(eventData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event Created!")),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create event")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All details are required")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Create Event",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: _openFilePicker,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .3,
                decoration: BoxDecoration(
                  // color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _filePickerResult != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_filePickerResult!.files.first.path!),
                          fit: BoxFit.fill,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined,
                              size: 42, color: Colors.black),
                          SizedBox(height: 8),
                          Text(
                            "Add Event Image",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _nameController,
                icon: Icons.event_outlined,
                label: "Event Name",
                hint: "Add Event Name"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _descController,
                icon: Icons.description_outlined,
                label: "Description",
                hint: "Add Description",
                maxLines: 4),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _theme,
                icon: Icons.star_sharp,
                label: "Theme",
                hint: "Enter theme of Event"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: "Location",
                hint: "Enter Location of Event"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _dateTimeController,
                icon: Icons.date_range_outlined,
                label: "Date & Time",
                hint: "Pickup Date & Time",
                readOnly: true,
                onTap: () => _selectDateTime(context)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _days,
              icon: Icons.lock_clock_outlined,
              label: "days",
              hint: "Enter number of days",
              // readOnly: true,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _hours,
              icon: Icons.lock_clock_outlined,
              label: "hours",
              hint: "Enter number of hours",
              // readOnly: true,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _minutes,
              icon: Icons.lock_clock_outlined,
              label: "Minutes",
              hint: "Enter number of minutes",
              // readOnly: true,
            ),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _price,
                icon: Icons.money_rounded,
                label: "Price",
                hint: "Registration cost"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _name2Controller,
                icon: Icons.account_circle,
                label: "Contact Name",
                hint: "Enter Contact Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                labelText: 'Phone',
                hintText: 'Enter contact phone number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: 'Email',
                hintText: 'Enter contact email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _googleFormLinkController,
              icon: Icons.link,
              label: "Google Form",
              hint: "Enter the Google Form URL for registration",
              // keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: MaterialButton(
                // color: Colors.green,
                onPressed: () async {
                  await _createEvent(); // Wrap the async function
                },
                child: const Text(
                  "Create New Event",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    // required TextInputType keyboardType,
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    GestureTapCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
