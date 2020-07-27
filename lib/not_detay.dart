import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';

class NotDetay extends StatefulWidget {
  String baslik;
  Not duzenlenecekNot;

  NotDetay({this.baslik, this.duzenlenecekNot});

  @override
  _NotDetayState createState() => _NotDetayState();
}

class _NotDetayState extends State<NotDetay> {
  var formKey = GlobalKey<FormState>();
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;
  int kategoriID;

  int secilenOncelik;

  String notBaslik, notIcerik;
  static var _oncelik = ["Düşük", "Orta", "Yüksek"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tumKategoriler = List<Kategori>();
    databaseHelper = DatabaseHelper();
    databaseHelper.kategorileriGetir().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        tumKategoriler.add(Kategori.fromMap(okunanMap));
      }
      if (widget.duzenlenecekNot != null) {
        kategoriID = widget.duzenlenecekNot.kategoriID;
        secilenOncelik = widget.duzenlenecekNot.notOncelik;
      } else {
        kategoriID = 1;
        secilenOncelik = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.baslik),
        ),
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Kategori: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: DropdownButtonHideUnderline(
                        child: tumKategoriler.length <= 0
                            ? CircularProgressIndicator()
                            : DropdownButton<int>(
                                items: kategoriItemleriOlustur(),
                                value: kategoriID,
                                onChanged: (secilenKategoriID) {
                                  setState(() {
                                    kategoriID = secilenKategoriID;
                                  });
                                },
                              ),
                      ),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 4),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.duzenlenecekNot != null
                      ? widget.duzenlenecekNot.notBaslik
                      : "",
                  validator: (text) {
                    if (text.length < 3) {
                      return "En az 3 karakter giriniz";
                    }
                  },
                  onSaved: (text) {
                    notBaslik = text;
                  },
                  decoration: InputDecoration(
                    hintText: "Not başlığını giriniz",
                    labelText: "Başlık",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.duzenlenecekNot != null
                      ? widget.duzenlenecekNot.notIcerik
                      : "",
                  onSaved: (text) {
                    notIcerik = text;
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Not içeriğini giriniz",
                    labelText: "İçerik",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Öncelik: ",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Container(
                      child: DropdownButtonHideUnderline(
                        child: tumKategoriler.length <= 0
                            ? CircularProgressIndicator()
                            : DropdownButton<int>(
                                items: _oncelik.map((oncelik) {
                                  return DropdownMenuItem<int>(
                                    child: Text(oncelik,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.indigo)),
                                    value: _oncelik.indexOf(oncelik),
                                  );
                                }).toList(),
                                value: secilenOncelik,
                                onChanged: (secilenOncelikID) {
                                  setState(() {
                                    secilenOncelik = secilenOncelikID;
                                  });
                                },
                              ),
                      ),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber, width: 4),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.redAccent,
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        var suan = DateTime.now();
                        if (widget.duzenlenecekNot == null) {
                          databaseHelper
                              .notEkle(Not(kategoriID, notBaslik, notIcerik,
                                  suan.toString(), secilenOncelik))
                              .then((kaydedilenNotID) {
                            if (kaydedilenNotID != 0) {
                              Navigator.pop(context);
                            }
                          });
                        } else {
                          databaseHelper
                              .notGuncelle(Not.withID(
                                  widget.duzenlenecekNot.notID,
                                  kategoriID,
                                  notBaslik,
                                  notIcerik,
                                  suan.toString(),
                                  secilenOncelik))
                              .then((guncellenenID) {
                            if (guncellenenID != 0) {
                              Navigator.pop(context);
                            }
                          });
                        }
                      }
                    },
                    child: Text(
                      "Kaydet",
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.greenAccent,
                  )
                ],
              )
            ],
          ),
        ));
  }

  List<DropdownMenuItem<int>> kategoriItemleriOlustur() {
    return tumKategoriler
        .map((kategori) => DropdownMenuItem<int>(
              value: kategori.kategoriID,
              child: Center(
                child: Text(
                  kategori.kategoriBaslik,
                  style: TextStyle(fontSize: 20, color: Colors.indigo),
                ),
              ),
            ))
        .toList();
  }
}
