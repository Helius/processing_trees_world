// constant //<>//
final static float LeafGrowEnergy = 10;
final static float makeSeedEnergy = 150;
final static float sunEnergy = 3;
final static int startCellEnergy = 50;

final int gridSize = 10;

// 35 62 49 20 45 0 38 36 27 59 30 30 20 63 34 14 62 28 7 3 27 53 29 10 5 6 14 37 4 15 61 6 18 23 22 54 20 13 3 56 20 1 34 56 52 48 34 63 60 14 18 18 46 57 6 57 3 22 61 5 46 23 1 40

// счетчик поколений
// uuid для семечек
// удалять семечки рандомно а не нижние
// уменьшалку энергии солнца

Cell[][] array = null;

ArrayList<Cell> cells = new ArrayList();

class Genome {
  static final int genomeSize = 64;

  byte[] genes = {35, 62, 49, 20, 45, 0, 38, 36, 27, 59, 30, 30, 20, 63, 34, 14, 62, 28, 7, 3, 27, 53, 29, 10, 5, 6, 14, 37, 4, 15, 61, 6, 18, 23, 22, 54, 20, 13, 3, 56, 20, 1, 34, 56, 52, 48, 34, 63, 60, 14, 18, 18, 46, 57, 6, 57, 3, 22, 61, 5, 46, 23, 1, 40}; //new byte[genomeSize];

