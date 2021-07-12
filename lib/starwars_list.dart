import 'package:d4_swapi/starwars_rest.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StarwarsList extends StatefulWidget {
  @override
  _StarwarsListState createState() => _StarwarsListState();
}

class _StarwarsListState extends State<StarwarsList> {
  final StarwarsRest _rest;
  final ScrollController _scrollController;
  bool _reload;
  late List<People> _people;
  late int _page;

  _StarwarsListState()
      : _reload = false,
        _rest = new StarwarsRest(),
        _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _page = 1;
    _people = [];
    fetchPeople();
  }

  Future<void> fetchPeople() async {
    setState(() {
      _reload = true;
    });
    var people = await _rest.fetchPeople(page: _page);
    setState(() {
      _reload = false;
      _people = List<People>.from(_people);
      _people.addAll(people);
      _page++;
    });
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      double maxPosition = _scrollController.position.maxScrollExtent;
      double currentPosition = _scrollController.position.pixels;

      if (maxPosition == currentPosition) {
        EasyDebounce.debounce('scrolling', Duration(microseconds: 275), () {
          fetchPeople();
          print('refetch');
        });
      }
    });
    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      children: <Widget>[
        for (int i = 0; i < _people.length; i++) buildCard(_people[i]),
        Visibility(
          visible: _reload,
          child: Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(),
            ),
          ),
          replacement: Container(),
        ),
      ],
    );
  }

  Widget buildCard(People people) {
    return Card(
      key: ValueKey(people),
      child: Container(
        height: 50,
        child: Row(
          children: [
            Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(people.imageUrl)),
            Container(
                margin: EdgeInsets.only(left: 15), child: Text(people.name)),
          ],
        ),
      ),
    );
  }
}
