import 'package:eventorchestr8/provider/firebase_provider.dart';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/screens/specific_community_screen.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CreateEventPage extends StatefulWidget {
  final String communityId; // Assuming communityId is passed to this screen

  const CreateEventPage({super.key, required this.communityId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
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
  int? dateTime;
  FirebaseProvider fp=FirebaseProvider();

  // Function to select Date and Time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
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
           dateTime = selectedDateTime.microsecondsSinceEpoch;
          _dateTimeController.text =
              "${formattedDate(dateTime!)} ${formattedTime(dateTime!)}";
        });
      }
    }
  }

  File? _image;
  void selectImage() async {
    _image = await pickImage(context);
    setState(() {});
  }
  // Function to create event and store it in Firebase

  Future<void> _createEvent() async {
    if (_nameController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _dateTimeController.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _theme.text.isNotEmpty &&
        (_days.text.isNotEmpty || _hours.text.isNotEmpty || (_hours.text.isNotEmpty && _minutes.text.isNotEmpty)) &&
        _name2Controller.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      try {
        String googleFormLink = _googleFormLinkController.text.trim();
        if (googleFormLink.isNotEmpty && !Uri.tryParse(googleFormLink)!.hasAbsolutePath) {
          showSnackBar(context, "Invalid Google Form link");
          return;
        }

        SharedPreferencesProvider sp=SharedPreferencesProvider();
        String userId=sp.currentUid;
        String communityId = widget.communityId;
        

        // Prepare the event data
        Map<String, dynamic> eventData = {
          'title': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'location': _locationController.text.trim(),
          'dateTime': dateTime, // Use current time or set specific time
          'created_by': userId,
          'community_id': communityId,
          'price': int.parse(_price.text.trim()), // Example price
          'peopleRegistered': 0, // Example number of people registered
          'theme': _theme.text, // Example theme
          'postTime': DateTime.now().microsecondsSinceEpoch,
          'googleFormUrl': googleFormLink,
          'duration': {
            'days': int.tryParse(_days.text) ?? 0,
            'hours': int.tryParse(_hours.text) ?? 0,
            'minutes': int.tryParse(_minutes.text) ?? 0,
          },
          "contacts": {
            "name": _name2Controller.text.trim(),
            "email": _emailController.text.trim(),
            "phone": int.parse(_phoneController.text.trim())
          }

          // Example duration in hours
        };
        print(DateTime.now().millisecondsSinceEpoch);

        // If image is selected, upload it to Firebase Storage and add the URL
        String? imageUrl;
        if (_image != null) {
          //File imageFile = File(_filePickerResult!.files.first.path!);
          await fp.uploadImageToStorage("event", _image!).then((url)=> imageUrl=url);
        }

        // Add image URL to the event data if available
        if (imageUrl != null) {
          eventData['imageUrl'] = imageUrl;
        }

        // Store event data in Firestore
        await fp.createEvent(eventData);

        showSnackBar(context, "Event Created!");
        Map<String,dynamic> community={};
        await fp.fetchCommunity(widget.communityId).then((c)=>community=c);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => CommunityScreen(community: community, isOwner: true,)),
          (route) => false,
        );
      } catch (e) {
        print(e);
        showSnackBar(context, "Failed to create event");
      }
    } else {
      showSnackBar(context, "All details are required");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: selectImage,
              child: Container(
                width: double.infinity,
                height: _image != null
                    ? MediaQuery.of(context).size.height * .3
                    : 60,
                decoration: BoxDecoration(
                  // color: Colors.green[100],
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          //File(_filePickerResult!.files.first.path!),
                          _image!,
                          fit: BoxFit.fill,
                        ),
                      )
                    : Row(
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
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      controller: _days,
                      icon: Icons.lock_clock_outlined,
                      label: "days",
                      hint: "Enter number of days",
                      keyboardType: TextInputType.number
                      // readOnly: true,
                      ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: _buildTextField(
                    controller: _hours,
                    icon: Icons.lock_clock_outlined,
                    label: "hours",
                    hint: "Enter number of hours",
                    keyboardType: TextInputType.number,
                    // readOnly: true,
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: _buildTextField(
                    controller: _minutes,
                    icon: Icons.lock_clock_outlined,
                    label: "Minutes",
                    hint: "Enter number of minutes",
                    keyboardType: TextInputType.number,
                    // readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _price,
              icon: Icons.money_rounded,
              label: "Price",
              hint: "Registration cost",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _name2Controller,
                icon: Icons.account_circle,
                label: "Contact Name",
                hint: "Enter Contact Name"),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _phoneController,
                icon: Icons.phone,
                label: 'Phone',
                hint: 'Enter contact phone number',
                keyboardType: TextInputType.number,
                onEditingComplete: () {
                var value=_phoneController.text.trim();
                if (value.trim().isEmpty) {
                  showSnackBar(context, 'Phone number is required') ;
                }
                if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                  showSnackBar(context, 'Enter a valid phone number');
                }
              },
                ),
            const SizedBox(height: 8),
            _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                label: "Email",
                hint: "Enter Contact Email",
                keyboardType: TextInputType.emailAddress,
                onEditingComplete: () {
                var value=_emailController.text.trim();
                if (value.trim().isEmpty) {
                  showSnackBar(context, 'Email is required') ;
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  showSnackBar(context, 'Enter a valid email address') ;
                }
              },
                ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _googleFormLinkController,
              icon: Icons.link,
              label: "Google Form",
              hint: "Enter the Google Form URL for registration",
              keyboardType: TextInputType.url,
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
    int minLines = 1,
    bool readOnly = false,
    GestureTapCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    void Function()? onEditingComplete,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onEditingComplete: onEditingComplete,
      maxLines: maxLines,
      minLines: minLines,
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
