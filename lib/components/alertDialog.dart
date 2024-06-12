import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddItemDialog extends StatefulWidget {
  final LatLng latLng;
  Function? addMarker;
  AddItemDialog({super.key, required this.latLng, required this.addMarker});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  List<bool> list = [false, false, false];
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Item"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                hintText: "Enter Location's Name here",
              ),
            ),
            CheckboxListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: Colors.green,
                  ),
                  Text("Want to go!")
                ],
              ),
              value: checkboxValue1,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue1 = value!;
                  list[0] = !list[0];
                });
              },
            ),
            CheckboxListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: Colors.orange,
                  ),
                  Text("Starred Places")
                ],
              ),
              value: checkboxValue2,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue2 = value!;
                  list[1] = !list[1];
                });
                // if(value == true){
                //   list.add(true);
                // }else{
                //   list.add(false);
                // }

              },
            ),
            CheckboxListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                  ),
                  Text("Favourites")
                ],
              ),
              value: checkboxValue3,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue3 = value!;
                  list[2] = !list[2];
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            widget.addMarker!(widget.latLng, textEditingController.text.toString(), list);
            debugPrint(list.toString());
            Navigator.of(context).pop();
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
