import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventorchestr8/provider/firebase_provider.dart';
import 'package:eventorchestr8/provider/shared_preferences_provider.dart';
import 'package:eventorchestr8/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class CommunityForm extends StatefulWidget {
  const CommunityForm({super.key});

  @override
  State<CommunityForm> createState() => _CommunityFormState();
}

class _CommunityFormState extends State<CommunityForm> {
  final _formKey = GlobalKey<FormState>();
  late FirebaseProvider fp;
  var isLoading = false;

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
  void initState() {
    fp = FirebaseProvider();
    isLoading =
        Provider.of<SharedPreferencesProvider>(context, listen: true).isLoading;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _taglineController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void selectImage() async {
    _image = await pickImage(context);
    setState(() {});
  }

  Future<void> _createCommunity() async {
    setState(() {
      isLoading = true;
    });
    if (_nameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _taglineController.text.isNotEmpty &&
        _tagsController.text.isNotEmpty &&
        _image != null) {
      try {
        // Fetch the current user UID
        // Get the current user ID
        SharedPreferencesProvider sp = SharedPreferencesProvider();
        String userId = sp.currentUid;

        // Upload the image to Firebase Storage and get the URL
        String imageUrl = await fp.uploadImageToStorage("community", _image!);

        // Add community data to Firestore along with the user ID
        fp
            .createCommunity({
              'name': _nameController.text,
              'description': _descriptionController.text,
              'members': _members,
              'tagline': _taglineController.text,
              'tags': _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .toList(),
              'created_at': FieldValue.serverTimestamp(),
              'created_by':
                  userId, // Store the user ID who created the community
              'imageUrl': imageUrl, // Store image URL
              'joined_by':
                  null, // Add joined_by field with null value initially
            })
            .timeout(Duration(seconds: 10))
            .then((_) {
              showSnackBar(context, "Community Created!");
              setState(() {
                isLoading = false;
              });
              Navigator.of(context).pop();
            });
      } catch (e) {
        showSnackBar(context, "Failed to create Community $e");
      }
    } else {
      showSnackBar(context, "Missing details or no image selected");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).colorScheme.outline;
    print("isloading= " + isLoading.toString());
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: Text(
          "Create Community",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                          onTap: selectImage,
                          child: Container(
                            height: _image == null
                                ? 50
                                : 200, // Increased height for better visibility
                            width: double.infinity, // Make it occupy full width
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[
                                  200], // Background color for better contrast
                            ),
                            child: _image == null
                                ? Center(
                                    child: Text(
                                      'Pick an image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                    child: Image.file(
                                      _image!,
                                      width: double
                                          .infinity, // Fit to container width
                                      height: 200, // Fit to container height
                                      fit: BoxFit
                                          .fill, // Ensure the image scales properly
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
                          minLines: 1,
                          maxLines: 4,
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _createCommunity,
                          icon: Icon(Icons.check),
                          label: Text('Create Community'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
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
