//This is Assignment 4 (Loops and Functions(Unit 1-14)) for COMP1010's summer session.

//This file is labelled VisenNeelanshA4Q6, which contains code covering all 6 questions in the assignment.

//The following program contains a Cannon Game, where the user controls a tank located on the left side of the canvas
//that is trying to hit a target located on the right side of the canvas. Between the tank and target is a wall obstacle. 



//=============================
//GLOBAL VARIABLES AND CONSTANTS FOR OBJECTS ON CANVAS

//WALL OBSTACLE
int xWall, yWall;  //WALL COORDINATES
final int WALL_HEIGHT = 200;
final int WALL_WIDTH = 100;
int wallLeft;  
int wallTop;
final int BRICK_WIDTH = 10;
final int BRICK_HEIGHT = 5;

//WHITE STARS
int xStar, yStar;  //STAR COORDINATES
final int STAR_SIZE = 10;
final int STAR_SPACING = 50;

//GREEN GRASS
int xGrass, yGrass;  //GRASS COORDINATES
final int GRASS_SPACING = 4;
final int SHORT_GRASS = 10;

//RED TARGET
float targetEdge;  //TARGET X COORDINATE
int targetWidth = 100;  //STARTING TARGET SIZE
final int MIN_TARGET = 55;  //TARGET WILL SHRINK AFTER A LEVEL IS CLEARED UNTIL MIN_TARGET IS REACHED
final int TARGET_HEIGHT = 25;

//WHITE TANK
int xTank, yTank;  //TANK COORDINATES
final int TANK_SIZE = 50;
int TANK_START;  //TANK WILL REVERT TO A STARTING POSITION AFTER A LEVEL IS CLEARED

//WHITE BARREL
float barrelEndX, barrelEndY;  //CANNON COORDINATES
int BARREL_START_X, BARREL_START_Y;  //PIVOTS AT THE CENTER OF TANK
final int BARREL_SIZE = 50;
float angle;  //BARREL ANGLE IS RESTRICTED BETWEEN STRAIGHT UP AND STRAIGHT RIGHT 

//WHITE CANNONBALL (TANK PROJECTILE)
float xBall, yBall;  //BALL COORDINATES
int BALL_SIZE = 10;
final int VELO = 75;  //BALL VELOCITY CONSTANT
float time = 0.0;  //TIME BEGINS AT 0 AND INCREASES BY TIME_STEP
float flightTime, timeFired; 
float TIME_STEP = 0.08;
float G = -9.8;  //GRAVITATIONAL CONSTANT FOT BALL FLIGHT

//RED BOMBS
final int BOMB_SIZE = 10;  
final int NUM_BOMBS = 10;
float bombSpeed;  //INCREASES AFTER A LEVEL IS CLEARED
float[] xBomb = new float[NUM_BOMBS];  //X COORDINATE OF BOMBS IS AN ARRAY 
float[] yBomb = new float[NUM_BOMBS];  //Y COORDINATE OF BOMBS IS AN ARRAY

//=============================
//OTHER CODING VARIABLES AND CONSTANTS
boolean onScreen;  //TRUE IF BALL IS ON THE CANVAS
boolean inProgress = false;  //GAME IS NOT IN PROGRESS WHEN PROGRAM BEGINS 
int hits;  //INCREASES EVERY TIME THE TARGET IS HIT BY THE BALL
int shots;  //INCREASES EVERY TIME THE CANNON IS FIRED
int levels = 1;  //GAME BEGINS AT LEVEL 1 AND INCREASES AFTER THE TARGET IS HIT 3 TIMES
int MAX_LEVEL = 10;  //GAME IS CAPPED AT 10 LEVELS AND CONTINUES UNTIL PLAYER LOSES
float newTarget;  //TARGET LOCATION CHANGES AFTER A LEVEL IS CLEARED



//=============================
//GAME CODE

void setup() {  //INITIAL SETUP VALUES FOR THE GAME
  size(800, 600);
  TANK_START = width/8;  //STARTING LOCATION OF TANK
  xTank = TANK_START;
  yTank = height-50;
  targetEdge = random(3*width/5, width - targetWidth);  //TARGET LOCATION IS RANDOMLY SELECTED EACH LEVEL (TO THE RIGHT OF THE WALL)
  angle = 0;  //CANNON ANGLE BEGINS PARALLEL TO THE GROUND 
  textSize(25);  //FONT SIZE
  textAlign(CENTER);  
  wallLeft = width/2 - WALL_WIDTH/2;
  wallTop = height - WALL_HEIGHT;
  
  for(int i = 0; i < NUM_BOMBS; i++) {  //GOING THROUGH ARRAY FOR BOMB LOCATIONS
    xBomb[i] = (int)random(wallLeft);  //STARTING X COORDINATE OF THE BOMBS IS A RANDOM POINT LEFT OF THE WALL
    yBomb[i] = (int)random(height) - height - BOMB_SIZE/2;  //STARTING Y COORDINATE OF THE BOMBS IS JUST ABOVE THE CANVAS
  }
}


