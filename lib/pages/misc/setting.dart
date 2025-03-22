import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/core/theme/theme.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  // Handle logout action with a more reliable approach
  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    
    try {
      // Show loading indicator
      final loadingOverlay = _showLoadingOverlay(context);
      
      // Call logout method
      await authService.logout();
      
      // Remove the loading overlay
      loadingOverlay.remove();
      
      // Navigate to landing page using a more reliable approach
      if (context.mounted) {
        // Go to landing page
        context.go('/landing');
      }
    } catch (e) {
      // Hide any dialogs that might be showing
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }
  
  // Show a loading overlay that doesn't use dialog
  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlay);
    return overlay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      appBar: AppBar(
        title: const Text(
          'ตั้งค่า',
          style: TextStyle(
            color: MainTheme.mainText,
            fontSize: 18,
            fontFamily: 'BaiJamjuree',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: MainTheme.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MainTheme.mainText,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // Settings section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: MainTheme.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile settings option
                ListTile(
                  leading: const Icon(Icons.person, color: MainTheme.blueText),
                  title: const Text(
                    'ข้อมูลผู้ใช้',
                    style: TextStyle(
                      color: MainTheme.mainText,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to profile page
                  },
                ),
                
                const Divider(height: 1),
                
                // Password change option
                ListTile(
                  leading: const Icon(Icons.lock, color: MainTheme.blueText),
                  title: const Text(
                    'เปลี่ยนรหัสผ่าน',
                    style: TextStyle(
                      color: MainTheme.mainText,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/change_password_mail');
                  },
                ),
                
                // Add this new section
                const Divider(height: 1),
                
                // Scan History option
                ListTile(
                  leading: const Icon(Icons.history, color: MainTheme.blueText),
                  title: const Text(
                    'ประวัติการตรวจ',
                    style: TextStyle(
                      color: MainTheme.mainText,
                      fontFamily: 'BaiJamjuree',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Use string literal instead of Path class constant
                    context.push('/scanlog');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: MainTheme.redWarning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}