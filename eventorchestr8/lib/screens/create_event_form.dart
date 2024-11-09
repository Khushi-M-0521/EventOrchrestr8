import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';


class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  FilePickerResult? _filePickerResult;
  bool _isInPersonEvent = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _sponsorsController = TextEditingController();
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
        _dateTimeController.text.isNotEmpty) {
      try {
        await firestore.collection('events').add({
          'name': _nameController.text,
          'description': _descController.text,
          'location': _locationController.text,
          'date_time': _dateTimeController.text,
          'in_person_event': _isInPersonEvent,
          'guests': _guestController.text,
          'sponsors': _sponsorsController.text,
          'created_at': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event Created!")),
        );
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create event")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Event Name, Description, Location, Date & Time are required")),
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
                  color: Colors.green[100],
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
                controller: _guestController,
                icon: Icons.people_outlined,
                label: "Guests",
                hint: "Enter list of guests"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _sponsorsController,
                icon: Icons.attach_money_outlined,
                label: "Sponsors",
                hint: "Enter Sponsors"),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "In Person Event",
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                const Spacer(),
                Switch(
                    activeColor: Colors.green,
                    value: _isInPersonEvent,
                    onChanged: (value) {
                      setState(() {
                        _isInPersonEvent = value;
                      });
                    }),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: MaterialButton(
                color: Colors.green,
                onPressed: _createEvent,
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