void draw() {  //CALLS THE GAME FUNCTIONS BELOW
  background(0);  //BLACK BACKGROUND
  brickWall();
  stars();
  grass();
  target();
  tank();
  ballLocation();
  gameStatus();
  bombs();
}


void brickWall() {  
//CODE THAT DRAWS THE WALL  
  fill(200, 0, 0);  //RED BRICKS
  stroke(255);  //WHITE OUTLINE OF BRICKS
  strokeWeight(1);  
  rect(wallLeft, wallTop, WALL_WIDTH + BRICK_WIDTH/2, WALL_HEIGHT);  //DRAWS THE INITIAL WALL OUTLINE
  for (xWall = wallLeft; xWall < width/2 + WALL_WIDTH/2; xWall += BRICK_WIDTH) {  //X COORDINATE FOR BRICK PATTERN
    for (yWall = wallTop; yWall < height; yWall += BRICK_HEIGHT) {  //Y COORDINATE FOR BRICK PATTERN
      if (yWall % BRICK_WIDTH == 0) {
        rect(xWall, yWall, BRICK_WIDTH, BRICK_HEIGHT);  //VERTICAL WHITE LINES ARE DRAWN
      } else {
        rect(xWall + BRICK_WIDTH/2, yWall, BRICK_WIDTH, BRICK_HEIGHT);  //VERTICAL WHITE LINES ARE OFFSET, FORMING A BRICK PATTERN ON THE WALL
      }
    }
  }
  
  //CODE THAT WRITES WALL MESSAGE AND RESETS BALL
  boolean hitWall = ballInObject(wallLeft, wallTop, WALL_WIDTH, WALL_HEIGHT, xBall, yBall);  //TRUE IF BALL HITS THE WALL
  if (hitWall) {
    fill(255);  //WHITE TEXT
    text("WALL HIT", width/2, height/2);  //MESSAGE IN CENTER OF CANVAS 
    resetShot();  //NEW BALL IN CANNON, PLAYER CAN NOW SHOOT AGAIN
  }
}


void stars() {
//CODE THAT DRAWS THE STARS
  fill(255);  //WHITE STARS
  for (xStar = STAR_SIZE; xStar <= width - STAR_SIZE; xStar += STAR_SPACING) {  //X COORDINATE FOR STAR
    for (yStar = 2*STAR_SIZE; yStar <= STAR_SPACING; yStar += 2*STAR_SIZE) {  //Y COORDINATE FOR STAR
      if (yStar < STAR_SPACING/2) {  //OFFSET STAR PATTERN
        ellipse(xStar, yStar, 2*STAR_SIZE/3, 2*STAR_SIZE/3);  //SMALLER STARS
      } 
      else {
        ellipse(xStar + STAR_SPACING/2, yStar, STAR_SIZE, STAR_SIZE);  //LARGER STARS
      }
    }
  }
}


void grass() {
//CODE THAT DRAWS THE GRASS
  strokeWeight(2);  
  stroke(0, 255, 0);  //GREEN GRASS
  for (xGrass = 0; xGrass <= width; xGrass += GRASS_SPACING) {  //X COORDINATE FOR GRASS
    for (yGrass = height - 2*SHORT_GRASS; yGrass <= height - SHORT_GRASS; yGrass += GRASS_SPACING) {  //Y COORDINATE FOR GRASS
      line(xGrass, height, xGrass, yGrass);  
    }
  }
}


