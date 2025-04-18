import 'package:drip_tok/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GenderSelection extends StatefulWidget {
  final void Function(String)?
      onGenderSelected; // Callback to pass selected gender
  const GenderSelection({Key? key, this.onGenderSelected}) : super(key: key);

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String selectedGender = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedGender = 'Male';
            });
            if (widget.onGenderSelected != null) {
              widget.onGenderSelected!(selectedGender);
            }
          },
          child: GenderContainer(
            label: 'Male',
            isSelected: selectedGender == 'Male',
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedGender = 'Female';
            });
            if (widget.onGenderSelected != null) {
              widget.onGenderSelected!(selectedGender);
            }
          },
          child: GenderContainer(
            label: 'Female',
            isSelected: selectedGender == 'Female',
          ),
        ),
      ],
    );
  }
}

class GenderContainer extends StatelessWidget {
  final String label;
  final bool isSelected;

  const GenderContainer({
    Key? key,
    required this.label,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width;
    return Container(
      width: width * 0.41,
      padding: EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? AppColors.pink : AppColors.genderborder,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.pink : AppColors.genderborder,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
