import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/pages/near_chart_result/near_chart_result.dart';

// Class
class NearChartFour extends StatefulWidget {
  const NearChartFour({super.key});

// Collect selected line from dropdown
  @override
  _NearChartFourState createState() => _NearChartFourState();
}

class _NearChartFourState extends State<NearChartFour> {
  String? selectedLine;

  Future<void> saveSelectedLine(String line, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_line_$index', line);
  }

// Start UI
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MainTheme.mainBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Eye
            Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: MainTheme.black.withOpacity(0.2),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: MainTheme.nearchartWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: MainTheme.nearchartPink,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ตาข้างซ้าย',
                        style: TextStyle(
                          color: MainTheme.black,
                          fontFamily: 'BaiJamjuree',
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Text(
              'รอบที่ 4',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: MainTheme.buttonBorder,
                fontFamily: 'BaiJamjuree',
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Near Chart Picture
            Container(
              width: 257,
              height: 557,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset('assets/images/snellen_chart.png'),
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            // Select Line
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown

                Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: MainTheme.nearchartPink,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLine,
                      hint: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'เลือกบรรทัด',
                          style: TextStyle(
                            color: MainTheme.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'BaiJamjuree',
                          ),
                        ),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return List.generate(11, (index) {
                          return Align(
                            alignment: Alignment.center,
                            child: Text(
                              selectedLine ?? 'เลือกบรรทัด',
                              style: TextStyle(
                                color: MainTheme.black,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                                fontFamily: 'BaiJamjuree',
                              ),
                            ),
                          );
                        });
                      },
                      items: List.generate(11, (index) {
                        return DropdownMenuItem(
                          value: 'บรรทัดที่ ${index + 1}',
                          child: Center(
                            child: Text(
                              'บรรทัดที่ ${index + 1}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: MainTheme.black,
                                fontFamily: 'BaiJamjuree',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          selectedLine = value;
                        });
                      },
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down,
                          color: MainTheme.black), // ใช้ default icon แทน
                      dropdownColor: MainTheme.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.02),

                // Confirm button
                GestureDetector(
                  onTap: () {
                    if (selectedLine == null) {
                      // Not Selected line
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "กรุณาเลือกบรรทัด",
                            style: TextStyle(
                              fontFamily: 'BaiJamjuree',
                              color: MainTheme.white,
                            ),
                          ),
                          backgroundColor: MainTheme.nearchartRed,
                        ),
                      );
                    } else {
                      saveSelectedLine(selectedLine!, 4);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EyeTestResultsScreen(),
                        ),
                      );
                      // Selected line
                      print('เลือกบรรทัด: $selectedLine');
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: MainTheme.buttonNearChartBackground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        color: MainTheme.white,
                        fontSize: screenWidth * 0.04,
                        fontFamily: 'BaiJamjuree',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
