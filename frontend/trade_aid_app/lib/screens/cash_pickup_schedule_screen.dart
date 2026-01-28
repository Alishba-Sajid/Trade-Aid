import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/time_picker.dart';

// 🌿 Premium Fintech Palette
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0F777C), Color(0xFF119E90)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF0B2F2A);
const Color accentTeal = Color(0xFF119E90);
const Color surface = Color(0xFFFFFFFF);
const Color backgroundLight = Color(0xFFF6F7F7);
const Color subtleGrey = Color(0xFFE3E6E6);

class CashPickupScheduleScreen extends StatefulWidget {
  const CashPickupScheduleScreen({super.key});

  @override
  State<CashPickupScheduleScreen> createState() =>
      _CashPickupScheduleScreenState();
}

class _CashPickupScheduleScreenState extends State<CashPickupScheduleScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: accentTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTealTimePicker(
      context,
      initialTime: TimeOfDay.now(),
      primary: accentTeal,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: "Cash Payment Schedule",
        onBack: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Professional Header
            const Text(
              "SCHEDULE DETAILS",
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                color: Colors.grey,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            /// Section: Date
            _buildSectionHeader("Pick a Date", "When should we collect the cash?"),
            const SizedBox(height: 12),
            _premiumGradientCard(
              icon: Icons.calendar_month_rounded,
              title: "Pickup Date",
              subtitle: selectedDate == null
                  ? "Assign collection date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              isSelected: selectedDate != null,
              onTap: _pickDate,
            ),

            const SizedBox(height: 24),

            /// Section: Time
            _buildSectionHeader("Select Time Slot", "Choose a convenient window."),
            const SizedBox(height: 12),
            _premiumGradientCard(
              icon: Icons.history_toggle_off_rounded,
              title: "Pickup Time",
              subtitle: selectedTime == null
                  ? "Assign collection time"
                  : selectedTime!.format(context),
              isSelected: selectedTime != null,
              onTap: _pickTime,
            ),

            const Spacer(),

            /// Bottom Action Button
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentTeal.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: (selectedDate != null && selectedTime != null)
                    ? () {
                        // Confirm Logic
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentTeal,
                  disabledBackgroundColor: accentTeal.withOpacity(0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Confirm Schedule",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🖋️ Professional Section Header
  Widget _buildSectionHeader(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
        Text(
          desc,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 🌟 Premium Gradient Card Widget
  Widget _premiumGradientCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20), // Increased Height through Padding
        decoration: BoxDecoration(
          gradient: isSelected ? appGradient : null,
          color: isSelected ? null : surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? accentTeal.withOpacity(0.25) 
                  : Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            /// White Round Icon Background
            Container(
              height: 52,
              width: 52,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? accentTeal : Colors.grey.shade400,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),

            /// Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withOpacity(0.85) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            /// Selector Dot
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : subtleGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}