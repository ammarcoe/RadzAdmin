import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/custom_text_field.dart';
import '../../components/custom_button.dart';
import '../../components/section_header.dart';
import '../campaign/campaign_data_model.dart';

class AdminModuleScreen extends StatefulWidget {
  const AdminModuleScreen({Key? key}) : super(key: key);

  @override
  State<AdminModuleScreen> createState() => _AdminModuleScreenState();
}

class _AdminModuleScreenState extends State<AdminModuleScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers for adding new categories
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryPriceController = TextEditingController();
  final TextEditingController _maxPlacementsController = TextEditingController();
  
  // Local state for categories
  Map<String, double> vehicleCategories = Map.from(CampaignDataModel.vehicleCategories);
  Map<String, double> apparelCategories = Map.from(CampaignDataModel.apparelCategories);
  List<String> campaignTypes = List.from(CampaignDataModel.campaignTypes);
  int maxPlacements = CampaignDataModel.maxPlacementsPerCampaign;
  
  String selectedCategoryType = 'Vehicle';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _maxPlacementsController.text = maxPlacements.toString();
    _loadAdminSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryNameController.dispose();
    _categoryPriceController.dispose();
    _maxPlacementsController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('campaign_config')
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          if (data['vehicleCategories'] != null) {
            vehicleCategories = Map<String, double>.from(data['vehicleCategories']);
          }
          if (data['apparelCategories'] != null) {
            apparelCategories = Map<String, double>.from(data['apparelCategories']);
          }
          if (data['campaignTypes'] != null) {
            campaignTypes = List<String>.from(data['campaignTypes']);
          }
          if (data['maxPlacements'] != null) {
            maxPlacements = data['maxPlacements'];
            _maxPlacementsController.text = maxPlacements.toString();
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading settings: $e');
    }
  }

  Future<void> _saveAdminSettings() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('admin_settings')
          .doc('campaign_config')
          .set({
        'vehicleCategories': vehicleCategories,
        'apparelCategories': apparelCategories,
        'campaignTypes': campaignTypes,
        'maxPlacements': maxPlacements,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _showSuccessSnackBar('Settings saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Error saving settings: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addCategory() {
    if (_categoryNameController.text.trim().isEmpty || 
        _categoryPriceController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    final name = _categoryNameController.text.trim();
    final price = double.tryParse(_categoryPriceController.text.trim());
    
    if (price == null || price <= 0) {
      _showErrorSnackBar('Please enter a valid price');
      return;
    }

    setState(() {
      if (selectedCategoryType == 'Vehicle') {
        vehicleCategories[name] = price;
      } else {
        apparelCategories[name] = price;
      }
    });

    _categoryNameController.clear();
    _categoryPriceController.clear();
    _showSuccessSnackBar('Category added successfully!');
  }

  void _removeCategory(String category, bool isVehicle) {
    setState(() {
      if (isVehicle) {
        vehicleCategories.remove(category);
      } else {
        apparelCategories.remove(category);
      }
    });
    _showSuccessSnackBar('Category removed successfully!');
  }

  void _updateCategoryPrice(String category, bool isVehicle, double newPrice) {
    setState(() {
      if (isVehicle) {
        vehicleCategories[category] = newPrice;
      } else {
        apparelCategories[category] = newPrice;
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Admin Module Management',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD7FE2D),
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFD7FE2D),
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Pricing'),
            Tab(text: 'Capacity'),
            Tab(text: 'Campaign Types'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CustomButton(
              text: 'Save Changes',
              onPressed: isLoading ? null : _saveAdminSettings,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriesTab(),
          _buildPricingTab(),
          _buildCapacityTab(),
          _buildCampaignTypesTab(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Manage Ad Categories',
            subtitle: 'Add, edit, or remove vehicle and apparel categories',
            icon: Icons.category,
          ),
          const SizedBox(height: 32),
          
          // Add new category section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Category',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategoryType,
                        decoration: InputDecoration(
                          labelText: 'Category Type',
                          labelStyle: GoogleFonts.inter(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD7FE2D)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: GoogleFonts.inter(color: Colors.white),
                        items: ['Vehicle', 'Apparel'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCategoryType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Category Name',
                        icon: Icons.label,
                        controller: _categoryNameController,
                        hintText: 'e.g., Car, Helmet',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Price (PKR)',
                        icon: Icons.attach_money,
                        controller: _categoryPriceController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g., 3000',
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomButton(
                      text: 'Add',
                      onPressed: _addCategory,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Vehicle Categories
          _buildCategorySection('Vehicle Categories', vehicleCategories, true),
          
          const SizedBox(height: 32),
          
          // Apparel Categories
          _buildCategorySection('Apparel & Items Categories', apparelCategories, false),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, Map<String, double> categories, bool isVehicle) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 20),
          ...categories.entries.map((entry) => _buildCategoryItem(
            entry.key,
            entry.value,
            isVehicle,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double price, bool isVehicle) {
    final TextEditingController priceController = TextEditingController(text: price.toString());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: priceController,
              style: GoogleFonts.inter(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (PKR)',
                labelStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD7FE2D)),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final newPrice = double.tryParse(value);
                if (newPrice != null && newPrice > 0) {
                  _updateCategoryPrice(category, isVehicle, newPrice);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _removeCategory(category, isVehicle),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Pricing Overview',
            subtitle: 'Current pricing structure for all categories',
            icon: Icons.analytics,
          ),
          const SizedBox(height: 32),
          
          // Pricing summary cards
          Row(
            children: [
              Expanded(
                child: _buildPricingCard(
                  'Vehicle Categories',
                  vehicleCategories.length,
                  vehicleCategories.values.isNotEmpty 
                      ? vehicleCategories.values.reduce((a, b) => a + b) / vehicleCategories.length
                      : 0,
                  Icons.directions_car,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildPricingCard(
                  'Apparel Categories',
                  apparelCategories.length,
                  apparelCategories.values.isNotEmpty 
                      ? apparelCategories.values.reduce((a, b) => a + b) / apparelCategories.length
                      : 0,
                  Icons.checkroom,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Detailed pricing table
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Pricing Table',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPricingTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(String title, int count, double avgPrice, IconData icon) {
    return Container(
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7FE2D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFD7FE2D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$count Categories',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avg: PKR ${avgPrice.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              color: const Color(0xFFD7FE2D),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingTable() {
    final allCategories = {...vehicleCategories, ...apparelCategories};
    
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFF2A2A2A),
          ),
          children: [
            _buildTableHeader('Category'),
            _buildTableHeader('Type'),
            _buildTableHeader('Price (PKR)'),
          ],
        ),
        ...allCategories.entries.map((entry) {
          final isVehicle = vehicleCategories.containsKey(entry.key);
          return TableRow(
            children: [
              _buildTableCell(entry.key),
              _buildTableCell(isVehicle ? 'Vehicle' : 'Apparel'),
              _buildTableCell('${entry.value.toStringAsFixed(0)}'),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCapacityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Campaign Capacity Settings',
            subtitle: 'Manage maximum placements and campaign limits',
            icon: Icons.settings,
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maximum Placements per Campaign',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Max Placements',
                        icon: Icons.confirmation_number,
                        controller: _maxPlacementsController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newValue = int.tryParse(value);
                          if (newValue != null && newValue > 0) {
                            setState(() {
                              maxPlacements = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Current Limit',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$maxPlacements',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFD7FE2D),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        'Campaign Duration Limits',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Minimum: ${CampaignDataModel.minCampaignDurationMonths} month(s)',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Maximum: ${CampaignDataModel.maxCampaignDurationMonths} month(s)',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
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

  Widget _buildCampaignTypesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Campaign Types Management',
            subtitle: 'Manage available campaign categories',
            icon: Icons.business,
          ),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Campaign Types',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: campaignTypes.map((type) => _buildCampaignTypeChip(type)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                campaignTypes.remove(type);
              });
            },
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}