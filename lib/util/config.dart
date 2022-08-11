part of tetris_attack;

/////////////////////////////////////////////////////////////////////////////
// Port for the rest api.                                                  //
// Set localHosting to true, if you are running the app local.             //
/////////////////////////////////////////////////////////////////////////////
const restPort = '5000';

/////////////////////////////////////////////////////////////////////////////
// Initial durations for the timers used in the game.                      //
/////////////////////////////////////////////////////////////////////////////
// Interval after which the time gets counted up, should be 1 to represent seconds.
const Duration timeSpeed = Duration(seconds: 1);
// Interval between increasing the new block appearance rate.
// Increase this value if the game progresses too fast.
const Duration speedLevelSpeed = Duration(seconds: 15);
// Interval between each refresh of the model and the view, aka framerate.
// I DO NOT RECOMMEND GOING LOWER THAN 100MS AS IT BECOMES NEARLY IMPOSSIBLE TO PLAY, ITS TOO FAST!
const Duration gameSpeed = Duration(milliseconds: 100);
// Initial interval between the rate in which new blocks spawn.
// Increase this value if the game progresses too fast.
const Duration newBlockSpeed = Duration(seconds: 5);

/////////////////////////////////////////////////////////////////////////////
// Influences the multiplier of new blocks appearing.                      //
// Lower numbers make the game accelerate more quickly.                    //
/////////////////////////////////////////////////////////////////////////////
const double speedIncrease = 0.96;

/////////////////////////////////////////////////////////////////////////////
// Number of puzzle levels should be higher than 0.                        //
// If you increase the count, make sure to also add the levels             //
// Into web/res/level named "level" + number. No further changes need to   //
// be made. You can take one of the already existing levels as template.   //
/////////////////////////////////////////////////////////////////////////////
const int puzzleLevelCount = 9;

/////////////////////////////////////////////////////////////////////////////
// Game dimensions                                                         //
// If you alter these you should also adjust all the levels in the         //
// web/res/levels folder to match the dimensions. Other than that,         //
// there shouldn't be other places to adjust.                              //
// I still advice to leave the default values (16, 9)                      //
// as it seems to be the best visual representation.                       //
/////////////////////////////////////////////////////////////////////////////
const int gameRows = 16;
const int gameCols = 6;

/////////////////////////////////////////////////////////////////////////////
// Blocks + Selector                                                       //
// You could technically change the strings, but that wont change much,    //
// other than making it more work to also change the CSS file accordingly. //
// You can however disable the eradicator block here.                      //
/////////////////////////////////////////////////////////////////////////////
// Enable 5 combo block that removes matched color.
const bool enableEradicatorBlock = true;
// All block colors in the game.
const List<String> gameColors = ['purple', 'red', 'blue', 'yellow', 'green', 'orange'];
// String for the empty block.
const String emptyBlockS = 'empty';
// String for the selector.
const String selectorSLeft = 'selector-left';
const String selectorSRight = 'selector-right';

/////////////////////////////////////////////////////////////////////////////
// Keyboard inputs for the game.                                           //
// You can freely adjust these to whatever settings you prefer.            //
/////////////////////////////////////////////////////////////////////////////
// Up
const primaryUp = KeyCode.UP;
const secondaryUp = KeyCode.W;
// Down
const primaryDown = KeyCode.DOWN;
const secondaryDown = KeyCode.S;
// Left
const primaryLeft = KeyCode.LEFT;
const secondaryLeft = KeyCode.A;
// Right
const primaryRight = KeyCode.RIGHT;
const secondaryRight = KeyCode.D;
// Swap
const primarySwap = KeyCode.SPACE;
const secondarySwap = KeyCode.E;
// Push new blocks.
const primaryPushStones = KeyCode.SHIFT;
const secondaryPushStones = KeyCode.ENTER;
// Pause game
const primaryPauseGame = KeyCode.ESC;
const secondaryPauseGame = KeyCode.P;
// Reset puzzle mode
const primaryResetPuzzle = KeyCode.R;

/////////////////////////////////////////////////////////////////////////////
// Scores for actions.                                                     //
/////////////////////////////////////////////////////////////////////////////
// Score gained for each destroyed block with an eradicator block.
const eradicatorBlockPoint = 50;
// Base score gained by matching, this value will be multiplied by
// (matches - 2) * matches, to reward the player for bigger matches.
const baseScorePoints = 10;

/////////////////////////////////////////////////////////////////////////////
// Enum for gamemodes.                                                     //
/////////////////////////////////////////////////////////////////////////////
enum Gamemode {
  survival,
  puzzle
}

enum Gamestate {
  running,
  paused,
  lost
}