void target() {
//CODE THAT DRAWS THE TARGET
  fill(255, 0, 0);  //RED TARGET
  rect(targetEdge, height - TARGET_HEIGHT, targetWidth, TARGET_HEIGHT);  
  
  //CODE THAT WRITES TARGET MESSAGE, CHANGES TARGET SIZE AND RESETS BALL
  fill(255);  //WHITE TEXT
  text("Hits: " + hits, width - 100, 150);
  text("Level: " + levels, width - 100, 200);
  boolean hitTarget = ballInObject(targetEdge, height - TARGET_HEIGHT, targetWidth, TARGET_HEIGHT, xBall, yBall);  //TRUE IF BALL HITS TARGET
  if (hitTarget) { 
    fill(255);
    text("TARGET HIT", width/2, height/2);
    hits++;  //HIT COUNTER INCREASES BY 1 
    if (hits >= levels * 3) {  //WHEN THE TARGET IS HIT THREE TIMES AT ITS CURRENT LOCATION
      levels++;  //LEVEL INCREASES BY 1
      targetWidth -= 5;  //TARGET SHRINKS
      xTank = TANK_START;  //TANK REVERTS TO STARTING LOCATION
      newTarget = random(480, 700);  //TARGET MOVES TO NEW RANDOM LOCATION 
      targetEdge = newTarget;  
      for(int i = 0; i < NUM_BOMBS; i++) {
        yBomb[i] = (int)random(height) - height - BOMB_SIZE/2;  //BOMBS GO BACK ABOVE THE CANVAS
      }
    }
    resetShot();  //NEW BALL IN CANNON, PLAYER CAN NOW SHOOT AGAIN
  }
  if (targetWidth <= MIN_TARGET) {  //TARGET WILL STOP SHRINKING ONCE IT REACHES ITS MINIMUM SIZE
    levels = min(levels, MAX_LEVEL);  //LEVELS CAP AT 10
    targetWidth = max(MIN_TARGET, targetWidth); 
  }
}


void tank() {
//CODE THAT DRAWS THE TANK
  barrel();  //THE CANNON BARREL IS ATTACHED TO THE TANK
  fill(255);
  noStroke();
  rect(xTank, yTank, TANK_SIZE, TANK_SIZE);
  text("Shots: " + shots, width - 100, 175); 
}


void barrel() {
//CODE THAT DRAWS THE CANNON BARREL
  BARREL_START_X = xTank + TANK_SIZE/2;  //X CENTER OF TANK
  BARREL_START_Y = yTank + TANK_SIZE/2;  //Y CENTER OF TANK
  barrelEndX = BARREL_START_X + BARREL_SIZE * cos(angle);  //X END OF BARREL CHANGES BASED ON ANGLE
  barrelEndY = BARREL_START_Y - BARREL_SIZE * sin(angle);  //Y END OF BARREL CHANGES BASED ON ANGLE
  stroke(255);
  strokeWeight(3);
  line(BARREL_START_X, BARREL_START_Y, barrelEndX, barrelEndY);
}


void ballLocation() {
//CODE THAT DISPLAYS PROJECTILE LOCATION ON CANVAS
  textAlign(LEFT);
  text("xBall: " + xBall, 50, 150);
  text("yBall: " + yBall, 50, 175);
  textAlign(CENTER);
}


void keyPressed() {
//CODE RUNS WHEN CERTAIN KEYS ARE PRESSED
  //MOVE TANK
  int k = keyCode;
  int TANK_SPEED = 5;  //TANK MOVES AT CONSTANT SPEED
  if (k == LEFT && !inProgress) {  //MOVES LEFT WHEN LEFTKEY IS PRESSED
    xTank -= TANK_SPEED;
  } 
  else if (k == RIGHT && !inProgress) {  //MOVES RIGHT WHEN RIGHTKEY IS PRESSED
    xTank += TANK_SPEED;
  }

  //CHECK EDGES OF TANK
  if (xTank > wallLeft - TANK_SIZE - BRICK_WIDTH/2) {  //TANK DOES NOT MOVE PASSED THE WALL
    xTank = wallLeft - TANK_SIZE - BRICK_WIDTH/2;
  }
  if (xTank < 0) {  //TANK DOES NOT MOVE OFF THE LEFT OF CANVAS 
    xTank = 0;
  }

  //MOVE BARREL
  float BARREL_SPEED = 0.02;  //BARREL MOVES AT CONSTANT SPEED
  if (k == UP && !inProgress) {  //MOVES COUNTERCLOCKWISE WHEN UPKEY IS PRESSED
    angle += BARREL_SPEED;
  } 
  else if (k == DOWN && !inProgress) {  //MOVES CLOCKWISE WHEN DOWNKEY IS PRESSED
    angle -= BARREL_SPEED;
  }
  if (angle < 0) {  //BARREL CANNOT POINT TOWARDS THE GROUND
    angle = 0;
  }
  if (angle > PI/2) {  //BARREL CANNOT POINT LEFT OF CENTER
    angle = PI/2;
  }
  if (k == ENTER && !inProgress ) {  //PROJECTILE SHOOTS WHEN ENTER IS PRESSED
    inProgress = true;
    shots++;
  }
}


