import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class CampaignDataModel {
  // Static data lists
  static const List<String> cities = [
    'Islamabad',
    'Rawalpindi',
    'Lahore',
    'Karachi',
    'Peshawar',
    'Quetta',
  ];

  static const List<String> vehicleTypes = [
    'Car',
    'SUV',
    'Bike',
    'Rickshaw',
  ];

  static const List<String> categories = [
    'Food & Beverages',
    'Telecom',
    'Retail',
    'Technology',
    'Healthcare',
    'Education',
    'Real Estate',
    'Fashion',
  ];

  static const List<String> deliveryMethods = [
    'Courier to Drivers',
    'Pickup at Partner Print Shop',
    'Installation at Driver Location',
  ];

  static const List<String> paymentMethods = [
    'JazzCash',
    'Easypaisa',
    'Bank Transfer',
    'Stripe (Card)',
  ];

  static const List<String> reportingOptions = [
    'daily',
    'weekly',
    'bi-weekly',
  ];

  static const List<Map<String, dynamic>> steps = [
    {'title': 'Basic Info', 'icon': 'info_outline', 'description': 'Campaign details'},
    {'title': 'Creative Assets', 'icon': 'image', 'description': 'Upload designs'},
    {'title': 'Targeting', 'icon': 'my_location', 'description': 'Audience & vehicles'},
    {'title': 'Settings', 'icon': 'settings', 'description': 'Budget & duration'},
    {'title': 'Filters', 'icon': 'filter_alt', 'description': 'Category & compliance'},
    {'title': 'Logistics', 'icon': 'local_shipping', 'description': 'Delivery method'},
    {'title': 'Verification', 'icon': 'verified', 'description': 'Proof & tracking'},
    {'title': 'Payment', 'icon': 'payment', 'description': 'Billing details'},
    {'title': 'Review', 'icon': 'check_circle', 'description': 'Final review'},
  ];

  // Upload image to Firebase Storage
  static Future<String?> _uploadImageToStorage(Uint8List imageBytes, String fileName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Error: User not authenticated');
        return null;
      }

      // Validate image data
      if (imageBytes.isEmpty) {
        print('Error: Image data is empty');
        return null;
      }

      final fileExtension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      
      if (!allowedExtensions.contains(fileExtension)) {
        print('Error: Unsupported file format: $fileExtension');
        return null;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('campaign_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/$fileExtension',
          customMetadata: {
            'uploadedBy': user.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static const List<Map<String, String>> campaignSteps = [
    {'title': 'Basic Info', 'icon': 'info', 'description': 'Campaign details'},
    {'title': 'Creative Assets', 'icon': 'image', 'description': 'Upload designs'},
    {'title': 'Targeting', 'icon': 'location_on', 'description': 'Location & audience'},
    {'title': 'Settings', 'icon': 'settings', 'description': 'Campaign settings'},
    {'title': 'Filters', 'icon': 'filter_list', 'description': 'Vehicle filters'},
    {'title': 'Logistics', 'icon': 'local_shipping', 'description': 'Delivery method'},
    {'title': 'Verification', 'icon': 'verified', 'description': 'Proof & tracking'},
    {'title': 'Payment', 'icon': 'payment', 'description': 'Billing details'},
    {'title': 'Review', 'icon': 'check_circle', 'description': 'Final review'},
  ];

  // Campaign data submission
  static Future<void> submitCampaign({
    required String campaignName,
    required String companyName,
    required String description,
    required double budget,
    required int duration,
    double? payoutRate,
    required int vehicleCount,
    String? targetCity,
    String? vehicleType,
    String? category,
    String? deliveryMethod,
    String? paymentMethod,
    required bool featuredCampaign,
    required bool gpsTracking,
    required bool photoVerification,
    String? reportingFrequency,
    required String billingAddress,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Validate required fields
      if (campaignName.trim().isEmpty) {
        throw Exception('Campaign name is required');
      }
      if (companyName.trim().isEmpty) {
        throw Exception('Company name is required');
      }
      if (description.trim().isEmpty) {
        throw Exception('Description is required');
      }
      if (budget <= 0) {
        throw Exception('Budget must be greater than 0');
      }
      if (duration <= 0) {
        throw Exception('Duration must be greater than 0');
      }
      if (vehicleCount <= 0) {
        throw Exception('Vehicle count must be greater than 0');
      }
      if (billingAddress.trim().isEmpty) {
        throw Exception('Billing address is required');
      }

      final campaignData = {
        'campaignName': campaignName.trim(),
        'companyName': companyName.trim(),
        'description': description.trim(),
        'budget': budget,
        'duration': duration,
        'payoutRate': payoutRate,
        'vehicleCount': vehicleCount,
        'targetCity': targetCity,
        'vehicleType': vehicleType,
        'category': category,
        'deliveryMethod': deliveryMethod,
        'paymentMethod': paymentMethod,
        'featuredCampaign': featuredCampaign,
        'gpsTracking': gpsTracking,
        'photoVerification': photoVerification,
        'reportingFrequency': reportingFrequency,
        'billingAddress': billingAddress.trim(),
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending_approval',
      };

      print('Submitting campaign data to Firestore...');
      await FirebaseFirestore.instance
          .collection('campaigns')
          .add(campaignData);
      
      print('Campaign submitted successfully!');
    } catch (e) {
      print('Error in submitCampaign: $e');
      rethrow; // Re-throw the error so it can be caught by the UI
    }
  }
}