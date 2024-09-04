// constant //<>//
final static float LeafGrowEnergy = 1500;
final static float makeSeedEnergy = 7000;
final static int startCellEnergy = 5500;
static int sunEnergy = 300;

static int tickPerFrame = 11;
static final int generationTick = 3000;

final int gridSize = 10;

// 35 62 49 20 45 0 38 36 27 59 30 30 20 63 34 14 62 28 7 3 27 53 29 10 5 6 14 37 4 15 61 6 18 23 22 54 20 13 3 56 20 1 34 56 52 48 34 63 60 14 18 18 46 57 6 57 3 22 61 5 46 23 1 40
//{11,20,46,52,54,54,39,44,45,61,47,26,27,30,20,52,31,30,6,49,1,51,39,9,13,49,1,10,7,5,3,57,38,43,39,45,37,58,30,63,23,50,2,47,44,45,52,14,0,9,22,4,40,49,62,24,12,4,39,30,55,10,28,26}
// счетчик поколений

int globalIndex = 0;
Cell[][] array = null;

//ArrayList<Cell> cells = new ArrayList();

class Genome {
  static final int genomeSize = 64;

  byte[] genes = new byte[genomeSize];
  //byte[] genes ={48, 6, 28, 53, 54, 25, 29, 54, 31, 19, 50, 17, 41, 38, 50, 44, 23, 50, 57, 59, 4, 59, 11, 51, 44, 38, 41, 29, 61, 58, 23, 29, 20, 44, 25, 59, 0, 41, 62, 45, 9, 1, 60, 41, 22, 26, 55, 19, 50, 63, 57, 30, 55, 27, 56, 59, 7, 5, 58, 50, 61, 10, 41, 20};
  Genome() {
    for (int i = 0; i < genes.length; ++i) {
      genes[i] = (byte)random(genomeSize);
    }
  }

  Genome(Genome other) {
    for (int i = 0; i < genes.length; ++i) {
      genes[i] = other.genes[i];
    }
  }

  void mutate() {
    genes[(byte)random(genomeSize)] = (byte)random(genomeSize);
  }

  boolean isSame(Genome other) {
    for (int i = 0; i < genomeSize; i++) {
      if (genes[i] != other.genes[i]) return false;
    }
    return true;
  }

  //
  int code() {
    return crc(genes);
  }
}



class Cell {

  // genes - commnad

  final static byte makeSeed = 5;
  final static byte growLeaf = 10;
  final static byte isThereSun = 15;
  final static byte bifurcate = 20;
  final static byte checkIamSeed = 25;
  final static byte photosynthesis = 30;
  final static byte timeMoreThanHalf = 35;

  Genome genome = new Genome();
  byte pc = 0;
  float energy;
  boolean isSeed = true;
  boolean head = true;
  boolean oldSeed = false;
  int id = 0;

  Cell(int energy) {
    this.energy = energy;
    this.id = (int)random(65000);
  }

  Cell (Cell other) {
    this.genome = new Genome(other.genome);
    this.energy = other.energy*96/100;
    this.isSeed = false;
    other.energy = 0;
    this.id = other.id;
  }

  ArrayList<PVector> getEmptyDirections(int x, int y) {
    ArrayList<PVector> dirs = new ArrayList();
    for (int i = 0; i < 5; ++i) {
      PVector d = newDir(x, y, i);

      if (d != null && (array[(int)d.x][(int)d.y] == null)) {
        dirs.add(d);
      }
    }
    return dirs;
  }

  PVector getDirection(int x, int y) {
    ArrayList<PVector> dirs = getEmptyDirections(x, y);
    int size = dirs.size();
    if (size == 0) return null;
    if (size == 1) return dirs.get(0);
    return dirs.get((int)random(size));
  }

  PVector newDir(int x, int y, int direction) {

    switch(direction) {
    case 0:
      if (x == width/gridSize - 1) return new PVector(0, y);

      return new PVector(x + 1, y);

    case 1:
      if (y == 0) return null;
      if (x == width/gridSize - 1) return new PVector(0, y-1);
      return new PVector(x+1, y-1);

    case 2:
      if (y == 0) return null;
      return new PVector(x, y-1);

    case 3:
      if (y == 0) return null;
      if (x == 0) return new PVector(width/gridSize - 1, y-1);

      return new PVector(x-1, y-1);

    case 4:
      if (x == 0) return new PVector(width/gridSize - 1, y);
      return new PVector(x-1, y);
    }
    return null;
  }

  boolean dirIsEmpty(PVector v) {
    if (v != null && array[(int)v.x][(int)v.y] == null) return true;
    return false;
  }

  int recursivness = 0;

  void tick(int x, int y, int recurs) {
    if (recurs > 16) {
      return;
    }

    if (y != height/gridSize - 1 && isSeed) return;

    if (isSeed) {
      oldSeed = true;
    }

    byte cmd = genome.genes[((pc & 0xff) % Genome.genomeSize)];

    switch(cmd) {
    case makeSeed:
      {
        if (this.isSeed  || this.head == false) break;
        PVector v = getDirection(x, y);
        if (v != null && energy > makeSeedEnergy) {
          Cell c = new Cell(this);
          array[(int)v.x][(int)v.y] = c;
          c.isSeed = true;
          if ((int)random(5) == 3) {
            c.genome.mutate();
            c.id = (int)random(65000);
          }

          pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
        } else {
          pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
        }
      }
      break;

    case photosynthesis:
      {
        if (isSeed) break;
        float sunAmount = sunEnergy/2;
        int cellCnt = 0;
        for (int yy = 0; yy < height/gridSize; ++yy) {
          Cell c = array[x][yy];
          if (c != null && !c.isSeed) {
            if (c == this) break;
            if (cellCnt++ > 3) {
              sunAmount= 0;
              break;
            }
            sunAmount /=1.5;
          }
        }
        this.energy += sunAmount;
        if (sunAmount > 0) {
          pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
        } else {
          pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
        }
      }
      break;


    case growLeaf:
      {
        if (energy > LeafGrowEnergy && head) {
          PVector v = getDirection(x, y);
          head = false;
          if (v != null) {
            array[(int)v.x][(int)v.y] = new Cell(this);
            pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
          } else {
            pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
          }
        }
      }
      break;

    case bifurcate:
      if (head) {
        head = false;
        ArrayList<PVector> dirs = getEmptyDirections(x, y);
        if (dirs.size() > 1) {
          if (energy > 2*LeafGrowEnergy && head) {
            Cell c0 = new Cell(this);
            Cell c1 = new Cell(this);

            PVector v = dirs.get(0);
            array[(int)v.x][(int)v.y] = c0;

            v = dirs.get(1);
            array[(int)v.x][(int)v.y] = c1;
            // fix distributed energy
            c1.energy = c0.energy/2;
            c0.energy = c1.energy;
          }
          pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
        } else {
          pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
        }
      }
      break;

    case checkIamSeed:
      if (isSeed) {
        pc = genome.genes[(((pc+1) & 0xff) % Genome.genomeSize)];
      } else {
        pc = genome.genes[(((pc+2) & 0xff) % Genome.genomeSize)];
      }
      break;

    case isThereSun:
      {
        float sunAmount = sunEnergy/2;
        int cellCnt = 0;
        for (int yy = 0; yy < height/gridSize; ++yy) {
          Cell c = array[x][yy];
          if (c != null && !c.isSeed) {
            if (c == this) break;
            if (cellCnt++ > 3) {
              sunAmount= 0;
              break;
            }
            sunAmount /=1.5;
          }
        }
        if (sunAmount > 0) {
          pc = genome.genes[(((pc+1) & 0xff) % Genome.genomeSize)];
        } else {
          pc = genome.genes[(((pc+2) & 0xff) % Genome.genomeSize)];
        }
      }
      break;
    case timeMoreThanHalf:
      if (ticks > generationTick*2/3) {
        pc = genome.genes[(((pc+1) & 0xff) % Genome.genomeSize)];
      } else {
        pc = genome.genes[(((pc+2) & 0xff) % Genome.genomeSize)];
      }
      break;
    default:
      pc++;
      //pc = genome.genes[(((pc) & 0xff) % Genome.genomeSize)];
      break;
    }
  }
}

