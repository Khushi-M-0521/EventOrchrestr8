import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommunityForm extends StatefulWidget {
  @override
  _CommunityFormState createState() => _CommunityFormState();
}

class _CommunityFormState extends State<CommunityForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Number of members will be set to 0 by default
  final int _members = 0;

  // Variable to hold the selected image
  File? _image;

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _taglineController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _image = File(image.path); // Store the picked image as File
      }
    });
  }

  Future<void> _createCommunity() async {
    if (_nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _taglineController.text.isNotEmpty &&
        _tagsController.text.isNotEmpty &&
        _image != null) {
      try {
        // Fetch the current user UID
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String userId = user.uid; // Get the current user ID

          // Upload the image to Firebase Storage and get the URL
          String imageUrl = await _uploadImageToStorage();

          // Add community data to Firestore along with the user ID
          await firestore.collection('communities').add({
            'name': _nameController.text,
            'description': _descriptionController.text,
            'members': _members,
            'tagline': _taglineController.text,
            'tags': _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .toList(),
            'created_at': FieldValue.serverTimestamp(),
            'created_by': userId, // Store the user ID who created the community
            'imageUrl': imageUrl, // Store image URL
            'joined_by': null, // Add joined_by field with null value initially
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Community Created!")),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not authenticated")),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create Community")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing details or no image selected")),
      );
    }
  }

  Future<String> _uploadImageToStorage() async {
    // Create a unique name for the image
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = storage.ref().child('community_images/$fileName');

    // Upload the image to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(_image!);

    // Wait for the upload to complete
    TaskSnapshot snapshot = await uploadTask;

    // Get the image URL after upload
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Create Community",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Text(
                    "Community Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Image picker button
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200, // Increased height for better visibility
                      width: double.infinity, // Make it occupy full width
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors
                            .grey[200], // Background color for better contrast
                      ),
                      child: _image == null
                          ? Center(
                              child: Text(
                                'Pick an image',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                              child: Image.file(
                                _image!,
                                width:
                                    double.infinity, // Fit to container width
                                height: 200, // Fit to container height
                                fit: BoxFit
                                    .cover, // Ensure the image scales properly
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20),
                  _buildTextField(
                    label: 'Community Name',
                    icon: Icons.group,
                    borderColor: borderColor,
                    controller: _nameController,
                  ),
                  _buildTextField(
                    label: 'Tagline',
                    icon: Icons.short_text,
                    borderColor: borderColor,
                    controller: _taglineController,
                  ),
                  _buildTextField(
                    label: 'Tags (comma-separated)',
                    icon: Icons.label,
                    borderColor: borderColor,
                    controller: _tagsController,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _createCommunity,
                    icon: Icon(Icons.check),
                    label: Text('Create Community'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color borderColor,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon, color: Theme.of(context).colorScheme.onSurface),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
