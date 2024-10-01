import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AnaSayfa extends StatefulWidget {
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final String _apiKey = "API_KEY";

  final String _baseUrl =
      "http://api.exchangeratesapi.io/v1/latest?access_key=";

  TextEditingController _controller = TextEditingController();

  Map<String, double> _oranlar = {};

  String _secilenKur = "USD";

  double _sonuc = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verileriInternettenCek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _oranlar.isNotEmpty ? _buildBody():Center(child: CircularProgressIndicator()),
    );
  }

  AppBar _buildAppBar(){
    return AppBar(
      leading: IconButton(
        onPressed: () {},
        icon: Icon(Icons.attach_money),
        color: Colors.white,
      ),
      backgroundColor: Colors.blue,
      title: Text(
        "Kur Dönüştürücü",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildExchangeRow(),
          SizedBox(
            height: 16,
          ),
          _buildSonucText(),
          SizedBox(
            height: 16,
          ),
          _buildAyiriciCizgi(),
          SizedBox(
            height: 16,
          ),
          _buildKurList(),
        ],
      ),
    );
  }

  Widget _buildExchangeRow(){
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
            onChanged: (String yeniDeger) {
              _hesapla();
            },
          ),
        ),
        SizedBox(
          width: 16,
        ),
        DropdownButton<String>(
          value: _secilenKur,
          icon: Icon(Icons.arrow_downward),
          underline: SizedBox(),
          items: _oranlar.keys.map((String kur) {
            return DropdownMenuItem(
              value: kur,
              child: Text(kur),
            );
          }).toList(),
          onChanged: (String? yeniDeger) {
            if (yeniDeger != null) {
              _secilenKur = yeniDeger;
              _hesapla();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSonucText(){
    return Text(
      "${_sonuc.toStringAsFixed(2)} ₺",
      style: TextStyle(fontSize: 24),
    );
  }

  Widget _buildAyiriciCizgi(){
    return Container(
      height: 2,
      color: Colors.black,
    );
  }

  Widget _buildKurList(){
    return Expanded(
      child: ListView.builder(
        itemCount: _oranlar.keys.length,
        itemBuilder: _buildListItem,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title:
          Text(_oranlar.keys.toList()[index], style: TextStyle(fontSize: 19)),
      trailing: Text(
        "${_oranlar.values.toList()[index].toStringAsFixed(2)} ₺",
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  void _hesapla() {
    double? deger = double.tryParse(_controller.text);
    double? oran = _oranlar[_secilenKur];

    if (deger != null && oran != null) {
      setState(() {
        _sonuc = deger * oran;
      });
    }
  }

  void _verileriInternettenCek() async {
    
    Uri uri = Uri.parse(_baseUrl + _apiKey);
    http.Response response = await http.get(uri);

    Map<String, dynamic> parsedResponse = jsonDecode(response.body);

    Map<String, dynamic> rates = parsedResponse["rates"];

    double? baseTlKuru = rates["TRY"];

    if (baseTlKuru != null) {
      for (String ulkeKuru in rates.keys) {
        double? baseKur = double.tryParse(rates[ulkeKuru].toString());
        if (baseKur != null) {
          double tlKuru = baseTlKuru / baseKur;
          _oranlar[ulkeKuru] = tlKuru;
        }
      }
    }
    setState(() {});
  }
}

/*
{
    "success": true,
    "timestamp": 1519296206,
    "base": "EUR",
    "date": "2021-03-17",
    "rates": {
        "AUD": 1.566015,
        "CAD": 1.560132,
        "CHF": 1.154727,
        "CNY": 7.827874,
        "GBP": 0.882047,
        "JPY": 132.360679,
        "USD": 1.23396,
    [...]
    }
}
* */
