import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Addresses()),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Find Zip'),
          ),
          body: ItemsScreen(),
        ),
      ),
    );
  }
}

class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<Addresses>(context);
    final address = addresses.items;
    String _zip = "";
    return Container(
      padding: EdgeInsets.all(50),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onChanged: (String e) {
                _zip = e;
              },
            ),
            RaisedButton(
              onPressed: () async {
                final url =
                    'https://zipcloud.ibsnet.co.jp/api/search?zipcode=' + _zip;
                final response = await http.get(url);
                final json = jsonDecode(response.body);
                final jsonData = json['results'];

                if (jsonData != null) {
                  addresses.addAddress(
                    Address(
                      address1: jsonData[0]['address1'],
                      address2: jsonData[0]['address2'],
                      address3: jsonData[0]['address3'],
                      zipcode: jsonData[0]['zipcode'],
                    ),
                  );
                } else {
                  final snackBar = SnackBar(
                    content: Text('Not Exist Zip Code'),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {
                        Scaffold.of(context).removeCurrentSnackBar();
                      },
                    ),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
              child: Text('Find'),
            ),
            address.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) => ListTile(
                      title: Text(address[i].address1 +
                          address[i].address2 +
                          address[i].address3),
                      subtitle: Text(address[i].zipcode),
                    ),
                    itemCount: address.length,
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('No Item'),
                  )
          ],
        ),
      ),
    );
  }
}

class Address {
  final String address1;
  final String address2;
  final String address3;
  final String zipcode;

  Address({this.address1, this.address2, this.address3, this.zipcode});
}

class Addresses with ChangeNotifier {
  List<Address> _items = [];
  List<Address> get items => _items;
  void addAddress(Address address) {
    _items.add(address);
    notifyListeners();
  }
}