float calcTimeSinceFired(float time) {  
//FUNCTION CALCULATES TIME SINCE CANNON WAS FIRED
  time += TIME_STEP;
  flightTime = time - timeFired;
  return flightTime;  
}


float calcBallX(float flightTime, float initX, float initV, float angle) {  
//CALCULATES X COORDINATE OF PROJECTILE
  return initX + cos(angle) * flightTime * initV;
}


float calcBallY(float flightTime, float initY, float initV, float angle) {  
//CALCULATES Y COORDINATE OF PROJECTILE
  return initY - sin(angle) * flightTime * initV - G * sq(flightTime) / 2;
}


boolean ballInObject(float objectLeft, float objectTop, float objectWidth, float objectHeight, float ballX, float ballY) {
//TRUE IF BALL HITS WALL OR TARGET
  if (objectLeft <= ballX && ballX <= objectLeft + objectWidth && objectTop <= ballY && ballY <= objectTop + objectHeight) {
    return true;
  }
  else {
    return false;
  }
}


boolean belowGround(float y) {
//TRUE IF BALL FALLS BELOW CANVAS
  if (y > height - BALL_SIZE) {
    return true;
  } 
  else {
    return false;
  }
}


void tankBall(float x, float y, float size) {  
//CODE THAT DRAWS PROJECTILE
  fill(255);  //WHITE BALL
  ellipse(x, y, size, size);
}


void shootBall(float barrelEndX, float barrelEndY, float VELO, float angle) {
//CODE THAT CALCULATES COORDINATES OF PROJECTILE
  xBall = calcBallX(calcTimeSinceFired(flightTime), barrelEndX, VELO, angle);
  yBall = calcBallY(calcTimeSinceFired(flightTime), barrelEndY, VELO, angle); 
  tankBall(xBall, yBall, BALL_SIZE);
}


void bombs() {
//CODE THAT CALCULATES COORDINATES OF FALLING BOMBS AND DRAWS THEM 
//BOMBS IN THIS GAME BEGIN FALLING IN LEVEL 2
  fill(255,0,0);  //LSTER
  for(int i = 0; i < NUM_BOMBS; i++) {
    if (yBomb[i] > height + BOMB_SIZE/2) {
      xBomb[i] = random(wallLeft);  //X COORDINATE OF BOMBS
      yBomb[i] = random(height) - height - BOMB_SIZE/2;  //Y COORDINATE OF BOMBS
    }
    yBomb[i] += levels/2;  //BOMBS FALL FASTER WHEN LEVELS INCREASE
    ellipse(xBomb[i], yBomb[i], BOMB_SIZE, BOMB_SIZE);
    if(ballInObject(xTank, height - TANK_SIZE, TANK_SIZE, TANK_SIZE, xBomb[i], yBomb[i])) {  //TRUE IF BOMB HITS TANK 
      restartGame();  //GAME RESTARTS
    }
  }
}


void resetShot() {  
//CODE THAT PLACES NEW PROJECTILE FOR FIRING
  inProgress = false;
  xBall = 0f;  //X COORDINATE OF BALL IS 0
  yBall = 0f;  //Y COORDINATE OF BALL IS 0
  flightTime = 0f;  //FLIGHT TIME IS 0
}


void gameStatus() {
//CODE THAT DETERMINES WHAT IS HAPPENING IN THE GAME
  onScreen = (xBall < width && yBall < height);
  if (!onScreen) {  //TRUE IF BALL IS NOT ON THE SCREEN
    resetShot();
  }
  if (inProgress) {  //TRUE IF GAME IS IN PROGRESS
    shootBall(barrelEndX, barrelEndY, VELO, angle);  //SHOOT BALL WITH THESE PARAMETERS
    int DISPLAY_TIME = 2;
    if (flightTime < DISPLAY_TIME) {  //MESSAGE WILL REMAIN ON SCREEN
      text("TANK FIRED", width/2, height/2);
    }
    if (belowGround(yBall)) {  //TRUE IF THE BALL DOES NOT HIT THE WALL OR THE TARGET
      text("MISS!", width/2, height/2);
      resetShot(); 
    }
  } 
}


void restartGame() {
//CODE THAT RESETS THE GAME
  resetShot();  //NEW BALL IN CANNON, PLAYER CAN NOW SHOOT AGAIN
  levels = 1;  //BACK TO LEVEL 1
  shots = 0;  //SHOT COUNTER BACK TO 0
  hits = 0;  //HIT COUNTER BACK TO 0
  setup();  //GAME REVERTS TO SETUP VALUES 
}
