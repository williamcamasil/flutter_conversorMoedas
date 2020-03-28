import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//Biblioteca que permite ter uma requisição assincrona, ou seja de forma a não se esperar
import 'dart:async';
//Biblioteca para converter em JSON
import 'dart:convert';

//constante da requeste da api, para trazer os dados
const request = "https://api.hgbrasil.com/finance";

//foi inserido o async, para aguardar a o retorno da operação 
void main() async{
  //Fazendo a requisição dos dados
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    //Adicionado o tema da tela
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //Criando os controladores
  //Através dos controladores é possivel pegar os textos digitados nos textfields
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();


  double dolar;
  double euro;
  
  //Funções de troca
  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar*this.dolar).toStringAsFixed(2);
    euroController.text = (dolar*this.dolar/euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = (euro*this.euro/dolar).toStringAsFixed(2);
  }

  //limpa os campos
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      //widget FutureBuilder que vai conter o Map
      body: FutureBuilder<Map>(
        //Em seguida é inserida a função no future
        future: getData(),
        //Irá especificar o que será mostrado na tela em cada 1 dos casos
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            //Se não estiver conectado ou esperando será retornado carregando dados
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...", 
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              //Se tiver algum erro será retornado Erro ao Carregar os Dados :(
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao Carregar os Dados :(", 
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ); 
              }else{
                //Forma que será capturado o valor do dolar e do euro
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                //Se não conter erro retorna o container verde
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    //Manter tudo centralizado com largura total
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),

                      buildTextField("Reais", "R\$", realController, _realChanged),

                      //Da um espaçamento entre os inputs
                      Divider(),

                      buildTextField("Dolares", "US\$", dolarController, _dolarChanged),

                      Divider(),

                      buildTextField("Euros", "€", euroController, _euroChanged),

                    ],
                  ),
                );
              }
          }
        }
      ),
    );
  }
}

//Função que será retornada no futuro
//É uma função que irá retornar o dados no futuro, através do Map
//A ideia do futuro quer dizer que você só utilizara ele no futuro mesmo
Future<Map> getData() async{
  //Trazendo os dados para a variavel response
  http.Response response = await http.get(request);
  //Mostrando os dados selecionados
  return json.decode(response.body);
}

//Componentizando os textfields
Widget buildTextField(String label, String prefix, TextEditingController moeda, Function troca){
  return TextField(
    //Controller do texto recebido
    controller: moeda,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix, 
    ),
    
    style: TextStyle(
      color: Colors.amber, fontSize: 25.0,
    ),
    //Função de troca, toda vez que tiver alguma alteração no campo, será chamado a função
    onChanged: troca,
    keyboardType: TextInputType.number,
  );
}
