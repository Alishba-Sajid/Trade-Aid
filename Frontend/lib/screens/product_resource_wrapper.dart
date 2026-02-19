import 'package:flutter/material.dart';
import 'productresourcescreen.dart';
import 'resource_screen.dart';

class ProductResourceWrapper extends StatefulWidget {
  const ProductResourceWrapper({super.key});

  @override
  State<ProductResourceWrapper> createState() => _ProductResourceWrapperState();
}

class _ProductResourceWrapperState extends State<ProductResourceWrapper> {
  String selectedTab = "Products";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(30, 50, 50, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Products & Resources",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _tabButton("Products"),
              const SizedBox(width: 20),
              _tabButton("Resource Sharing"),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: selectedTab == "Products"
                ? const ProductResource()
                : const ResourceSharing(),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title) {
    bool isActive = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: isActive ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
