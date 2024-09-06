 //<>//

Cell[][] array = null;


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


void killOldSeeds() {

  for (int x = 0; x < width/gridSize; x++) {

    int number = 0;

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
  size(3600, 2000);
  array = new Cell[width/gridSize][height/gridSize];
  background(0);
  colorMode(HSB, 65535, 100, 100);
  for (int i = 0; i < width/gridSize; ++i) {
    array[i][height/(gridSize)-1] = new Cell(startCellEnergy);
  }
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
        generationCounter = 0;
        for (int i = 0; i < width/gridSize; ++i) {
          if (array[i][(height/gridSize)-1] == null) {
            array[i][height/gridSize-1] = new Cell(startCellEnergy);
          }
        }
        //state = WorldState.DropSeeds;
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
          float energy = c.energy;
          if (energy > makeSeedEnergy) {
            energy = makeSeedEnergy;
          }
          clr = (int)map(energy, 0, makeSeedEnergy, 0, 30000);
        }
        if (c.isSeed) {
          //stroke(color(20, 100, 100));
          //strokeWeight(2);
          fill(color(20, 100, 100));
          //strokeWeight(1);
          //stroke(0);
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
