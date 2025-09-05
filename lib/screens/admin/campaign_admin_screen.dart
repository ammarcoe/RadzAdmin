// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../components/custom_text_field.dart';
// import '../../components/custom_button.dart';
// import '../../components/section_header.dart';
// import '../campaign/campaign_data_model.dart';

// class CampaignAdminScreen extends StatefulWidget {
//   const CampaignAdminScreen({Key? key}) : super(key: key);

//   @override
//   State<CampaignAdminScreen> createState() => _CampaignAdminScreenState();
// }

// class _CampaignAdminScreenState extends State<CampaignAdminScreen> {
//   int _selectedTabIndex = 0;
  
//   // Controllers for adding new categories
//   final TextEditingController _categoryNameController = TextEditingController();
//   final TextEditingController _categoryPriceController = TextEditingController();
  
//   // Local state for managing categories (in real app, this would be from a database)
//   Map<String, double> _vehicleCategories = Map.from(CampaignDataModel.vehicleTypes);
//   Map<String, double> _apparelCategories = Map.from(CampaignDataModel.apparelTypes);
//   List<String> _campaignCategories = List.from(CampaignDataModel.categories);
//   int _maxPlacements = CampaignDataModel.maxPlacements;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: Text(
//           'Campaign Administration',
//           style: GoogleFonts.inter(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 280,
//             color: const Color(0xFF0F0F0F),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 _buildSidebarItem(
//                   icon: Icons.category,
//                   title: 'Ad Categories',
//                   subtitle: 'Manage vehicle & apparel types',
//                   index: 0,
//                 ),
//                 _buildSidebarItem(
//                   icon: Icons.attach_money,
//                   title: 'Pricing Management',
//                   subtitle: 'Update category prices',
//                   index: 1,
//                 ),
//                 _buildSidebarItem(
//                   icon: Icons.settings,
//                   title: 'System Settings',
//                   subtitle: 'Configure capacity & limits',
//                   index: 2,
//                 ),
//                 _buildSidebarItem(
//                   icon: Icons.filter_list,
//                   title: 'Campaign Filters',
//                   subtitle: 'Manage campaign categories',
//                   index: 3,
//                 ),
//               ],
//             ),
//           ),
          
//           // Main content
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(32),
//               child: _buildTabContent(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSidebarItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required int index,
//   }) {
//     bool isSelected = _selectedTabIndex == index;
    
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTabIndex = index),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFD7FE2D).withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFD7FE2D) : Colors.transparent,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? const Color(0xFFD7FE2D) : Colors.white60,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.inter(
//                       color: isSelected ? Colors.white : Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.inter(
//                       color: Colors.white60,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent() {
//     switch (_selectedTabIndex) {
//       case 0:
//         return _buildAdCategoriesTab();
//       case 1:
//         return _buildPricingTab();
//       case 2:
//         return _buildSystemSettingsTab();
//       case 3:
//         return _buildCampaignFiltersTab();
//       default:
//         return _buildAdCategoriesTab();
//     }
//   }

//   Widget _buildAdCategoriesTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionHeader(
//             icon: Icons.category,
//             title: 'Ad Categories Management',
//             subtitle: 'Manage vehicle types and apparel categories',
//           ),
//           const SizedBox(height: 32),
          
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Vehicle Categories
//               Expanded(
//                 child: _buildCategorySection(
//                   title: 'Vehicle Categories',
//                   icon: Icons.directions_car,
//                   categories: _vehicleCategories,
//                   onDelete: (category) {
//                     setState(() {
//                       _vehicleCategories.remove(category);
//                     });
//                   },
//                   onAdd: () => _showAddCategoryDialog('vehicle'),
//                 ),
//               ),
              
//               const SizedBox(width: 24),
              
//               // Apparel Categories
//               Expanded(
//                 child: _buildCategorySection(
//                   title: 'Apparel & Items',
//                   icon: Icons.checkroom,
//                   categories: _apparelCategories,
//                   onDelete: (category) {
//                     setState(() {
//                       _apparelCategories.remove(category);
//                     });
//                   },
//                   onAdd: () => _showAddCategoryDialog('apparel'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategorySection({
//     required String title,
//     required IconData icon,
//     required Map<String, double> categories,
//     required Function(String) onDelete,
//     required VoidCallback onAdd,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F0F0F),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFF2A2A2A)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: const Color(0xFFD7FE2D), size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: GoogleFonts.inter(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 onPressed: onAdd,
//                 icon: const Icon(Icons.add_circle_outline),
//                 color: const Color(0xFFD7FE2D),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
          
//           ...categories.entries.map((entry) {
//             return Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2A2A),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           entry.key,
//                           style: GoogleFonts.inter(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           'PKR ${entry.value.toStringAsFixed(0)}/month',
//                           style: GoogleFonts.inter(
//                             color: Colors.white60,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => onDelete(entry.key),
//                     icon: const Icon(Icons.delete_outline),
//                     color: Colors.red,
//                     iconSize: 18,
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPricingTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionHeader(
//             icon: Icons.attach_money,
//             title: 'Pricing Management',
//             subtitle: 'Update base prices for all categories',
//           ),
//           const SizedBox(height: 32),
          
//           // Combined pricing table
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0F0F0F),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFF2A2A2A)),
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Text(
//                         'Category',
//                         style: GoogleFonts.inter(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Type',
//                         style: GoogleFonts.inter(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Price (PKR/month)',
//                         style: GoogleFonts.inter(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 60),
//                   ],
//                 ),
//                 const Divider(color: Color(0xFF2A2A2A)),
                
//                 // Vehicle categories
//                 ..._vehicleCategories.entries.map((entry) {
//                   return _buildPricingRow(entry.key, 'Vehicle', entry.value, 'vehicle');
//                 }).toList(),
                
//                 // Apparel categories
//                 ..._apparelCategories.entries.map((entry) {
//                   return _buildPricingRow(entry.key, 'Apparel', entry.value, 'apparel');
//                 }).toList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPricingRow(String category, String type, double price, String categoryType) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               category,
//               style: GoogleFonts.inter(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: type == 'Vehicle' 
//                     ? const Color(0xFFD7FE2D).withOpacity(0.2)
//                     : const Color(0xFF2A2A2A),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 type,
//                 style: GoogleFonts.inter(
//                   color: type == 'Vehicle' ? const Color(0xFFD7FE2D) : Colors.white60,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               price.toStringAsFixed(0),
//               style: GoogleFonts.inter(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 60,
//             child: IconButton(
//               onPressed: () => _showEditPriceDialog(category, price, categoryType),
//               icon: const Icon(Icons.edit_outlined),
//               color: const Color(0xFFD7FE2D),
//               iconSize: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSystemSettingsTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionHeader(
//             icon: Icons.settings,
//             title: 'System Settings',
//             subtitle: 'Configure system-wide campaign settings',
//           ),
//           const SizedBox(height: 32),
          
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0F0F0F),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFF2A2A2A)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Campaign Capacity',
//                   style: GoogleFonts.inter(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
                
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         label: 'Maximum Placements per Campaign',
//                         icon: Icons.confirmation_number,
//                         controller: TextEditingController(text: _maxPlacements.toString()),
//                         keyboardType: TextInputType.number,
//                         onChanged: (value) {
//                           if (int.tryParse(value) != null) {
//                             setState(() {
//                               _maxPlacements = int.parse(value);
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     CustomButton(
//                       text: 'Update',
//                       onPressed: () {
//                         // Save to database
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Settings updated successfully'),
//                             backgroundColor: Color(0xFFD7FE2D),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCampaignFiltersTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionHeader(
//             icon: Icons.filter_list,
//             title: 'Campaign Filters',
//             subtitle: 'Manage campaign category filters',
//           ),
//           const SizedBox(height: 32),
          
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0F0F0F),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFF2A2A2A)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Campaign Categories',
//                       style: GoogleFonts.inter(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       onPressed: () => _showAddFilterDialog(),
//                       icon: const Icon(Icons.add_circle_outline),
//                       color: const Color(0xFFD7FE2D),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
                
