part of tetris_attack;

/// This class the the playing field of the game.
class Field {

  final List<List<String>> _blocks = List.generate(gameRows, (row) =>
      List.generate(gameCols, (col) =>
        emptyBlockS, growable: false),
      growable: false
  );

  final Selector _selector = Selector(3, 10);
  final _rand = Random();

  List<Tuple<int>> _removedBlocks = [];

  final Gamemode _mode;
  int _scoreIncrease  = 0;
  int _blockCount     = 0;
  bool _gameOver      = false;
  bool _blocksFalling = false;

  /// The selector for the player to swap blocks around.
  Selector get selector               => _selector;
  /// List of all the blocks currently in game.
  List<List<String>> get blocks       => _blocks;
  /// List of blocks that recently got removed, used to animate the removal.
  List<Tuple<int>> get removedBlocks  => _removedBlocks;
  /// Used to store the information how many blocks are still on the field.
  int get blockCount                  => _blockCount;
  /// Used to get the generated points from the last move.
  int get scoreIncrease               => _scoreIncrease;
  /// If true, a stone has reached the top and the game is now over.
  bool get gameOver                   => _gameOver;
  /// Returns true if blocks are still falling after a move.
  bool get blocksFalling              => _blocksFalling;

  Field(this._mode);

  /// Called everytime the field should be updated.
  void updateField() {
    _applyGravity();
    _checkIfMatched();
    _blockCount = _countBlocks();
  }

  /// Used to move the selector on the current playing field, also checks if the selector is colliding with walls.
  void moveSelector(int col, int row) {
    if((selector.posRow + row >= 0) && (selector.posRow + row < gameRows)) {
      selector.moveSelector(row, 0);
    }
    if((selector.posCol + col >= 1) && (selector.posCol + col < gameCols)) {
      selector.moveSelector(0, col);
    }
  }

  /// Initialized the first n rows of blocks.
  void initFirstBlocks(int n) {
    for(var row = 1; row < n; row++) {
      for(var col = 0; col < gameCols; col++) {
        _blocks[gameRows - row][col] = gameColors[_rand.nextInt(gameColors.length)];
      }
    }
  }

  /// Loads a puzzlelevel out of a JSON map.
  void loadLevel(Map<String, dynamic> level) {
    for(var row = 0; row < gameRows; row++) {
      for(var col = 0; col < gameCols; col++) {
        var cell = level['level'][row][col];
        if(cell != 0) blocks[row][col] = gameColors[cell - 1];
      }
    }
  }

  /// Method to swap the two blocks that the selector is currently on.
  void swapBlocks() {
    var col = _selector.posCol;
    var row = _selector.posRow;
    var left = _blocks[row][col - 1];
    var right = _blocks[row][col];

    if(left == 'eradicator' && right != emptyBlockS) {
      _eradicateColor(right);
      _blocks[row][col - 1] = emptyBlockS;
    } else if(left != emptyBlockS && right == 'eradicator') {
      _eradicateColor(left);
      _blocks[row][col] = emptyBlockS;
    } else {
      _blocks[row][col - 1] = right;
      _blocks[row][col] = left;
    }
  }

  /// Method to push all currently in play blocks up and add a new row of blocks on the last row of the playing field.
  void generateNewBlocks() {
    // Push the selector up one row, as it feels clunky if not.
    moveSelector(0, -1);
    // Push all blocks one row up.
    for(var row = 0; row < gameRows; row++) {
      for(var col = 0; col < gameCols; col++) {
        var type = blocks[row][col];
        if(type != emptyBlockS) {
          // If there was a block at row = 0, lose the game.
          if(row == 0) {
            _gameOver = true;
            return;
          } else {
            _blocks[row - 1][col] = type;
            _blocks[row][col] = emptyBlockS;
          }
        }
        // Add a new row of blocks on the last row.
        if(row == gameRows - 1) {
          blocks[gameRows - 1][col] = gameColors[_rand.nextInt(gameColors.length)];
        }
      }
    }
  }

  /// Used to reset the score increase after getting it in an update.
  void resetScoreIncrease() {
    _scoreIncrease = 0;
  }

  /// Counts the blocks that are currently in the field.
  int _countBlocks() {
    var count = 0;
    for(var row = 0; row < gameRows; row++) {
      for(var col = 0; col < gameCols; col++) {
        if(blocks[row][col] != emptyBlockS) count++;
      }
    }
    return count;
  }

