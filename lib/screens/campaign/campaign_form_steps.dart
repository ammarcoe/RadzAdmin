import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../components/custom_text_field.dart';
import '../../components/custom_dropdown.dart';
import '../../components/section_header.dart';
import 'campaign_data_model.dart';

class CampaignFormSteps {
  static Widget buildBasicInfoStep({
    required TextEditingController campaignNameController,
    required TextEditingController companyNameController,
    required TextEditingController descriptionController,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Campaign Name',
                  icon: Icons.campaign,
                  controller: campaignNameController,
                  validator: (v) => v?.isEmpty == true ? 'Campaign name is required' : null,
                  hintText: 'e.g., Shan Spices – Summer Promo',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: CustomTextField(
                  label: 'Company Name',
                  icon: Icons.business,
                  controller: companyNameController,
                  validator: (v) => v?.isEmpty == true ? 'Company name is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Description',
            icon: Icons.description,
            controller: descriptionController,
            validator: (v) => v?.isEmpty == true ? 'Description is required' : null,
            maxLines: 4,
            hintText: 'Brief description about the campaign objectives and target audience',
          ),
        ],
      ),
    );
  }

  static Widget buildCreativeAssetsStep({
    required Uint8List? selectedImageBytes,
    required String? selectedImageName,
    required VoidCallback onPickImage,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Area
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onPickImage,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2A2A2A),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              selectedImageBytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFFD7FE2D),
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upload Campaign Creative',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Click to browse and select your image',
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PNG, JPG up to 10MB',
                                  style: GoogleFonts.inter(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Guidelines
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7FE2D).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tips_and_updates,
                              color: Color(0xFFD7FE2D),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Design Guidelines',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildGuidelineItem('High resolution (minimum 1080x1080px)'),
                      _buildGuidelineItem('Clear, readable text and logos'),
                      _buildGuidelineItem('Bright, eye-catching colors'),
                      _buildGuidelineItem('Include contact information'),
                      _buildGuidelineItem('Avoid copyrighted content'),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help with design?',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our design team can help create professional campaign materials for an additional fee.',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFD7FE2D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTargetingStep({
    required String? selectedCity,
    required String? selectedVehicleType,
    required TextEditingController vehicleCountController,
    required Function(String?) onCityChanged,
    required Function(String?) onVehicleTypeChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdown(
                  label: 'Target City',
                  icon: Icons.location_city,
                  value: selectedCity,
                  items: CampaignDataModel.cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: onCityChanged,
                  validator: (v) => v == null ? 'Please select a city' : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: CustomDropdown(
                  label: 'Vehicle Type',
                  icon: Icons.directions_car,
                  value: selectedVehicleType,
                  items: CampaignDataModel.vehicleTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: onVehicleTypeChanged,
                  validator: (v) => v == null ? 'Please select vehicle type' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Number of Vehicles',
            icon: Icons.confirmation_number,
            controller: vehicleCountController,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v?.isEmpty == true) return 'Vehicle count is required';
              if (int.tryParse(v!) == null) return 'Please enter a valid number';
              return null;
            },
            hintText: 'e.g., 50',
          ),
        ],
      ),
    );
  }

  static Widget buildCampaignSettingsStep({
    required TextEditingController budgetController,
    required TextEditingController durationController,
    required TextEditingController payoutRateController,
    required bool featuredCampaign,
    required Function(bool) onFeaturedChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Budget (PKR)',
                  icon: Icons.attach_money,
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Budget is required';
                    if (double.tryParse(v!) == null) return 'Please enter a valid amount';
                    return null;
                  },
                  hintText: 'e.g., 50000',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: CustomTextField(
                  label: 'Duration (days)',
                  icon: Icons.calendar_today,
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Duration is required';
                    if (int.tryParse(v!) == null) return 'Please enter a valid number';
                    return null;
                  },
                  hintText: 'e.g., 30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Payout Rate per Vehicle (PKR) - Optional',
            icon: Icons.payments,
            controller: payoutRateController,
            keyboardType: TextInputType.number,
            hintText: 'e.g., 1000',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: featuredCampaign 
                        ? const Color(0xFFD7FE2D).withOpacity(0.2)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star,
                    color: featuredCampaign 
                        ? const Color(0xFFD7FE2D)
                        : Colors.white60,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Campaign',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Get priority placement and increased visibility (+25% cost)',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: featuredCampaign,
                  onChanged: onFeaturedChanged,
                  activeColor: const Color(0xFFD7FE2D),
                  activeTrackColor: const Color(0xFFD7FE2D).withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFiltersStep({
    required String? selectedCategory,
    required Function(String?) onCategoryChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Campaign Category',
            icon: Icons.category,
            value: selectedCategory,
            items: CampaignDataModel.categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: onCategoryChanged,
            validator: (v) => v == null ? 'Please select a category' : null,
          ),
        ],
      ),
    );
  }

  static Widget buildLogisticsStep({
    required String? selectedDeliveryMethod,
    required Function(String?) onDeliveryMethodChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Delivery Method',
            icon: Icons.local_shipping,
            value: selectedDeliveryMethod,
            items: CampaignDataModel.deliveryMethods.map((String method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: onDeliveryMethodChanged,
            validator: (v) => v == null ? 'Please select delivery method' : null,
          ),
        ],
      ),
    );
  }

  static Widget buildProofVerificationStep({
    required bool gpsTracking,
    required bool photoVerification,
    required String? reportingFrequency,
    required Function(bool) onGpsTrackingChanged,
    required Function(bool) onPhotoVerificationChanged,
    required Function(String?) onReportingFrequencyChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerificationOption(
            title: 'GPS Tracking',
            description: 'Track vehicle locations during campaign',
            icon: Icons.gps_fixed,
            value: gpsTracking,
            onChanged: onGpsTrackingChanged,
          ),
          const SizedBox(height: 20),
          _buildVerificationOption(
            title: 'Photo Verification',
            description: 'Require drivers to submit installation photos',
            icon: Icons.camera_alt,
            value: photoVerification,
            onChanged: onPhotoVerificationChanged,
          ),
          const SizedBox(height: 32),
          CustomDropdown(
            label: 'Reporting Frequency',
            icon: Icons.schedule,
            value: reportingFrequency,
            items: CampaignDataModel.reportingOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onReportingFrequencyChanged,
          ),
        ],
      ),
    );
  }

  static Widget _buildVerificationOption({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: value 
                  ? const Color(0xFFD7FE2D).withOpacity(0.2)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value 
                  ? const Color(0xFFD7FE2D)
                  : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD7FE2D),
            activeTrackColor: const Color(0xFFD7FE2D).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  static Widget buildPaymentStep({
    required String? selectedPaymentMethod,
    required TextEditingController billingAddressController,
    required Function(String?) onPaymentMethodChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Payment Method',
            icon: Icons.payment,
            value: selectedPaymentMethod,
            items: CampaignDataModel.paymentMethods.map((String method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: onPaymentMethodChanged,
            validator: (v) => v == null ? 'Please select payment method' : null,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Billing Address',
            icon: Icons.location_on,
            controller: billingAddressController,
            validator: (v) => v?.isEmpty == true ? 'Billing address is required' : null,
            maxLines: 3,
            hintText: 'Enter complete billing address',
          ),
        ],
      ),
    );
  }

  static Widget buildReviewStep({
    required String campaignName,
    required String companyName,
    required String description,
    required String budget,
    required String duration,
    required String? selectedCity,
    required String? selectedVehicleType,
    required String vehicleCount,
    required String? selectedCategory,
    required String? selectedDeliveryMethod,
    required String? selectedPaymentMethod,
    required bool featuredCampaign,
    required bool gpsTracking,
    required bool photoVerification,
    required String? reportingFrequency,
    required String billingAddress,
    Uint8List? selectedImageBytes,
    String? selectedImageName,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Campaign Summary',
            icon: Icons.summarize,
          ),
          const SizedBox(height: 24),
          _buildReviewSection('Basic Information', [
            _buildReviewItem('Campaign Name', campaignName),
            _buildReviewItem('Company Name', companyName),
            _buildReviewItem('Description', description),
          ]),
          const SizedBox(height: 24),
          _buildReviewSection('Budget & Duration', [
            _buildReviewItem('Budget', 'PKR $budget'),
            _buildReviewItem('Duration', '$duration days'),
            _buildReviewItem('Featured Campaign', featuredCampaign ? 'Yes' : 'No'),
          ]),
          const SizedBox(height: 24),
          _buildReviewSection('Targeting', [
            _buildReviewItem('Target City', selectedCity ?? 'Not selected'),
            _buildReviewItem('Vehicle Type', selectedVehicleType ?? 'Not selected'),
            _buildReviewItem('Vehicle Count', vehicleCount),
          ]),
          const SizedBox(height: 24),
          _buildReviewSection('Campaign Details', [
            _buildReviewItem('Category', selectedCategory ?? 'Not selected'),
            _buildReviewItem('Delivery Method', selectedDeliveryMethod ?? 'Not selected'),
            _buildReviewItem('Payment Method', selectedPaymentMethod ?? 'Not selected'),
          ]),
          const SizedBox(height: 24),
          _buildReviewSection('Verification & Tracking', [
            _buildReviewItem('GPS Tracking', gpsTracking ? 'Enabled' : 'Disabled'),
            _buildReviewItem('Photo Verification', photoVerification ? 'Enabled' : 'Disabled'),
            _buildReviewItem('Reporting Frequency', reportingFrequency ?? 'Not selected'),
          ]),
          const SizedBox(height: 24),
          _buildReviewSection('Billing', [
            _buildReviewItem('Billing Address', billingAddress),
          ]),
          if (selectedImageBytes != null) ...[
            const SizedBox(height: 24),
            _buildReviewSection('Creative Asset', [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    selectedImageBytes,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  static Widget _buildReviewSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CreativeAssetsStep extends StatelessWidget {
  const CreativeAssetsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creative Assets',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Image upload functionality has been temporarily disabled.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: const Color(0xFF718096),
              ),
              const SizedBox(height: 16),
              Text(
                'Image Upload Disabled',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Image upload functionality is temporarily unavailable.\nYou can proceed without uploading images.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}