  Genome() {
    //for (int i = 0; i < genes.length; ++i) {
    //genes[i] = (byte)random(genomeSize);
    //}
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
  final static byte makeSeed = 1;

  final static byte checkIamSeed = 7;
  final static byte checkIamOnTop = 8;
  final static byte checkIamCoverdByOther = 9;

  final static byte checkDirEmpty = 10; // next is direction
  final static byte growLeaf = 20; // next is direction
  final static byte photosynthesis = 30;

  Genome genome = new Genome();
  byte pc = 0;
  float energy;
  boolean isSeed = true;
  boolean head = true;
  boolean oldSeed = false;

  Cell(int energy) {
    this.energy = energy;
  }

  Cell (Cell other) {
    this.genome = new Genome(other.genome);
    this.energy = other.energy/2;
    this.isSeed = false;
    other.energy = this.energy;
  }

  PVector newDir(int x, int y, int direction) {
    //println("direction: " + direction + ", " + direction % 5);
    switch(direction % 5) {
    case 0:
      if (x == width/gridSize - 1) return null;
      return new PVector(x + 1, y);

    case 1:
      if (x == width/gridSize - 1) return null;
      if (y == 0) return null;
      return new PVector(x+1, y-1);

    case 2:
      if (y == 0) return null;
      return new PVector(x, y-1);

    case 3:
      if (x == 0) return null;
      if (y == 0) return null;
      return new PVector(x-1, y-1);

    case 4:
      if (x == 0) return null;
      return new PVector(x-1, y);
    }
    return null;
  }

  boolean dirIsEmpty(PVector v) {
    if (v != null && array[(int)v.x][(int)v.y] == null) return true;
    return false;
  }

  void tick(int x, int y) {

    if (y != height/gridSize - 1 && isSeed) return;

    byte cmd = genome.genes[((pc++ & 0xff) % Genome.genomeSize)];

    switch(cmd) {
    case makeSeed:
      {
        if (this.isSeed) break;
        PVector v = newDir(x, y, (int)random(5));
        if (dirIsEmpty(v) && energy > makeSeedEnergy) {
          Cell c = new Cell(this);
          array[(int)v.x][(int)v.y] = c;
          c.isSeed = true;
          if ((int)random(5) == 3) {
            c.genome.mutate();
          }
        }
      }
      break;

    case photosynthesis:
      {
        float sunAmount = sunEnergy/2;
        for (int yy = 0; yy < height/gridSize; ++yy) {
          Cell c = array[x][yy];
          if (c != null && !c.isSeed) {
            if (c == this) break;
            c.energy += sunAmount;
            sunAmount /=1.5;
          }
        }
        this.energy += sunAmount;
      }
      break;

    case checkDirEmpty:
      {
        int direction = genome.genes[((pc++ & 0xff) % Genome.genomeSize)];
        if (dirIsEmpty(newDir(x, y, direction))) {
          // True, pc already incremented
        } else {
          ++pc; // False
        }
        tick(x, y);
      }
      break;

    case growLeaf:
      {
        if (energy > 2*LeafGrowEnergy && head) {
          energy -= LeafGrowEnergy;
          // 1. get new direction from next genes
          int direction = genome.genes[((pc++ & 0xff) % Genome.genomeSize)];
          // 2. check dir is empty, then grow leaf

          for (int i = 0; i < direction*3/Genome.genomeSize; i++) {
            PVector v = newDir(x, y, direction + i);
            if (dirIsEmpty(v)) {
              array[(int)v.x][(int)v.y] = new Cell(this);
            }
            head = false;
          }
        }
      }
      break;

    case checkIamSeed:
      if (!isSeed) pc++;
      tick(x, y);
      break;

    case checkIamOnTop:
      break;
    case checkIamCoverdByOther:
      break;
    default:
      break;
    }
  }
}

public void lifeTick() {
  for (int y = 0; y < height/gridSize; ++y) {
    for (int x = 0; x < width/gridSize; ++x) {
      Cell c = array[x][y];
      if (c != null) {
        c.tick(x, y);
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

void setup() {
  size(3000, 2000);
  array = new Cell[width/gridSize][height/gridSize];
  background(0);
  colorMode(HSB, 65535, 100, 100);
  for (int i = 0; i < 40; ++i) {
    array[(int)random(width/gridSize)][height/(gridSize)-1] = new Cell(startCellEnergy);
  }
}

boolean mode = true;

void mouseClicked() {
  int x = mouseX/gridSize;
  int y = mouseY/gridSize;
  Cell c = array[x][y];
  if (c != null) {
    for (int i = 0; i < Genome.genomeSize; ++i) {
      print(c.genome.genes[i] + " ");
    }
    println("[" + (c.pc & 0xff) + "]");
    println("energy: " + c.energy);
  } else {
    println("cell misclick - change mode");
    mode = !mode;
  }
}

void killOldSeeds() {
  for (int x = 0; x < width/gridSize; x++) {

    int number = 0;
    while (array[x][height/gridSize - 1 - number] != null) {
      number++;
    }
    
    if (number > 1) {
      // pick lucky
      int remained = (int)random(number);
      for (int i = 0; i < number; ++i) {
        if (i != remained) {
          array[x][height/gridSize - i - 1] = null;
        }
      }
    }
  }
}

void killAllTrees() {
  for (int y = 0; y < height/gridSize; y++) {
    for (int x = 0; x < width/gridSize; x++) {
      Cell c = array[x][y];
      if (c != null && !c.isSeed) {
        array[x][y] = null;
      }
    }
  }
}

int killDelay = 0;
int maxEnergy = 0;
int milis = millis();
boolean grow = true;

enum WorldState {
  Grow,
    DropSeeds,
    KillTrees,
    KillExtraSeeds
}

WorldState state = WorldState.Grow;

void draw() {
  background(0);
  stroke(255);

  switch(state) {

  case Grow:
    lifeTick();
    if (millis() - milis > 22000) {
      milis = millis();
      state = WorldState.KillTrees;
    }
    break;

  case KillTrees:
    killAllTrees();
    state = WorldState.DropSeeds;
    break;

  case DropSeeds:
    if (!moveSeeds()) {
      state = WorldState.KillExtraSeeds;
    }
    break;

  case KillExtraSeeds:
    killOldSeeds();
    if (!moveSeeds()) {
      state = WorldState.Grow;
    }
    break;
  }

  int maxEnergyLocal = 0;
  // draw cells
  for (int y = 0; y < height/gridSize; y++) {
    for (int x = 0; x < width/gridSize; x++) {
      Cell c = array[x][y];
      if (c != null) {
        int clr;
        if (mode) {
          clr = c.genome.code();
        } else {
          clr = (int)map(c.energy, 0, maxEnergy, 0, 30000);
        }
        if (c.isSeed) {
          fill(color(20, 100, 100));
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
}
