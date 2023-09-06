import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyDiaryApp());

class MyDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyDiary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'MyDiary',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationScreen()),
                );
              },
              child: Text('Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String username;
  final String password;

  User(this.username, this.password);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['username'], json['password']);
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class DiaryEntry {
  final String username;
  final String text;

  DiaryEntry(this.username, this.text);

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(json['username'], json['text']);
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'text': text};
  }
}

class UserManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/diary.json');
  }

  Future<void> saveDiaryEntry(String username, String text) async {
    final diaryEntry = DiaryEntry(username, text);
    final file = await _localFile;
    final List<dynamic> existingEntries = await getDiaryEntries();

    existingEntries.add(diaryEntry.toJson());
    await file.writeAsString(json.encode(existingEntries));
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    try {
      final file = await _localFile;
      final exists = await file.exists();
      if (!exists) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => DiaryEntry.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);

    final file = await _localFile;
    final jsonList = users.map((user) => user.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  Future<List<User>> getUsers() async {
    try {
      final file = await _localFile;
      final exists = await file.exists();
      if (!exists) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> validateUser(String username, String password) async {
    final users = await getUsers();
    try {
      final matchingUser = users.firstWhere(
        (user) => user.username == username && user.password == password,
      );

      // Se o usuário for encontrado, retorna true
      return true;
    } catch (e) {
      // Se nenhum usuário correspondente for encontrado, lança uma exceção
      throw Exception('Usuário não encontrado');
    }
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserManager userManager = UserManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nome de Usuário'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;
                try {
                  final isValidUser = await userManager.validateUser(username, password);
                  if (isValidUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiaryScreen(username)),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erro de login'),
                          content: Text('Nome de usuário ou senha incorretos.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Erro de login'),
                        content: Text('Ocorreu um erro inesperado: $e'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Fazer Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserManager userManager = UserManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Nome de Usuário'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;
                final user = User(username, password);
                try {
                  await userManager.addUser(user);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Cadastro bem-sucedido'),
                        content: Text('Seu cadastro foi realizado com sucesso!'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context); // Voltar para a tela de login
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Erro de cadastro'),
                        content: Text('Ocorreu um erro inesperado ao cadastrar: $e'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Cadastrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryScreen extends StatefulWidget {
  final String username;

  DiaryScreen(this.username);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController diaryController = TextEditingController();
  final UserManager userManager = UserManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bem-vindo, ${widget.username}!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            TextField(
              controller: diaryController,
              decoration: InputDecoration(labelText: 'Descreva o seu dia'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = diaryController.text;
                final username = widget.username;
                try {
                  await userManager.saveDiaryEntry(username, text);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Diário Salvo'),
                        content: Text('Sua entrada de diário foi salva com sucesso!'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Erro ao salvar diário'),
                        content: Text('Ocorreu um erro inesperado ao salvar o diário: $e'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Salvar Diário'),
            ),
            SizedBox(height: 20),
            Text(
              'Histórico do Diário:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: FutureBuilder<List<DiaryEntry>>(
                future: userManager.getDiaryEntries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else {
                    final entries = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          title: Text(entry.text),
                          subtitle: Text('Por: ${entry.username}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
