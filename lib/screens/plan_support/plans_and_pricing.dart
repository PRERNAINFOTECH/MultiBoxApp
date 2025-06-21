import 'package:flutter/material.dart';
import '../../widgets/scroll_to_top_wrapper.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/custom_app_bar.dart';

class PlansPricingScreen extends StatefulWidget {
  const PlansPricingScreen({super.key});

  @override
  State<PlansPricingScreen> createState() => _PlansPricingScreenState();
}

class _PlansPricingScreenState extends State<PlansPricingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isMonthly = true;

  final planData = {
    'monthly': [
      {
        'title': 'STANDARD',
        'price': '₹798',
        'features': [
          "Stock Management without History",
          "Single Reel Addition",
          "Products management",
          "Production Line Handling",
          "Daily Program Management",
          "Purchase Order Management",
        ]
      },
      {
        'title': 'ENTERPRISE',
        'price': '₹1098',
        'features': [
          "Stock Management with History",
          "Bulk Reel Addition",
          "Advanced Reel Filtering",
          "Reels Stocks and Order Management",
          "Products Management",
          "Products Filtering",
          "Production Line Handling",
          "Daily Program Management",
          "Daily Program Sharing",
          "Purchase Order Management",
          "Monthly Report",
          "Database Copy",
        ]
      },
    ],
    'yearly': [
      {
        'title': 'STANDARD',
        'price': '₹7980',
        'features': [
          "Stock Management without History",
          "Single Reel Addition",
          "Products management",
          "Production Line Handling",
          "Daily Program Management",
          "Purchase Order Management",
        ]
      },
      {
        'title': 'ENTERPRISE',
        'price': '₹10980',
        'features': [
          "Stock Management with History",
          "Bulk Reel Addition",
          "Advanced Reel Filtering",
          "Reels Stocks and Order Management",
          "Products Management",
          "Products Filtering",
          "Production Line Handling",
          "Daily Program Management",
          "Daily Program Sharing",
          "Purchase Order Management",
          "Monthly Report",
          "Database Copy",
        ]
      },
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Tenant Plans"),
        actions: const [AppBarMenu()],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: ScrollToTopWrapper(
        scrollController: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Tenant Plans",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose the plans based on your needs and our features.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [isMonthly, !isMonthly],
                onPressed: (index) => setState(() => isMonthly = index == 0),
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF4A68F2),
                color: const Color(0xFF4A68F2),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Monthly"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Yearly"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;
                  var plans = isMonthly ? planData['monthly']! : planData['yearly']!;
                  return Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var plan in plans)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: isMobile ? double.infinity : 320,
                            child: _buildPlanCard(
                              title: plan['title'] as String,
                              price: plan['price'] as String,
                              isMonthly: isMonthly,
                              features: List<String>.from(plan['features'] as List),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isMonthly,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A68F2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            price,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            isMonthly ? "/month" : "/year",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDD9FD),
                foregroundColor: const Color(0xFF4A68F2),
              ),
              child: const Text("You Have Active Plan"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
