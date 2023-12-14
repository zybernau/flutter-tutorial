import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
// import 'package:audioplayers/audioplayers.dart';

// const sound1Path = "sound2.mp3";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          home: MyHomePage()),
    );
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
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex. ');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    // return Center(
    //   child: Column(
    //     children: [
    //       Text('Favourites: '),
    //       for (var pr in appState.favorites)
    //         BigCard(pair: pr),
    //     ]) ,);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Favourites: Total ${appState.favorites.length}.'),
        ),
        for (var pr in appState.favorites)
          ListTile(
            iconColor: theme.colorScheme.primary,
            leading: Icon(Icons.favorite),
            title: Text(pr.asLowerCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var lastFour = appState.lastFour;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: lastFour.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    iconColor: theme.colorScheme.primary,
                    leading: lastFour[index].containsValue(true)?Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    title: Text(lastFour[index].keys.first.asLowerCase));
              },

              )

            ),
          // ListView(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.all(21),
          //       child: Text('History'),
          //     ),
          //     for (Map his in appState.lastFour)
          //       ListTile(
          //           iconColor: theme.colorScheme.primary,
          //           leading: his.containsValue(true)?Icon(Icons.favorite) : Icon(Icons.favorite_border),
          //           title: Text(his.keys.first.asLowerCase)),
          //   ],
          // ),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
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

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    if (lastFour.length >= 4) {
      lastFour.removeAt(0);
    }
    var isLastFav = false;
    if (favorites.contains(current)) {
      isLastFav = true;
    }
    final entry = Map();
    entry[current] = isLastFav;
    lastFour.add(entry);

    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  var lastFour = <Map>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} - ${pair.second}",
        ),
      ),
    );
  }
}
