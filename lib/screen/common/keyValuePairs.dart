import 'package:flutter/material.dart';

class KeyValuePairs extends StatelessWidget {
  final String keyText;
  final String valueText;

  const KeyValuePairs({Key? key, required this.keyText, required this.valueText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child:  Container(
        margin: const EdgeInsets.all(1),
        child: Wrap(
          children: [
            Text('$keyText: ', style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
            Text(valueText,style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 10),softWrap: true,maxLines: 3,
              overflow: TextOverflow.ellipsis,),
          ],
        ),
      ),
    );
  }
}
