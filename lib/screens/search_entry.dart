import 'package:flutter/material.dart';

class SearchEntry extends StatelessWidget {
  static const String id = 'search_entry_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search for an Entry'),
      ),
      body: SearchBody(),
    );
  }
}

///Main body of initial screen
class SearchBody extends StatefulWidget {
  @override
  _SearchBodyState createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Nothing here'),
    );
  }
}
