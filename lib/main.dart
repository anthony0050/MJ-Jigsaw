import 'package:flutter/material.dart';

void main() {
  runApp(const MJJigsawApp());
}

class MJJigsawApp extends StatelessWidget {
  const MJJigsawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MJ Jigsaw Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.amber,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 4,
        ),
      ),
      home: const JigsawGameScreen(),
    );
  }
}

class JigsawGameScreen extends StatefulWidget {
  const JigsawGameScreen({super.key});

  @override
  State<JigsawGameScreen> createState() => _JigsawGameScreenState();
}

class _JigsawGameScreenState extends State<JigsawGameScreen> {
  int gridDimension = 3; // Default 3x3
  
  // High quality MJ artwork / classic poses
  final List<Map<String, String>> mjGallery = [
    {
      'title': 'Billie Jean Silhouette',
      'url': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=800'
    },
    {
      'title': 'Stage Spotlight',
      'url': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=800'
    },
    {
      'title': 'Live Concert Energy',
      'url': 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=800'
    },
  ];

  int selectedImageIndex = 0;
  List<int> puzzlePieces = [];
  List<int?> completedBoard = [];
  bool isCompleted = false;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    int totalPieces = gridDimension * gridDimension;
    puzzlePieces = List.generate(totalPieces, (index) => index);
    puzzlePieces.shuffle();
    completedBoard = List.filled(totalPieces, null);
    isCompleted = false;
    moves = 0;
    setState(() {});
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < completedBoard.length; i++) {
      if (completedBoard[i] != i) {
        win = false;
        break;
      }
    }
    if (win) {
      setState(() {
        isCompleted = true;
      });
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Hee-Hee! 挑战成功！', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '太棒了！你用了 $moves 步成功拼接了《${mjGallery[selectedImageIndex]['title']}》拼图！',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('再来一局', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = gridDimension * gridDimension;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Michael Jackson 拼图狂欢', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _resetGame,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Level & Stats Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: gridDimension,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  underline: Container(height: 2, color: Colors.amber),
                  items: const [
                    DropdownMenuItem(value: 3, child: Text('难度: 3x3 (简单)')),
                    DropdownMenuItem(value: 4, child: Text('难度: 4x4 (中等)')),
                    DropdownMenuItem(value: 5, child: Text('难度: 5x5 (大师)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        gridDimension = val;
                        _resetGame();
                      });
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text('步数: $moves', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Image Selection Bar
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: mjGallery.length,
              itemBuilder: (context, idx) {
                bool isSelected = selectedImageIndex == idx;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = idx;
                      _resetGame();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.horizontal(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.amber : Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        mjGallery[idx]['title']!,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Main Board Target Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black38,
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridDimension,
                    ),
                    itemCount: total,
                    itemBuilder: (context, index) {
                      return DragTarget<int>(
                        onAcceptWithDetails: (details) {
                          int pieceIndex = details.data;
                          setState(() {
                            completedBoard[index] = pieceIndex;
                            puzzlePieces.remove(pieceIndex);
                            moves++;
                          });
                          _checkWin();
                        },
                        builder: (context, candidateData, rejectedData) {
                          int? currentPiece = completedBoard[index];
                          return Container(
                            margin: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white12),
                              color: Colors.black26,
                            ),
                            child: currentPiece != null
                                ? Image.network(
                                    mjGallery[selectedImageIndex]['url']!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white24, fontSize: 18),
                                    ),
                                  ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              '👇 将下方散落的碎片拖拽至上方位置：',
              style: TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),

          // Bottom Draggable Pieces Tray
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: puzzlePieces.isEmpty
                  ? const Center(
                      child: Text('全部碎片已就位！', style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: puzzlePieces.map((pieceIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Draggable<int>(
                              data: pieceIndex,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.amber, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      mjGallery[selectedImageIndex]['url']!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.2,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber.withOpacity(0.6)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    mjGallery[selectedImageIndex]['url']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