  /// Method used for the eradicator block,
  /// removes all colors of a kind (even other eradicator blocks!).
  void _eradicateColor(String color) {
    for(var row = 0; row < gameRows; row++) {
      for (var col = 0; col < gameCols; col++) {
        if(blocks[row][col] == color) {
          blocks[row][col] = emptyBlockS;
          _scoreIncrease += eradicatorBlockPoint;
        }
      }
    }
  }

  /// Method to check if 3 or more blocks are in a row, so they get removed once the condition is true.
  void _checkIfMatched() {
    // Initialize a list for all positions of all matched blocks.
    var blocksToRemove = <Tuple<int>>[];
    // Initialize a list for eradicators to be generated under the condition that 5 blocks are matched in a line.
    var addEradicators = <Tuple<int>>[];
    if(!_blocksFalling) {
      for(var row = 0; row < gameRows; row++) {
        for(var col = 0; col < gameCols; col++) {
          // Get the color of the current block
          var color = blocks[row][col];
          // If the current block is not an empty or special block, check for collision.
          if(color != emptyBlockS && color != 'eradicator') {
            // Current chain in the X and Y direction, starts at 1 since we are already looking at 1 block.
            var chainX = 1;
            var chainY = 1;
            /*
           * We are looking at the field from left to right top to bottom,
           * searching for chains that consists of 3 or more same colors:
           *  ------------>
           *  =========   ||
           *  |r|r|b|b|   ||
           *  =========   ||
           *  |r|r|r|b|   ||
           *  =========   ||
           *  |r|y|g|g|   ||
           *  =========   \/
           *
           * In this example we find 3 reds in the second row and 3 red in the first column.
           * Those positions will be stored in the blocksToRemove list in the form of tuples,
           * to check if an already added position is not already inside.
           * Once the whole field is traversed, blocks at the found positions will be removed.
           * Points will be awarded according to the total amount of removed blocks at once.
           */
            while(row + chainX < gameRows) {
              if(blocks[row + chainX][col] == color) {
                chainX++;
              } else {
                break;
              }
            }
            while(col + chainY < gameCols) {
              if(blocks[row][col + chainY] == color) {
                chainY++;
              } else {
                break;
              }
            }
            // If the player made a match with 5 of the same color in a straight line,
            // reward the player by giving out a eradicator block.
            if(_mode == Gamemode.survival && enableEradicatorBlock) {
              if(chainX >= 5) addEradicators.add(Tuple(row + 2, col));
              if(chainY >= 5) addEradicators.add(Tuple(row, col + 2));
            }
            if(chainX >= 3) {
              for(var delX = 0; delX < chainX; delX++) {
                var block = Tuple(row + delX, col);
                var addBlock = true;
                for(var tuples in blocksToRemove) {
                  if(tuples.equals(block)) {
                    addBlock = false;
                  }
                }
                if(addBlock) blocksToRemove.add(block);
              }
            }
            if(chainY >= 3) {
              for(var delY = 0; delY < chainY; delY++) {
                var block = Tuple(row, col + delY);
                var addBlock = true;
                for(var tuples in blocksToRemove) {
                  if(tuples.equals(block)) addBlock = false;
                }
                if(addBlock) blocksToRemove.add(block);
              }
            }
          }
        }
      }
      _scoreIncrease = baseScorePoints * (blocksToRemove.length - 2) * blocksToRemove.length;
    }
    _removedBlocks = blocksToRemove;
    if(blocksToRemove.isNotEmpty) _blocksFalling = true;
    for(var block in blocksToRemove) {
      _blocks[block.first][block.second] = emptyBlockS;
    }
    for(var specialBlock in addEradicators) {
      _blocks[specialBlock.first][specialBlock.second] = 'eradicator';
    }
  }

  /// Method that checks if there are blocks below the block, or the last row, if not lets the blocks fall down until the block is over another block or on the last row.
  void _applyGravity() {
    // reset the falling blocks flag.
    _blocksFalling = false;
    // Traverse the field from the bottom to the top, so lower blocks fall first and make room for upper blocks.
    for(var row = gameRows - 2; row >= 0; row--) {
      for(var col = 0; col < gameCols; col++) {
        var type = blocks[row][col];
        // If below is empty, move down by 1 slot and replace initial position with an empty block.
        if(type != emptyBlockS && blocks[row + 1][col] == emptyBlockS) {
          _blocks[row + 1][col] = type;
          _blocks[row][col] = emptyBlockS;
          // At least 1 block is falling now, so we set the flag.
          _blocksFalling = true;
        }
      }
    }
  }
}