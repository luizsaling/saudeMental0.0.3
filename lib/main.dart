import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_helper.dart';
import 'meditationplayerscreen.dart';
import 'package:animations/animations.dart';
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Humor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Meditação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken),
            label: 'Ajuda',
          ),
        ],
      ),
    );
  }
}

class MoodTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFF26254D),
      appBar: AppBar(
        title: Text('Olá! Como está se sentindo?'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => moodProvider.addMood('😊'),
            child: Text('😊'),
          ),
          ElevatedButton(
            onPressed: () => moodProvider.addMood('😢'),
            child: Text('😢'),
          ),
          ElevatedButton(
            onPressed: () => moodProvider.addMood('😐'),
            child: Text('😐'),
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
            title: 'Focar',
            url: 'https://www.youtube.com/watch?v=89l2WJC9LWI&t=19096s'),
        Meditation(
            title: 'Dormir',
            url: 'https://www.youtube.com/watch?v=rE6grcHZTFo'),
        Meditation(
            title: 'Paisagens',
            url: 'https://www.youtube.com/watch?v=Y4goaZhNt4k'),
        Meditation(
            title: 'Estudar',
            url: 'https://www.youtube.com/watch?v=n61ULEU7CO0&t=4116s'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF26254D),
      appBar: AppBar(
        title: Text('O que gostaria de fazer?'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            itemCount: meditations.length,
            itemBuilder: (context, index) {
              final meditation = meditations[index];
              return ListTile(
                title: Text(
                  meditation.title,
                  style: TextStyle(color: Colors.white),
                ),
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
      ),
    );
  }
}

class PlaceholderScreen extends StatefulWidget {
  @override
  PlaceholderScreenState createState() => PlaceholderScreenState();
}

class PlaceholderScreenState extends State<PlaceholderScreen> {
  final List<String> _texts = [
    'Acredite em você!',
    'Nunca desista dos seus sonhos.',
    'A persistência é o caminho do êxito.',
    'O sucesso é a soma de pequenos esforços repetidos dia após dia.',
    'Você é mais forte do que imagina.',
    'Respire fundo, você está mais perto do que imagina.',
    'Este momento difícil vai passar, e vou sair mais forte.',
    'Cada dia é uma nova oportunidade para recomeçar.',
    'O que importa é o progresso, não a perfeição.',
    'Aceite o que você não pode mudar, e concentre-se no que pode.',
    'As dificuldades de hoje são os degraus que te levam ao sucesso amanhã.',
    'Seja gentil consigo mesmo, você está fazendo o melhor que pode.',
    'Lembre-se: você é mais forte do que pensa e mais corajoso do que imagina.'
  ];

  String _displayedText = 'Pressione para sentir-se MELHOR!';

  void _showRandomText() {
    final random = Random();
    setState(() {
      _displayedText = _texts[random.nextInt(_texts.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF26254D),
      appBar: AppBar(
        title: Text('MOTIVAÇÃO'),
        backgroundColor: Colors.black,
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
              child: Text('#CONFIA!'),
            ),
          ],
        ),
      ),
    );
  }
}
