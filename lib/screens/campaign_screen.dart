import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:radzadmin/screens/campaign/campaign_data_model.dart';
import 'package:radzadmin/screens/campaign/campaign_form_steps.dart';
import 'dart:typed_data';
import '../../components/custom_button.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _campaignNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _payoutRateController = TextEditingController();
  final _vehicleCountController = TextEditingController();
  final _billingAddressController = TextEditingController();

  // Dropdown values
  String? _selectedCity;
  String? _selectedVehicleType;
  String? _selectedCategory;
  String? _selectedDeliveryMethod;
  String? _selectedPaymentMethod;
  String? _reportingFrequency;

  // Boolean values
  bool _featuredCampaign = false;
  bool _gpsTracking = false;
  bool _photoVerification = false;
  // bool _gpsTracking = true;
  // bool _photoVerification = true;
  // String? _reportingFrequency = 'daily';

  // Updated image handling for file_picker
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void dispose() {
    _campaignNameController.dispose();
    _companyNameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _payoutRateController.dispose();
    _vehicleCountController.dispose();
    _billingAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes!;
        _selectedImageName = result.files.single.name;
      });
    }
  }

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CampaignDataModel.submitCampaign(
        campaignName: _campaignNameController.text,
        companyName: _companyNameController.text,
        description: _descriptionController.text,
        budget: double.parse(_budgetController.text),
        duration: int.parse(_durationController.text),
        payoutRate: _payoutRateController.text.isNotEmpty 
            ? double.parse(_payoutRateController.text) 
            : null,
        vehicleCount: int.parse(_vehicleCountController.text),
        targetCity: _selectedCity,
        vehicleType: _selectedVehicleType,
        category: _selectedCategory,
        deliveryMethod: _selectedDeliveryMethod,
        paymentMethod: _selectedPaymentMethod,
        featuredCampaign: _featuredCampaign,
        gpsTracking: _gpsTracking,
        photoVerification: _photoVerification,
        reportingFrequency: _reportingFrequency,
        billingAddress: _billingAddressController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Campaign submitted successfully!',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 8) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  IconData _getStepIcon(String iconName) {
    switch (iconName) {
      case 'info_outline': return Icons.info_outline;
      case 'image': return Icons.image;
      case 'my_location': return Icons.my_location;
      case 'settings': return Icons.settings;
      case 'filter_alt': return Icons.filter_alt;
      case 'local_shipping': return Icons.local_shipping;
      case 'verified': return Icons.verified;
      case 'payment': return Icons.payment;
      case 'check_circle': return Icons.check_circle;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Left Sidebar - Step Navigation
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F0F),
              border: Border(
                right: BorderSide(color: Color(0xFF2A2A2A)),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Campaign',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Step ${_currentStep + 1} of ${CampaignDataModel.steps.length}',
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Steps List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: CampaignDataModel.steps.length,
                    itemBuilder: (context, index) {
                      final step = CampaignDataModel.steps[index];
                      final isActive = index == _currentStep;
                      final isCompleted = index < _currentStep;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _currentStep = index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? const Color(0xFFD7FE2D).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive 
                                      ? const Color(0xFFD7FE2D)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color(0xFFD7FE2D)
                                          : isActive
                                              ? const Color(0xFFD7FE2D).withOpacity(0.2)
                                              : const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isCompleted ? Icons.check : _getStepIcon(step['icon']),
                                      color: isCompleted
                                          ? Colors.black
                                          : isActive
                                              ? const Color(0xFFD7FE2D)
                                              : Colors.white60,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step['title'],
                                          style: GoogleFonts.inter(
                                            color: isActive
                                                ? Colors.white
                                                : Colors.white70,
                                            fontSize: 16,
                                            fontWeight: isActive
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          step['description'],
                                          style: GoogleFonts.inter(
                                            color: Colors.white60,
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              CampaignDataModel.steps[_currentStep]['title'],
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              CampaignDataModel.steps[_currentStep]['description'],
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Progress Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentStep + 1}/${CampaignDataModel.steps.length}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD7FE2D),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Form(
                      key: _formKey,
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                // Bottom Navigation
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F0F0F),
                    border: Border(
                      top: BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            text: 'Previous',
                            onPressed: _previousStep,
                            backgroundColor: const Color(0xFF2A2A2A),
                            textColor: Colors.white,
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: _currentStep == 8 ? 'Submit Campaign' : 'Next Step',
                            onPressed: _currentStep == 8 ? _submitCampaign : _nextStep,
                            isLoading: _isLoading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return CampaignFormSteps.buildBasicInfoStep(
          campaignNameController: _campaignNameController,
          companyNameController: _companyNameController,
          descriptionController: _descriptionController,
        );
      case 1:
        return CampaignFormSteps.buildCreativeAssetsStep(
          selectedImageBytes: _selectedImageBytes,
          selectedImageName: _selectedImageName,
          onPickImage: _pickImage,
        );
      case 2:
        return CampaignFormSteps.buildTargetingStep(
          selectedCity: _selectedCity,
          selectedVehicleType: _selectedVehicleType,
          vehicleCountController: _vehicleCountController,
          onCityChanged: (value) => setState(() => _selectedCity = value),
          onVehicleTypeChanged: (value) => setState(() => _selectedVehicleType = value),
        );
      case 3:
        return CampaignFormSteps.buildCampaignSettingsStep(
          budgetController: _budgetController,
          durationController: _durationController,
          payoutRateController: _payoutRateController,
          featuredCampaign: _featuredCampaign,
          onFeaturedChanged: (value) => setState(() => _featuredCampaign = value),
        );
      case 4:
        return CampaignFormSteps.buildFiltersStep(
          selectedCategory: _selectedCategory,
          onCategoryChanged: (value) => setState(() => _selectedCategory = value),
        );
      case 5:
        return CampaignFormSteps.buildLogisticsStep(
          selectedDeliveryMethod: _selectedDeliveryMethod,
          onDeliveryMethodChanged: (value) => setState(() => _selectedDeliveryMethod = value),
        );
      case 6:
        return CampaignFormSteps.buildProofVerificationStep(
          gpsTracking: _gpsTracking,
          photoVerification: _photoVerification,
          reportingFrequency: _reportingFrequency,
          onGpsTrackingChanged: (value) => setState(() => _gpsTracking = value),
          onPhotoVerificationChanged: (value) => setState(() => _photoVerification = value),
          onReportingFrequencyChanged: (value) => setState(() => _reportingFrequency = value),
        );
      case 7:
        return CampaignFormSteps.buildPaymentStep(
          selectedPaymentMethod: _selectedPaymentMethod,
          billingAddressController: _billingAddressController,
          onPaymentMethodChanged: (value) => setState(() => _selectedPaymentMethod = value),
        );
      case 8:
        return CampaignFormSteps.buildReviewStep(
          campaignName: _campaignNameController.text,
          companyName: _companyNameController.text,
          description: _descriptionController.text,
          budget: _budgetController.text,
          duration: _durationController.text,
          selectedCity: _selectedCity,
          selectedVehicleType: _selectedVehicleType,
          vehicleCount: _vehicleCountController.text,
          selectedCategory: _selectedCategory,
          selectedDeliveryMethod: _selectedDeliveryMethod,
          selectedPaymentMethod: _selectedPaymentMethod,
          featuredCampaign: _featuredCampaign,
          gpsTracking: _gpsTracking,
          photoVerification: _photoVerification,
          reportingFrequency: _reportingFrequency,
          billingAddress: _billingAddressController.text,
          selectedImageBytes: _selectedImageBytes,
          selectedImageName: _selectedImageName,
        );
      default:
        return CampaignFormSteps.buildBasicInfoStep(
          campaignNameController: _campaignNameController,
          companyNameController: _companyNameController,
          descriptionController: _descriptionController,
        );
    }
  }
}