//                 ..._campaignCategories.map((category) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2A2A2A),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             category,
//                             style: GoogleFonts.inter(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               _campaignCategories.remove(category);
//                             });
//                           },
//                           icon: const Icon(Icons.delete_outline),
//                           color: Colors.red,
//                           iconSize: 18,
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddCategoryDialog(String type) {
//     _categoryNameController.clear();
//     _categoryPriceController.clear();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F0F),
//         title: Text(
//           'Add ${type == 'vehicle' ? 'Vehicle' : 'Apparel'} Category',
//           style: GoogleFonts.inter(color: Colors.white),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomTextField(
//               label: 'Category Name',
//               icon: Icons.label,
//               controller: _categoryNameController,
//             ),
//             const SizedBox(height: 16),
//             CustomTextField(
//               label: 'Price (PKR/month)',
//               icon: Icons.attach_money,
//               controller: _categoryPriceController,
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.inter(color: Colors.white60),
//             ),
//           ),
//           CustomButton(
//             text: 'Add',
//             onPressed: () {
//               if (_categoryNameController.text.isNotEmpty &&
//                   _categoryPriceController.text.isNotEmpty) {
//                 double price = double.tryParse(_categoryPriceController.text) ?? 0;
//                 setState(() {
//                   if (type == 'vehicle') {
//                     _vehicleCategories[_categoryNameController.text] = price;
//                   } else {
//                     _apparelCategories[_categoryNameController.text] = price;
//                   }
//                 });
//                 Navigator.pop(context);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditPriceDialog(String category, double currentPrice, String categoryType) {
//     _categoryPriceController.text = currentPrice.toString();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F0F),
//         title: Text(
//           'Edit Price for $category',
//           style: GoogleFonts.inter(color: Colors.white),
//         ),
//         content: CustomTextField(
//           label: 'Price (PKR/month)',
//           icon: Icons.attach_money,
//           controller: _categoryPriceController,
//           keyboardType: TextInputType.number,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.inter(color: Colors.white60),
//             ),
//           ),
//           CustomButton(
//             text: 'Update',
//             onPressed: () {
//               if (_categoryPriceController.text.isNotEmpty) {
//                 double price = double.tryParse(_categoryPriceController.text) ?? 0;
//                 setState(() {
//                   if (categoryType == 'vehicle') {
//                     _vehicleCategories[category] = price;
//                   } else {
//                     _apparelCategories[category] = price;
//                   }
//                 });
//                 Navigator.pop(context);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddFilterDialog() {
//     _categoryNameController.clear();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF0F0F0F),
//         title: Text(
//           'Add Campaign Category',
//           style: GoogleFonts.inter(color: Colors.white),
//         ),
//         content: CustomTextField(
//           label: 'Category Name',
//           icon: Icons.category,
//           controller: _categoryNameController,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.inter(color: Colors.white60),
//             ),
//           ),
//           CustomButton(
//             text: 'Add',
//             onPressed: () {
//               if (_categoryNameController.text.isNotEmpty) {
//                 setState(() {
//                   _campaignCategories.add(_categoryNameController.text);
//                 });
//                 Navigator.pop(context);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }