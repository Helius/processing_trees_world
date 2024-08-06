// constant
final static float LeafGrowEnergy = 30;
final static float makeSeedEnergy = 70;
final static float sunEnergy = 4;
final static int startCellEnergy = 300;

final int gridSize = 10;

Cell[][] array = null;

ArrayList<Cell> cells = new ArrayList();


public static int crc(byte[] genes) {

  int[] table = {
    0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
    0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
    0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
    0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
    0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
    0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
    0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
    0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
    0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
    0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
    0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
    0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
    0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
    0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
    0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
    0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
    0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
    0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
    0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
    0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
    0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
    0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
    0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
    0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
    0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
    0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
    0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
    0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
    0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
    0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
    0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
    0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040,
  };



  int crc = 0x0000;
  for (byte b : genes) {
    crc = (crc >>> 8) ^ table[(crc ^ b) & 0xff];
  }

  return crc;
}



class Genome {
  static final int genomeSize = 64;

  byte[] genes = new byte[genomeSize];

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

    byte cmd = genome.genes[((pc & 0xff) % Genome.genomeSize)];


    if (cmd >= checkDirEmpty && cmd < checkDirEmpty + 5) {
    }

    switch(pc) {
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
          pc++; // False
        }
        tick(x, y);
      }
      break;

    case growLeaf:
      {
        if (energy > 2*LeafGrowEnergy) {
          energy -= LeafGrowEnergy;
          // 1. get new direction from next genes
          int direction = genome.genes[((pc++ & 0xff) % Genome.genomeSize)];
          // 2. check dir is empty, then grow leaf
          PVector v = newDir(x, y, direction);
          if (dirIsEmpty(v)) {
            array[(int)v.x][(int)v.y] = new Cell(this);
          }
        }
      }
      break;

    case checkIamSeed:
      pc++;
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

    pc++;
  }
}



public void lifeTick() {
  for (int y = 0; y < height/gridSize; y++) {
    for (int x = 0; x < width/gridSize; x++) {
      Cell c = array[x][y];
      if (c != null) {
        c.tick(x, y);
      }
    }
  }
}

void moveSeeds() {

  for (int y = height/gridSize - 2; y >= 0; --y) {
    for (int x = width/gridSize - 1; x >= 0; --x) {
      if (array[x][y] != null && array[x][y].isSeed) {
        if (array[x][y+1] == null) {
          array[x][y+1] = array[x][y];
          array[x][y] = null;
        } else {
          //int x, y;
          boolean direction = ((int)random(100)) % 2 == 0;
          if (direction) {
            if (x < width/gridSize - 1 && array[x+1][y+1] == null) {
              array[x+1][y+1] = array[x][y];
              array[x][y] = null;
            }
          } else {
            if (x > 0 && array[x-1][y+1] == null) {
              array[x-1][y+1] = array[x][y];
              array[x][y] = null;
            }
          }
        }
      }
    }
  }
}

void setup() {
  size(3000, 2000);
  array = new Cell[width/gridSize][height/gridSize];
  background(0);
  colorMode(HSB, 65535, 100, 100);
}


void mouseClicked() {
  int x = mouseX/gridSize;
  int y = mouseY/gridSize;

  if (x >= 0 && x < width/gridSize && y >= 0 && y < height/gridSize) {
    array[x][y] = new Cell(startCellEnergy);
  }
}

void killOldSeeds() {
  for (int x = 0; x < width/gridSize; x++) {
    Cell cb = array[x][height/gridSize - 1];
    Cell ca = array[x][height/gridSize - 2];
    if (cb != null && ca != null && ca.isSeed) {
      array[x][height/gridSize - 1] = null;
    }
  }
}

int killDelay = 0;

void draw() {
  background(0);
  stroke(255);

  // move seeds
  moveSeeds();

  if (killDelay++ > 60) {
    // kill old seeds
    killOldSeeds();
    killDelay = 0;
  }

  // process comands
  lifeTick();

  // draw cells
  for (int y = 0; y < height/gridSize; y++) {
    for (int x = 0; x < width/gridSize; x++) {
      Cell c = array[x][y];
      if (c != null) {
        if (c.isSeed) {
          fill(color(20, 100, 100));
        } else {
          println(c.genome.code());
          fill(color(c.genome.code(), 100, 100));
        }
        rect(x * gridSize, y * gridSize, gridSize, gridSize);
      }
    }
  }
}
