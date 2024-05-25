import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 144, 205, 230)), 
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<String> phrases = [];
  late String currentPhrase;

  MyAppState() {
    currentPhrase = "Loading...";
    loadPhrases();
  }

  Future<void> loadPhrases() async {
    try {
      final String data = await rootBundle.loadString('Frases/frases.txt');
      phrases = LineSplitter().convert(data);
      if (phrases.isNotEmpty) {
        getNextPhrase();
      } else {
        currentPhrase = "No phrases available.";
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load phrases: $e');
      currentPhrase = "Failed to load phrases: $e";
      notifyListeners();
    }
  }

  void getNextPhrase() {
    final random = Random();
    if (phrases.isNotEmpty) {
      phrases.shuffle();
      currentPhrase = phrases.removeLast();
    } else {
      currentPhrase = "No phrases available.";
    }
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite(String phrase) {
    if (favorites.contains(phrase)) {
      favorites.remove(phrase);
    } else {
      favorites.add(phrase);
    }
    notifyListeners();
  }

  void removeFavorite(String phrase) {
    favorites.remove(phrase);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerador de Frases'),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    IconData icon;
    if (appState.favorites.contains(appState.currentPhrase)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tema: Amizade', // Texto inicial
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          BigCard(phrase: appState.currentPhrase),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(appState.currentPhrase);
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNextPhrase();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final String phrase;

  const BigCard({required this.phrase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headline6!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          phrase,
          style: style,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView.builder(
      itemCount: appState.favorites.length,
      itemBuilder: (context, index) {
        final phrase = appState.favorites[index];
        return ListTile(
          leading: Icon(Icons.favorite),
          title: Text(phrase),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              appState.removeFavorite(phrase);
            },
            tooltip: 'Remove',
          ),
        );
      },
    );
  }
}