public void lifeTick() {
  for (int y = 0; y < height/gridSize; ++y) {
    for (int x = 0; x < width/gridSize; ++x) {
      Cell c = array[x][y];
      if (c != null) {
        c.tick(x, y, 0);
      }
    }
  }
}

boolean moveSeeds() {
  boolean moved = false;
  for (int y = height/gridSize - 2; y >= 0; --y) {
    for (int x = width/gridSize - 1; x >= 0; --x) {
      if (array[x][y] != null && array[x][y].isSeed) {
        if (array[x][y+1] == null) {
          array[x][y+1] = array[x][y];
          array[x][y] = null;
          moved = true;
        } else {
          //int x, y;
          boolean direction = ((int)random(100)) % 2 == 0;
          if (direction) {
            if (x < width/gridSize - 1 && array[x+1][y+1] == null) {
              array[x+1][y+1] = array[x][y];
              array[x][y] = null;
              moved = true;
            }
          } else {
            if (x > 0 && array[x-1][y+1] == null) {
              array[x-1][y+1] = array[x][y];
              array[x][y] = null;
              moved = true;
            }
          }
        }
      }
    }
  }
  return moved;
}


void killOldSeeds() {

  for (int x = 0; x < width/gridSize; x++) {

    int number = 0;

    //for (int y = height/gridSize - 2; y >= 0; --y) {
    //  array[x][y] = null;
    //}


    while (array[x][height/gridSize - 1 - number] != null) {
      number++;
    }

    if (number > 1) {
      // pick lucky
      //int remained = number;
      for (int i = 0; i < number-1; ++i) {
        //if (i != remained) {
        array[x][height/gridSize - i - 1] = null;
        //}
      }
    }
  }
}

void killAllTrees() {
  for (int y = 0; y < height/gridSize; ++y) {
    for (int x = 0; x < width/gridSize; ++x) {
      Cell c = array[x][y];
      if (c != null && !c.isSeed) {
        array[x][y] = null;
      }
      // kill old seeds
      Cell s = array[x][height/gridSize - 1];
      if (s != null && s.oldSeed) {
        array[x][height/gridSize - 1] = null;
      }
    }
  }
}

void setup() {
  size(3000, 2000);
  array = new Cell[width/gridSize][height/gridSize];
  background(0);
  colorMode(HSB, 65535, 100, 100);
  for (int i = 0; i < width/gridSize; ++i) {
    array[i][height/(gridSize)-1] = new Cell(startCellEnergy);
  }
  frameRate(200);
}

boolean mode = true;

void mouseClicked() {
  int x = mouseX/gridSize;
  int y = mouseY/gridSize;
  Cell c = array[x][y];
  if (c != null) {
    print("{");
    for (int i = 0; i < Genome.genomeSize; ++i) {
      print(c.genome.genes[i] + ",");
    }
    println("}");
    println("[" + (c.pc & 0xff) + "]");
    println("energy: " + c.energy);
  } else {
    println("cell misclick - change mode");
    mode = !mode;
  }
}

