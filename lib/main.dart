import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithm Visualization',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    var defaultOutlineBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(15.0),
    );

    return SizedBox(
      width: 250.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                onPressed: () {},
                tooltip: 'Close sidebar',
                icon: const Icon(Icons.menu_open_outlined),
              ),
            ),
            SizedBox(
              height: 42.0,
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: defaultOutlineBorder,
                  focusedBorder: defaultOutlineBorder,
                  border: defaultOutlineBorder,
                  hintText: 'Filter algorithms',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  fillColor: Colors.black12,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView(
                children: const [
                  SidebarList(name: 'Dijkstra\'s algorithm'),
                  SidebarList(name: 'A (A-star) Algorithm*'),
                  SidebarList(name: 'Bellman-Ford Algorithm'),
                  SidebarList(name: 'Floyd-Warshall Algorithm'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarList extends StatelessWidget {
  const SidebarList({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), child: Text(name),);
    return InkWell(
      onTap: () {}, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), child: Text(name),),
    );
  }
}
