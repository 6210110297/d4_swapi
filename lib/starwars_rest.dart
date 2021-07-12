import 'package:dio/dio.dart';

class People {
  final String name;
  People({this.name = ''});

  factory People.fromJson(Map<String, dynamic> data) {
    return People(name: data['name']);
  }
}

class StarwarsRest {
  Future<List<People>> fetchPeople({int page = 1}) async {
    var response = await Dio().get('https://swapi.dev/api/people?page=$page');
    List<dynamic> results = response.data['results'];
    print('fetch ${results.toString()}');
    return results.map((data) => People.fromJson(data)).toList();
  }
}
