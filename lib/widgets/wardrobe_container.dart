import 'package:drip_tok/constants/app_colors.dart';
import 'package:flutter/material.dart';

class MyDripsAndWardrobe extends StatefulWidget {
  final Color? color;
  const MyDripsAndWardrobe({super.key, required this.color});

  @override
  State<MyDripsAndWardrobe> createState() => _MyDripsAndWardrobeState();
}

class _MyDripsAndWardrobeState extends State<MyDripsAndWardrobe> {
  int selectedIndex = 0;

  void _onContainerSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _onContainerSelected(0),
                  child: Container(
                    width: width * 0.42,
                    height: height * 0.059,
                    decoration: BoxDecoration(
                      color: selectedIndex == 0
                          ? Colors.pink
                          : AppColors.textFieledfillColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedIndex == 0
                            ? Colors.pink
                            : AppColors.textfieledBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'My Drips',
                        style: TextStyle(
                          color: selectedIndex == 0
                              ? Colors.white
                              : AppColors.gray,
                          fontSize: 16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _onContainerSelected(1),
                  child: Container(
                    width: width * 0.42,
                    height: height * 0.059,
                    decoration: BoxDecoration(
                      color: selectedIndex == 1
                          ? Colors.pink
                          : AppColors.textFieledfillColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: selectedIndex == 1
                            ? Colors.pink
                            : AppColors.textfieledBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Wardrobe',
                        style: TextStyle(
                          color:
                              selectedIndex == 1 ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: selectedIndex == 0
                  ? const Text(
                      'My Drips Content',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(
                      'Wardrobe Content',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
