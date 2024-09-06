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
