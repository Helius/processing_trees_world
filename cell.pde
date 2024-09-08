class Cell {

  // genes - commnad

  final static byte makeSeed = 0;
  final static byte growLeaf = 10;
  //final static byte isThereSun = 15;
  final static byte bifurcate = 20;
  final static byte checkIamSeed = 30;
  final static byte photosynthesis = 40;
  final static byte timeMoreThan = 50;

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
    this.energy = other.energy;
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

  PVector getRandomEmptyDirection(int x, int y) {
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

  void tick(int x, int y) {

    if (!head) {
      return;
    }

    if (y != height/gridSize - 1 && isSeed) {
      return;
    }

    if (isSeed) {
      oldSeed = true;
    }

    byte cmd = genome.genes[((pc & 0xff) % Genome.genomeSize)];

    switch(cmd) {
    case makeSeed:
      {

        PVector v = getRandomEmptyDirection(x, y);
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
        if (energy > LeafGrowEnergy) {
          energy -= LeafGrowEnergy;
          //PVector v = getDirection(x, y);
          ++pc; // next is direction to grow
          int direction = genome.genes[((pc & 0xff) % Genome.genomeSize)] % 5;
          PVector v = newDir(x, y, direction);
          Cell c = null;

          if (v != null) {
            c = array[(int)v.x][(int)v.y];
          }

          if (v!= null && (c == null || !c.head || !c.isSeed)) {
            head = false;
            array[(int)v.x][(int)v.y] = new Cell(this);
            pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
          } else {
            pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
          }
        }
      }
      break;

    case bifurcate:
      ArrayList<PVector> dirs = getEmptyDirections(x, y);
      if (dirs.size() > 1) {
        if (energy > 2*LeafGrowEnergy) {
          energy -= 2*LeafGrowEnergy;
          //println("bifurkate!!!!!!!!!");
          Cell c0 = new Cell(this);
          Cell c1 = new Cell(this);

          PVector v = dirs.get(0);
          array[(int)v.x][(int)v.y] = c0;

          v = dirs.get(1);
          array[(int)v.x][(int)v.y] = c1;
          // fix distributed energy
          c1.energy = c0.energy/2;
          c0.energy = c1.energy;
          head = false;
        } else {
          //println("no energy:" + energy + " of " + (2*LeafGrowEnergy) + ", its:" + (energy > 2*LeafGrowEnergy) );
        }
        pc = genome.genes[((pc+1 & 0xff) % Genome.genomeSize)];
      } else {
        //println("no luck");
        pc = genome.genes[((pc+2 & 0xff) % Genome.genomeSize)];
      }

      break;

    case checkIamSeed:
      if (isSeed) {
        pc = genome.genes[(((pc+1) & 0xff) % Genome.genomeSize)];
      } else {
        pc = genome.genes[(((pc+2) & 0xff) % Genome.genomeSize)];
      }
      break;

      //case isThereSun:
      //  {
      //    float sunAmount = sunEnergy/2;
      //    int cellCnt = 0;
      //    for (int yy = 0; yy < height/gridSize; ++yy) {
      //      Cell c = array[x][yy];
      //      if (c != null && !c.isSeed) {
      //        if (c == this) break;
      //        if (cellCnt++ > 3) {
      //          sunAmount= 0;
      //          break;
      //        }
      //        sunAmount /=1.5;
      //      }
      //    }
      //    if (sunAmount > 0) {
      //      pc = genome.genes[(((pc+1) & 0xff) % Genome.genomeSize)];
      //    } else {
      //      pc = genome.genes[(((pc+2) & 0xff) % Genome.genomeSize)];
      //    }
      //  }
      //  break;
    case timeMoreThan:
      pc++;
      int value = genome.genes[(pc & 0xff) % Genome.genomeSize] & 0xff;
      if (value > map(ticks, 0, generationTick, 0, Genome.genomeSize-1)) {
        pc = genome.genes[((pc+1) & 0xff) % Genome.genomeSize];
      } else {
        pc = genome.genes[((pc+2) & 0xff) % Genome.genomeSize];
      }
      break;
    default:
      pc++;
      //pc = genome.genes[(((pc) & 0xff) % Genome.genomeSize)];
      break;
    }
  }
}
