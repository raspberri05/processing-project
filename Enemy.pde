public class Enemy extends AnimatedSprite{
  float boundaryLeft, boundaryRight;
  public Enemy(PImage img, float scale, float bLeft, float bRight){
    super(img, scale);
    moveLeft = new PImage[2];
    moveLeft[0] = loadImage("enemy_walk_left1.png");
    moveLeft[1] = loadImage("enemy_walk_left2.png");
    moveRight = new PImage[2];
    moveRight[0] = loadImage("enemy_walk_right1.png");
    moveRight[1] = loadImage("enemy_walk_right2.png");
    currentImages = moveRight;
    boundaryLeft = bLeft;
    boundaryRight = bRight;
    change_x = 2;
  }
  void update(){
    super.update();
    if(getLeft() <= boundaryLeft){
      setLeft(boundaryLeft);
      change_x *= -1;
    }
    else if (getRight() >= boundaryRight){
      setRight(boundaryRight);
      change_x *= -1;
    }
  }
}
