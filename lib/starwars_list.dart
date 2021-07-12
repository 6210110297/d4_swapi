import 'package:cached_network_image/cached_network_image.dart';
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
        EasyDebounce.debounce('scrolling', Duration(microseconds: 300), () {
          fetchPeople();
          print('refetch');
        });
      }
    });
    return Container(
      decoration: BoxDecoration(
          image: _reload && _page == 1
              ? null
              : DecorationImage(
                  fit: BoxFit.cover, image: AssetImage('bg.jpg'))),
      child: ListView(
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
      ),
    );
  }

  Widget buildCard(People people) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.all(10),
      key: ValueKey(people),
      child: Container(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                child: CachedNetworkImage(
              fit: BoxFit.fill,
              imageUrl: people.imageUrl,

              // placeholder: (context, url) => Container(
              //     color: Colors.grey, child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Text('unloading picture'),
            )),
            Container(
                child: Text(
              people.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )),
            Row(children: [
              Icon(Icons.height),
              Text(people.height),
            ]),
            Row(children: [Icon(Icons.monitor_weight), Text(people.mass)]),
            Container(child: genderIcon(people.gender)),
          ],
        ),
      ),
    );
  }

  Widget genderIcon(String gender) {
    if (gender == 'male') {
      return Icon(Icons.male);
    } else if (gender == 'female') {
      return Icon(Icons.female);
    } else {
      return Icon(Icons.blur_on);
    }
  }
}
