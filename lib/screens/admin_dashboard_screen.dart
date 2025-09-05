import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_in_screen.dart';
import 'campaign_screen.dart';
import 'campaigns_list_screen.dart';
import '../components/custom_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;
  
  // Data variables
  int _totalCampaigns = 0;
  int _activeCampaigns = 0;
  int _totalDrivers = 0;
  double _totalRevenue = 0;
  int _totalImpressions = 0;
  bool _isLoadingData = true;
  
  final List<String> _menuItems = [
    'Dashboard',
    'Campaigns',
    'Analytics',
    'Drivers',
    'Settings',
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard_outlined,
    Icons.campaign_outlined,
    Icons.analytics_outlined,
    Icons.people_outline,
    Icons.settings_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoadingData = true;
      });

      // Fetch campaigns data
      final campaignsSnapshot = await FirebaseFirestore.instance
          .collection('campaigns')
          .get();
      
      _totalCampaigns = campaignsSnapshot.docs.length;
      _activeCampaigns = campaignsSnapshot.docs
          .where((doc) => (doc.data()['status'] ?? '').toString().toLowerCase() == 'active')
          .length;
      
      // Calculate total revenue from campaigns
      _totalRevenue = 0;
      for (var doc in campaignsSnapshot.docs) {
        final budget = doc.data()['budget'];
        if (budget != null) {
          if (budget is String) {
            _totalRevenue += double.tryParse(budget) ?? 0;
          } else if (budget is num) {
            _totalRevenue += budget.toDouble();
          }
        }
      }

      // Fetch users data (drivers are users without isAdmin = true)
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      _totalDrivers = usersSnapshot.docs
          .where((doc) => (doc.data()['isAdmin'] ?? false) != true)
          .length;

      // Calculate total impressions (sum from all campaigns)
      _totalImpressions = 0;
      for (var doc in campaignsSnapshot.docs) {
        final impressions = doc.data()['impressions'];
        if (impressions != null) {
          if (impressions is String) {
            _totalImpressions += int.tryParse(impressions) ?? 0;
          } else if (impressions is num) {
            _totalImpressions += impressions.toInt();
          }
        }
      }

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  String _formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error signing out. Please try again.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleMenuNavigation(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0: // Dashboard
        // Stay on current screen - no navigation needed
        break;
      case 1: // Campaigns
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CampaignsListScreen(),
          ),
        );
        break;
      case 2: // Analytics
        _showComingSoonDialog('Analytics');
        break;
      case 3: // Drivers
        _showComingSoonDialog('Drivers Management');
        break;
      case 4: // Settings
        _showComingSoonDialog('Settings');
        break;
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Coming Soon',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '$feature feature is under development and will be available soon.',
          style: GoogleFonts.inter(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD7FE2D),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0A),
              border: Border(
                right: BorderSide(color: Color(0xFF1A1A1A), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7FE2D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset('assets/images/radz1.png'),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Radz',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Menu
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      final isHovered = _hoveredIndex == index;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = -1),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _handleMenuNavigation(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFFD7FE2D).withOpacity(0.1)
                                      : isHovered
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _menuIcons[index],
                                      color: isSelected 
                                          ? const Color(0xFFD7FE2D)
                                          : isHovered
                                              ? Colors.white
                                              : Colors.white60,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _menuItems[index],
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: isSelected 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                        color: isSelected 
                                            ? const Color(0xFFD7FE2D)
                                            : isHovered
                                                ? Colors.white
                                                : Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // User Profile Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1A1A1A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7FE2D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFD7FE2D),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  user?.email?.split('@')[0] ?? 'Unknown',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _signOut(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            foregroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: const Color(0xFF0F0F0F),
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A0A0A),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  
                  // Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: _isLoadingData
                                    ? _buildLoadingStatsCard('Active Campaigns', Icons.campaign, const Color(0xFFD7FE2D))
                                    : _buildStatsCard(
                                        'Active Campaigns',
                                        _activeCampaigns.toString(),
                                        'Total: $_totalCampaigns campaigns',
                                        Icons.campaign,
                                        const Color(0xFFD7FE2D),
                                      ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _isLoadingData
                                    ? _buildLoadingStatsCard('Total Drivers', Icons.people, Colors.blue)
                                    : _buildStatsCard(
                                        'Total Drivers',
                                        _formatNumber(_totalDrivers),
                                        'Registered users',
                                        Icons.people,
                                        Colors.blue,
                                      ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _isLoadingData
                                    ? _buildLoadingStatsCard('Revenue', Icons.trending_up, Colors.green)
                                    : _buildStatsCard(
                                        'Revenue',
                                        _formatCurrency(_totalRevenue),
                                        'Total campaign budgets',
                                        Icons.trending_up,
                                        Colors.green,
                                      ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _isLoadingData
                                    ? _buildLoadingStatsCard('Impressions', Icons.visibility, Colors.purple)
                                    : _buildStatsCard(
                                        'Impressions',
                                        _formatNumber(_totalImpressions),
                                        'Total campaign views',
                                        Icons.visibility,
                                        Colors.purple,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Quick Actions Section
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Action Cards Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: screenWidth > 1400 ? 4 : 3,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.3,
                            children: [
                              _buildActionCard(
                                context,
                                'Create Campaign',
                                'Launch new advertising campaigns with targeted reach',
                                Icons.add_circle_outline,
                                const Color(0xFFD7FE2D),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CampaignScreen(),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                context,
                                'View Campaigns',
                                'Manage and monitor existing campaigns',
                                Icons.campaign_outlined,
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CampaignsListScreen(),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                context,
                                'Campaigns List',
                                'Browse all active and inactive campaigns',
                                Icons.list_alt_outlined,
                                Colors.purple,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CampaignsListScreen(),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                context,
                                'Analytics',
                                'View detailed performance metrics',
                                Icons.analytics_outlined,
                                Colors.green,
                                () => _showComingSoonDialog('Analytics'),
                              ),
                              _buildActionCard(
                                context,
                                'Settings',
                                'Configure application settings',
                                Icons.settings_outlined,
                                Colors.orange,
                                () => _showComingSoonDialog('Settings'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.white30,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A1A1A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStatsCard(
    String title,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.white30,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD7FE2D)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}