import ddf.minim.*;

AudioPlayer w;
AudioPlayer b;
Minim minim;//audio context
PFont mono;
final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;


//declare global variables
Player player;
PImage snow, crate, red_brick, brown_brick, gold, spider, p, flag;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
boolean isGameOver;
int totalCoins;
int numCoins;
float view_x;
float view_y;
Enemy enemy;
PImage bg;
int totalTime;
int currentTime = 500;
int gameTime;
String ms;

//initialize them in setup().
void setup(){
  minim = new Minim(this);
  w = minim.loadFile("music.mp3", 2048);
  w.play();
  size(800, 600);
  imageMode(CENTER);
  p = loadImage("player.png");
  player = new Player(p, 0.8);
  player.setBottom(GROUND_LEVEL);
  player.center_x = 150;
  platforms = new ArrayList<Sprite>();
  view_x = 0;
  view_y = 0;
  coins = new ArrayList<Sprite>();
  totalCoins = 6;
  totalTime = 0;
  numCoins = 0;
  isGameOver = false;
  gameTime = 0;
  bg = loadImage("background.png");
  flag = loadImage("flag.png");
  gold = loadImage("gold1.png");
  spider = loadImage("enemy_walk_right1.png");
  red_brick = loadImage("red_brick.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
  createPlatforms("map.csv");
}

// modify and update them in draw().
void draw(){
  //background(0,0,0);
  background(bg);
  scroll();
  displayAll();
  if (!isGameOver){
    updateAll();
    collectCoins();
    checkDeath();
  }
} 
void displayAll(){
  for(Sprite s: platforms){
    s.display();
  }
  for (Sprite c: coins){
    c.display();
  }
  image(flag, 2200, 460, 150, 200); 
  player.display();
  enemy.display();
  fill(255);
  mono = createFont("game.ttf", 32);
  textFont(mono);
  float x_val = view_x + 400;
  timer(x_val);
  textAlign(CENTER);
  text(player.lives + "  of  " + 3 + "  Lives", x_val, view_y + 50);
  text(numCoins + "  of  " + totalCoins + "  Coins", x_val, view_y + 100);  
 }
 
 void timer(float x_val){
  totalTime = millis();
  gameTime = totalTime - currentTime;
  textAlign(LEFT);
  int minutes = (gameTime / 1000) / 60;;
  int seconds = (gameTime / 1000) % 60;
  int milliseconds = gameTime - (minutes*60000 + seconds*1000);
  milliseconds /= 10;
  if (milliseconds%10 == 0) ms = milliseconds + "0";
  else ms = milliseconds + "";
  float x = x_val - 325;
  float y = view_y + 75;
  if (seconds < 10 && minutes < 10) text("0" + minutes + ":0" + seconds + ":" + ms, x, y);
  else if (seconds < 10) text(minutes + ":0" + seconds + ":" + ms, x, y);
  else if (minutes < 10) text("0" + minutes + ":" + seconds + ":" + ms, x, y);
  else text(minutes + ":" + seconds + ":" + ms, x, y);
 }
 
 void updateAll(){
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  enemy.update();
  enemy.updateAnimation();
  for (Sprite c: coins){
    ((AnimatedSprite)c).updateAnimation();
  }
 }
 
 void checkDeath(){
   boolean collideEnemy = checkCollision(player, enemy);
   boolean fallOffCliff = player.getBottom() > GROUND_LEVEL;
   if (collideEnemy || fallOffCliff){
     player.lives --;
     w.rewind();
     if(player.lives == 0){
        isGameOver = true;
          if (isGameOver){
            float x_val = view_x + 400;
            fill(0,0,255);
            text("GAME OVER!", x_val, view_y + height/2 - 50);
            if (player.lives == 0){
              text("You lose", x_val, view_y + height/2);
            }
            else {
              text("You win", x_val, view_y + height/2);
            }
            text("Press SPACE to restart", x_val, view_y + height/2 + 50);
          }
        w.pause();
        
        minim = new Minim(this);
        w = minim.loadFile("end.mp3", 2048);
        w.play();
        int x = 0;
        noLoop();
     }
     else{
       player.center_x = 100;
       player.setBottom(GROUND_LEVEL);
     }
   }
 }
 
 void collectCoins(){
   ArrayList<Sprite> coin_list = checkCollisionList(player, coins);
   if (coin_list.size() > 0){
     for (Sprite coin: coin_list){
       numCoins++;
       coins.remove(coin);
         b = minim.loadFile("coin.mp3", 2048);
         b.play();
     }
   }
   if(player.getRight() >= 2175){
      isGameOver = true;
      w.pause();
      minim = new Minim(this);
      w = minim.loadFile("win.mp3", 2048);
      w.play();
   }
 }


void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if (player.getRight() > right_boundary){
    view_x += player.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if (player.getLeft() < left_boundary){
    view_x -= left_boundary - player.getLeft();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if (player.getBottom() > bottom_boundary){
    view_y += player.getBottom() - bottom_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if (player.getTop() < top_boundary){
    view_y -= top_boundary - player.getTop();
  }
  translate(-view_x, -view_y);
}


// returns true if sprite is one a platform.
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  // move down say 5 pixels
  s.center_y += 5;

  // check to see if sprite collide with any walls by calling checkCollisionList
  ArrayList<Sprite> collision_list = checkCollisionList(s, walls);
  
  // move back up 5 pixels to restore sprite to original position.
  s.center_y -= 5;
  
  // if sprite did collide with walls, it must have been on a platform: return true
  // otherwise return false.
  return collision_list.size() > 0; 
}


// Use your previous solutions from the previous lab.

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  // add gravity to change_y of sprite
  s.change_y += GRAVITY;
  
  // move in y-direction by adding change_y to center_y to update y position.
  s.center_y += s.change_y;
  
  // Now resolve any collision in the y-direction:
  // compute collision_list between sprite and walls(platforms).
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  
  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving down(change_y > 0)
         set bottom of sprite to equal top of platform
       else if sprite is moving up
         set top of sprite to equal bottom of platform
       set sprite's change_y to 0
  */
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  // move in x-direction by adding change_x to center_x to update x position.
  s.center_x += s.change_x;
  
  // Now resolve any collision in the x-direction:
  // compute collision_list between sprite and walls(platforms).   
  col_list = checkCollisionList(s, walls);

  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving right
         set right side of sprite to equal left side of platform
       else if sprite is moving left
         set left side of sprite to equal right side of platform
  */

  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_x > 0){
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0){
        s.setLeft(collided.getRight());
    }
  }}

boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight()<= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}


void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("2")){
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("3")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("4")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("5")){
        Coin c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(c);
      }
      else if(values[col].equals("6")){
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 5 * SPRITE_SIZE;
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
      }
    }
  }
}
 

// called whenever a key is pressed.
void keyPressed(){
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
  }
  // add an else if and check if key pressed is 'a' and if sprite is on platforms
  // if true then give the sprite a negative change_y speed(use JUMP_SPEED)
  // defined above
  else if(keyCode == UP && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
  }
  else if (isGameOver && key == ' '){
    w.pause();
    currentTime = totalTime + 500;
    loop();
    setup();
  }
}

// called whenever a key is released.
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x = 0;
  }
  else if(keyCode == LEFT){
    player.change_x = 0;
  }
}
