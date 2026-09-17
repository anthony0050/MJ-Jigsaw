import 'package:flutter/material.dart';

void main() {
  runApp(const MJJigsawApp());
}

class MJJigsawApp extends StatelessWidget {
  const MJJigsawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Michael Jackson 拼图狂欢',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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
  final List<Map<String, String>> mjGallery = [
    {
      'title': 'Billie Jean Silhouette',
      'path': 'assets/mj1.png',
    },
    {
      'title': 'Stage Spotlight',
      'path': 'assets/mj2.png',
    },
    {
      'title': 'Live Concert Energy',
      'path': 'assets/mj3.png',
    },
  ];

  int selectedImageIndex = 0;
  int gridSize = 3;

  late List<int?> currentBoard;
  late List<int> poolPieces;

  int? selectedPoolIndex;
  int moveCount = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    int total = gridSize * gridSize;
    currentBoard = List.filled(total, null);
    poolPieces = List.generate(total, (i) => i)..shuffle();
    selectedPoolIndex = null;
    moveCount = 0;
    setState(() {});
  }

  void _onPoolTileTap(int poolIdx) {
    setState(() {
      if (selectedPoolIndex == poolIdx) {
        selectedPoolIndex = null;
      } else {
        selectedPoolIndex = poolIdx;
      }
    });
  }

  void _onBoardSlotTap(int boardIdx) {
    setState(() {
      if (selectedPoolIndex != null) {
        int piece = poolPieces.removeAt(selectedPoolIndex!);
        if (currentBoard[boardIdx] != null) {
          poolPieces.add(currentBoard[boardIdx]!);
        }
        currentBoard[boardIdx] = piece;
        selectedPoolIndex = null;
        moveCount++;
        _checkWin();
      } else if (currentBoard[boardIdx] != null) {
        int piece = currentBoard[boardIdx]!;
        currentBoard[boardIdx] = null;
        poolPieces.add(piece);
        moveCount++;
      }
    });
  }

  void _checkWin() {
    bool isComplete = currentBoard.length == gridSize * gridSize;
    for (int i = 0; i < currentBoard.length; i++) {
      if (currentBoard[i] != i) {
        isComplete = false;
        break;
      }
    }
    if (isComplete) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 恭喜通关！'),
          content: Text('你一共使用了 $moveCount 步完成了拼图！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('再玩一次'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = mjGallery[selectedImageIndex]['path']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Michael Jackson 拼图狂欢'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: gridSize,
                  items: const [
                    DropdownMenuItem(value: 3, child: Text('难度: 3x3 (简单)')),
                    DropdownMenuItem(value: 4, child: Text('难度: 4x4 (中等)')),
                    DropdownMenuItem(value: 5, child: Text('难度: 5x5 (大师)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      gridSize = val;
                      _resetGame();
                    }
                  },
                ),
                Text('步数: $moveCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mjGallery.length,
              itemBuilder: (context, idx) {
                bool isSelected = idx == selectedImageIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = idx;
                      _resetGame();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        mjGallery[idx]['title']!,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int? piece = currentBoard[index];
                    return GestureDetector(
                      onTap: () => _onBoardSlotTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                          color: Colors.black26,
                        ),
                        child: piece != null
                            ? JigsawPieceWidget(
                                imagePath: imagePath,
                                pieceIndex: piece,
                                gridSize: gridSize,
                              )
                            : Center(
                                child: Text('${index + 1}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.2))),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Text('👇 将下方散落的碎片拖拽至上方位置：'),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: poolPieces.length,
                itemBuilder: (context, idx) {
                  bool isSelected = selectedPoolIndex == idx;
                  int piece = poolPieces[idx];
                  return GestureDetector(
                    onTap: () => _onPoolTileTap(idx),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: JigsawPieceWidget(
                        imagePath: imagePath,
                        pieceIndex: piece,
                        gridSize: gridSize,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JigsawPieceWidget extends StatelessWidget {
  final String imagePath;
  final int pieceIndex;
  final int gridSize;

  const JigsawPieceWidget({
    super.key,
    required this.imagePath,
    required this.pieceIndex,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    int row = pieceIndex ~/ gridSize;
    int col = pieceIndex % gridSize;

    double alignX = (gridSize > 1) ? -1.0 + (col / (gridSize - 1)) * 2.0 : 0.0;
    double alignY = (gridSize > 1) ? -1.0 + (row / (gridSize - 1)) * 2.0 : 0.0;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.none,
        alignment: Alignment(alignX, alignY),
        child: SizedBox(
          width: 300,
          height: 300,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.amber),
            ),
          ),
        ),
      ),
    );
  }
}
