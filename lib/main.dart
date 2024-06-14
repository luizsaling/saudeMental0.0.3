import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'meditationplayerscreen.dart';
import 'dart:math';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => MoodProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: AppContainer(),
    );
  }
}

class AppContainer extends StatefulWidget {
  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int _currentIndex = 0;
  List<Widget> _screens = [
    MoodTrackerScreen(),
    MeditationScreen(),
    PlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.self_improvement),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MoodTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá! Como esta se sentindo?'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => moodProvider.addMood('Feliz'),
            child: Text('Feliz'),
          ),
          ElevatedButton(
            onPressed: () => moodProvider.addMood('Triste'),
            child: Text('Triste'),
          ),
          ElevatedButton(
            onPressed: () => moodProvider.addMood('Normal'),
            child: Text('Normal'),
          ),
          Expanded(
            child: FutureBuilder<List<Mood>>(
              future: moodProvider.moods,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Sem humor gravado');
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final mood = snapshot.data![index];
                    return ListTile(
                      title: Text(mood.mood),
                      subtitle: Text(mood.date),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Mood {
  final int id;
  final String date;
  final String mood;

  Mood({required this.id, required this.date, required this.mood});

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      id: map['id'],
      date: map['date'],
      mood: map['mood'],
    );
  }
}

class MoodProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Mood>> get moods async {
    final List<Map<String, dynamic>> maps = await _dbHelper.getMoods();
    return List.generate(maps.length, (i) {
      return Mood.fromMap(maps[i]);
    });
  }

  void addMood(String mood) async {
    await _dbHelper.insertMood(DateTime.now().toString(), mood);
    notifyListeners();
  }
}

class MeditationScreen extends StatelessWidget {
  List<Meditation> get meditations => [
        Meditation(
            title: 'Meditar',
            url: 'https://youtu.be/ItO5o9hXf3o?list=RDQMemvGIAV61uI'),
        Meditation(
            title: 'Foco',
            url: 'https://www.youtube.com/watch?v=89l2WJC9LWI&t=19096s'),
        Meditation(
            title: 'Dormir',
            url: 'https://www.youtube.com/watch?v=rE6grcHZTFo'),
        Meditation(
            title: 'Paisagens',
            url: 'https://www.youtube.com/watch?v=Y4goaZhNt4k'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vídeos de ajuda'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: meditations.length,
              itemBuilder: (context, index) {
                final meditation = meditations[index];
                return ListTile(
                  title: Text(meditation.title),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MeditationPlayerScreen(meditation: meditation),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatefulWidget {
  @override
  _PlaceholderScreenState createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  final List<String> _texts = [
    'Acredite em você!',
    'Nunca desista dos seus sonhos.',
    'A persistência é o caminho do êxito.',
    'O sucesso é a soma de pequenos esforços repetidos dia após dia.',
    'Você é mais forte do que imagina.',
  ];

  String _displayedText = 'Pressione o botão para uma mensagem motivacional!';

  void _showRandomText() {
    final random = Random();
    setState(() {
      _displayedText = _texts[random.nextInt(_texts.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MOTIVAÇÃO'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _displayedText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showRandomText,
              child: Text('Mostrar Mensagem'),
            ),
          ],
        ),
      ),
    );
  }
}
