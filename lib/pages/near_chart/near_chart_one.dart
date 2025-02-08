import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/pages/near_chart/near_chart_two.dart';

// Test

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NearChartOne(),
    );
  }
}

// Class
class NearChartOne extends StatefulWidget {
  const NearChartOne({super.key});

// Collect selected line from dropdown
@override
_NearChartOneState createState() => _NearChartOneState();
}

class _NearChartOneState extends State<NearChartOne> {
  String? selectedLine;


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

            // Right Eye
            Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                        color: Color(0xFFF8DBE6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ตาข้างขวา',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'BaiJamjuree',
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFCFCFC),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Text(
              'รอบที่ 1',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black,
                fontFamily: 'BaiJamjuree',
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Near Chart Picture
            Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.5,
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
                    color: Color(0xFFF5BBD1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLine,
                      hint: Center(
                        child: Text(
                          'เลือกบรรทัด',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BaiJamjuree',
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                      items: List.generate(11, (index) {
                        return DropdownMenuItem(
                          value: 'บรรทัดที่ ${index + 1}',
                          child: Center(
                            child: Text(
                              'บรรทัดที่ ${index + 1}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black,
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
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.02),

                // Confirm button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NearChartTwo(),
                      ),
                    );
                    print('เลือกบรรทัด: $selectedLine');
                  },
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF12358F), Color(0xFFF5BBD1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ยืนยัน',
                      style: TextStyle(
                        color: Colors.white,
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