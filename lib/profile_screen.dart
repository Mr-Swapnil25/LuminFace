import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'user_model.dart';
import 'auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final Function(bool) updateTheme;
  final bool isDarkMode;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.updateTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  String _selectedGender = '';
  DateTime? _selectedDate;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _selectedGender = widget.user.gender;
    _selectedDate = widget.user.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
          _isEditing = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error selecting image. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  // Select date of birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.isDarkMode
                ? ColorScheme.dark(
                    primary: AppTheme.orchidPink,
                    onPrimary: Colors.white,
                    surface: AppTheme.softCharcoal,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppTheme.orchidPink,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppTheme.cocoaGray,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.orchidPink,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isEditing = true;
      });
    }
  }

  // Save profile changes
  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Name cannot be empty',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Upload profile image if selected
      String? profileImageUrl;
      if (_profileImageFile != null) {
        // In a real app, this would upload to Firebase Storage
        // profileImageUrl = await authService.uploadProfileImage(_profileImageFile!);
        profileImageUrl = 'placeholder_url';
      }
      
      // Update user profile
      await authService.updateUserProfile(
        uid: widget.user.uid,
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
        profileImageUrl: profileImageUrl,
      );
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.orchidPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating profile. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.richBerry,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sign out
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: widget.isDarkMode 
                ? Colors.white70 
                : AppTheme.cocoaGray.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.mauveMist,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
              } catch (e) {
                print('Error signing out: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error signing out. Please try again.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.richBerry,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.richBerry,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // Delete account
  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(
            color: widget.isDarkMode 
                ? Colors.white70 
                : AppTheme.cocoaGray.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.mauveMist,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.deleteAccount();
              } catch (e) {
                print('Error deleting account: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error deleting account. Please try again.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.richBerry,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.richBerry,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: widget.isDarkMode 
            ? AppTheme.softCharcoal 
            : AppTheme.ivoryWhite,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_isEditing)
              IconButton(
                icon: Icon(
                  Icons.check_rounded,
                  color: AppTheme.orchidPink,
                ),
                onPressed: _isLoading ? null : _saveChanges,
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.orchidPink,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildProfileForm(),
                    const SizedBox(height: 24),
                    _buildAppSettings(),
                    const SizedBox(height: 24),
                    _buildAccountActions(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.orchidPink.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _profileImageFile != null || widget.user.profileImageUrl != null
                    ? ClipOval(
                        child: _profileImageFile != null
                            ? Image.file(
                                _profileImageFile!,
                                fit: BoxFit.cover,
                              )
                            : widget.user.profileImageUrl != null
                                ? Image.network(
                                    widget.user.profileImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 60,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.blushNude,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.blushNude.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.email,
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode
                  ? Colors.white70
                  : AppTheme.cocoaGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Born: ${DateFormat('MMMM d, yyyy').format(widget.user.dateOfBirth)}',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDarkMode
                  ? Colors.white70
                  : AppTheme.cocoaGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to edit profile screen in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Profile editing coming soon!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.orchidPink,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            icon: Icon(Icons.edit_outlined),
            label: Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.orchidPink, width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
        ),
        const SizedBox(height: 16),
        // Name field
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.orchidPink),
          ),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
          onChanged: (value) {
            setState(() {
              _isEditing = true;
            });
          },
        ),
        const SizedBox(height: 16),
        // Gender dropdown
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.people_outline_rounded, color: AppTheme.orchidPink),
          ),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
          dropdownColor: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
          items: ['Female', 'Male', 'Non-binary', 'Prefer not to say'].map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedGender = newValue;
                _isEditing = true;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        // Date of birth field
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.orchidPink),
              suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.orchidPink),
            ),
            child: Text(
              _selectedDate != null
                  ? DateFormat('MMMM d, yyyy').format(_selectedDate!)
                  : 'Select date',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
        ),
        const SizedBox(height: 16),
        // Dark mode toggle
        Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.mauveMist.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Switch between light and dark themes',
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white70
                    : AppTheme.cocoaGray.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            value: widget.isDarkMode,
            onChanged: (bool value) {
              widget.updateTheme(value);
            },
            activeColor: AppTheme.orchidPink,
            activeTrackColor: AppTheme.orchidPink.withOpacity(0.3),
            inactiveThumbColor: AppTheme.mauveMist,
            inactiveTrackColor: AppTheme.mauveMist.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 16),
        // Notification settings
        Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.mauveMist.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: SwitchListTile(
            title: Text(
              'Notifications',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Receive beauty tips and reminders',
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white70
                    : AppTheme.cocoaGray.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            value: true, // This would be a user preference in a real app
            onChanged: (bool value) {
              // Update notification settings
            },
            activeColor: AppTheme.orchidPink,
            activeTrackColor: AppTheme.orchidPink.withOpacity(0.3),
            inactiveThumbColor: AppTheme.mauveMist,
            inactiveTrackColor: AppTheme.mauveMist.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.mauveMist.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.blushNude.withOpacity(0.2),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.blushNude,
                size: 20,
              ),
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : AppTheme.cocoaGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: widget.isDarkMode
                  ? Colors.white30
                  : AppTheme.cocoaGray.withOpacity(0.3),
              size: 16,
            ),
            onTap: _signOut,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Color(0xFF252327) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.mauveMist.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.richBerry.withOpacity(0.15),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.richBerry,
                size: 20,
              ),
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(
                color: AppTheme.richBerry,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: widget.isDarkMode
                  ? Colors.white30
                  : AppTheme.cocoaGray.withOpacity(0.3),
              size: 16,
            ),
            onTap: _deleteAccount,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'LuminFace Beauty v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode
                  ? Colors.white30
                  : AppTheme.cocoaGray.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
} 