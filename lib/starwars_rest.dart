import 'package:dio/dio.dart';

class People {
  final String name;
  final String height;
  final String mass;
  final String gender;
  final String imageUrl;

  People({
    this.name = '',
    this.height = '',
    this.mass = '',
    this.gender = '',
    this.imageUrl = '',
  });

  factory People.fromJson(Map<String, dynamic> data) {
    var pplId = data['url']?.toString().split('/')[5];
    var url =
        'https://starwars-visualguide.com/assets/img/characters/$pplId.jpg';
    return People(
        name: data['name'],
        height: data['height'],
        mass: data['mass'],
        gender: data['gender'],
        imageUrl: url);
  }
}

class StarwarsRest {
  Future<List<People>> fetchPeople({int page = 1}) async {
    var response = await Dio().get('https://swapi.dev/api/people?page=$page');
    List<dynamic> results = response.data['results'];
    // print('fetch ${results.toString()}');
    return results.map((data) => People.fromJson(data)).toList();
  }
}