void keyPressed() {

  if (keyCode == UP) {
    sunEnergy += 10;
  } else if (keyCode == DOWN) {
    sunEnergy -= 10;
  } else if (keyCode == LEFT) {
    tickPerFrame -= 10;
  } else if (keyCode == RIGHT) {
    tickPerFrame += 10;
  }
  if (keyPressed) {
    if (key == 'n') {
      for (int i = 0; i < width/gridSize; ++i) {
        if (array[i][(height/gridSize)-1] == null) {
          array[i][height/(2*gridSize)] = new Cell(startCellEnergy);
        }
      }
    }
  }
  if (keyPressed) {
    if (key == 'r') {
      killAllTrees();
      for (int i = 0; i < width/gridSize; ++i) {
        array[i][height/(gridSize)-1] = new Cell(startCellEnergy);
        state = WorldState.Grow;
      }
    }
  }
}

int killDelay = 0;
int maxEnergy = 0;
int milis = millis();
int ticks = 0;
boolean grow = true;

enum WorldState {
  Grow,
    DropSeeds,
    KillTrees,
    KillExtraSeeds
}

WorldState state = WorldState.Grow;

int frmCount = 0;
int frameInterval = millis();
int fps;
int generationCounter = 1;
void draw() {

  background(0);
  stroke(255);
  textSize(48);
  //println("start " + millis());
  frmCount++;
  if (millis() - frameInterval > 1000) {
    //println(frmCount);
    frameInterval = millis();
    fps = frmCount;
    frmCount = 0;
  }
  text("gen: " + generationCounter + "(" + 100 * ticks / generationTick + "%)", 180, 80);
  text("fps: " + fps, 10, 80);
  text("sun: " + sunEnergy, width-200, 80);
  text("ticks: " + tickPerFrame, width-400, 80);
  switch(state) {

  case Grow:
    for (int i = 0; i < tickPerFrame; i++) {
      lifeTick();
      ticks++;
      if (ticks > generationTick) {
        ticks = 0;
        state = WorldState.KillTrees;
        break;
      }
    }

    break;

  case KillTrees:
    killAllTrees();
    state = WorldState.DropSeeds;
    generationCounter++;
    break;

  case DropSeeds:
    if (!moveSeeds()) {
      state = WorldState.KillExtraSeeds;
    }
    break;

  case KillExtraSeeds:
    killOldSeeds();
    if (!moveSeeds()) {
      //// kill some other
      //for (int i = 0; i < width/gridSize; ++i) {
      //  if (i % 5 != 0) {
      //    array[i][height/gridSize-1] = null;
      //  }
      //}
      boolean hasSeed = false;
      for (int x = 0; x < width/gridSize-1; ++x) {
        hasSeed |= array[x][height/gridSize-1] != null;
      }
      if (!hasSeed) {
        for (int i = 0; i < width/gridSize; ++i) {
          if (array[i][(height/gridSize)-1] == null) {
            array[i][height/(2*gridSize)] = new Cell(startCellEnergy);
          }
        }
      }
      state = WorldState.Grow;
    }

    break;
  }
  //println("will draw " + millis());
  int maxEnergyLocal = 0;
  // draw cells
  for (int y = 0; y < height/gridSize; y++) {
    for (int x = 0; x < width/gridSize; x++) {
      Cell c = array[x][y];
      if (c != null) {
        int clr;
        if (mode) {
          //clr = c.genome.code();
          clr = c.id;
        } else {
          clr = (int)map(c.energy, 0, maxEnergy, 0, 30000);
        }
        if (c.isSeed) {
          stroke(color(20, 100, 100));
          strokeWeight(2);
          fill(color(20, 100, 100));
          strokeWeight(1);
          stroke(0);
        } else {
          fill(color(clr, 100, 100));
        }
        rect(x * gridSize, y * gridSize, gridSize, gridSize);
        if (c.energy > maxEnergyLocal) {
          maxEnergyLocal = (int)c.energy;
        }
      }
    }
  }
  maxEnergy = maxEnergyLocal;

  if (!mode) {
    // draw energy range
    for (int i = 0; i < height/gridSize; ++i) {
      fill(color(map(i, height/gridSize, 0, 0, 30000), 100, 100));
      //fill(color(20, 100, 100));
      rect(0, i * gridSize, gridSize, gridSize);
    }
  }
  //println("end " + millis());
}
