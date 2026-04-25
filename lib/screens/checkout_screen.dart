import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../shared/widgets/drape_scaffold.dart';
import '../shared/widgets/primary_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DrapeScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                    ),
                  ),
                ),
                Text('Checkout', style: AppText.titleS.copyWith(fontWeight: FontWeight.w600, fontSize: 17)),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 48, color: AppColors.muted),
                  SizedBox(height: 16),
                  Text('Secure Checkout', style: TextStyle(fontSize: 18, color: AppColors.ink)),
                  SizedBox(height: 8),
                  Text('Coming soon', style: TextStyle(color: AppColors.muted)),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 32),
            child: PrimaryButton(label: 'CONFIRM ORDER', onTap: null),
          ),
        ],
      ),
    );
  }
}
