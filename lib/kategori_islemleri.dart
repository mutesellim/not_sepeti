import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/utils/database_helper.dart';
import 'package:flutter_not_sepeti/models/kategori.dart';

class Kategoriler extends StatefulWidget {
  @override
  _KategorilerState createState() => _KategorilerState();
}

class _KategorilerState extends State<Kategoriler> {
  List<Kategori> tumKategoriler;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (tumKategoriler == null) {
      tumKategoriler = List<Kategori>();
      kategoriListesiniGuncelle();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategoriler"),
      ),
      body: ListView.builder(
          itemCount: tumKategoriler.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () => _kategoriGuncelle(tumKategoriler[index], context),
              title: Text(tumKategoriler[index].kategoriBaslik),
              trailing: InkWell(
                child: Icon(Icons.delete),
                onTap: () => _kategoriSil(tumKategoriler[index].kategoriID),
              ),
              leading: Icon(Icons.category),
            );
          }),
    );
  }

  void kategoriListesiniGuncelle() {
    databaseHelper.kategoriListesiniGetir().then((kategoriIcerenList) {
      setState(() {
        tumKategoriler = kategoriIcerenList;
      });
    });
  }

  _kategoriSil(int kategoriID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Kategori Sil"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    "Kategori silindiğinde bununla ilgili tüm notlar silinecektir. Emin Misiniz?"),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Vazgeç"),
                    ),
                    FlatButton(
                      onPressed: () {
                        databaseHelper
                            .kategoriSil(kategoriID)
                            .then((silinenKategori) {
                          if (silinenKategori != 0) {
                            setState(() {
                              kategoriListesiniGuncelle();
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                      child: Text(
                        "Kategoriyi Sil",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  _kategoriGuncelle(Kategori guncellenecekKategori, BuildContext context) {
    kategoriGuncelleDialog(context, guncellenecekKategori);
  }

  void kategoriGuncelleDialog(
      BuildContext context, Kategori guncellenecekKategori) {
    var formKey = GlobalKey<FormState>();
    String guncellenecekKategoriAdi;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Kategori Güncelle",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            children: <Widget>[
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: guncellenecekKategori.kategoriBaslik,
                    onSaved: (yeniDeger) {
                      guncellenecekKategoriAdi = yeniDeger;
                    },
                    decoration: InputDecoration(
                        labelText: "Kategori Adı",
                        border: OutlineInputBorder()),
                    validator: (girilenKategoriAdi) {
                      if (girilenKategoriAdi.length < 2) {
                        return "En az 2 karakter giriniz";
                      }
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    child: Text(
                      "Vazgeç",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .kategoriGuncelle(Kategori.withID(
                                guncellenecekKategori.kategoriID,
                                guncellenecekKategoriAdi))
                            .then((katID) {
                          if (katID != 0) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Kategori Güncellendi"),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        });
                        kategoriListesiniGuncelle();
                        Navigator.of(context).pop();
                      }
                    },
                    color: Colors.green,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }
}
