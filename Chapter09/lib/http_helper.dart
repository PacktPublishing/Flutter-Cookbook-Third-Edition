import 'dart:convert';
import 'pizza.dart';
//import 'dart:io';
import 'package:http/http.dart' as http;

class HttpHelper {
  //use these or add your own wiremock server and change the authority and path
  final String authority = 'YOURCODE.wiremockapi.cloud';
  final String path = 'pizzalist';

  Future<List<Pizza>> getPizzaList() async {
    try {
      final Uri url = Uri.https(authority, path);
      final http.Response result = await http.get(url);
      if (result.statusCode == 200) {
        final responseString = result.body;
        List pizzaMapList = jsonDecode(responseString);
        List<Pizza> myPizzas = [];
        for (var pizza in pizzaMapList) {
          Pizza myPizza = Pizza.fromJson(pizza);
          myPizzas.add(myPizza);
        }
        return myPizzas;
      } else {
        return [];
      }
    } on Exception catch (e) {
      return [];
    }
  }

  Future<String> postPizza(Pizza pizza) async {
    const postPath = '/pizza';
    String post = json.encode(pizza.toJson());
    Uri url = Uri.https(authority, postPath);
    http.Response r = await http.post(url, body: post);
    return r.body;
  }

  Future<String> putPizza(Pizza pizza) async {
    const putPath = '/pizza';

    String put = json.encode(pizza.toJson());
    Uri url = Uri.https(authority, putPath);
    http.Response r = await http.put(url, body: put);

    return r.body;
  }

  Future<String> deletePizza(int id) async {
    final deletePath = '/pizza/$id';

    Uri url = Uri.https(authority, deletePath);
    http.Response r = await http.delete(url);

    return r.body;
  }
}
