#ifndef CPUKDTREERANGESEARCH
#define CPUKDTREERANGESEARCH
#include "ESBTL_ProteinHandler.h"
#include "dataStructures.h"
#include "AtomNameToNumHashTable.h"
#include "SearchStructureConstruction.h"
#include <string>
#include <vector>
#include <cmath>
#include "printToFileHandler.h"


void cpuKdTreeRangeSearch(/*std::string AtomA, std::string atomB, int requiredProximity,*/rangeSearchSettings& settings, ProteinDataHandler heldProteinSets, AtomToNumHashTable atomReferenceTable);
void rangeSearchCpu(atomCoords targetAtom, int elementTwo, int maxDistance, std::vector<int> &resultsVector, short *names, int *xValueArray, int *yValueArray, int*zValueArray, int *kdArray, int kdArraySize, int TreePos, int treeLevel, int* runcount, int valueArraysStartPositionOffset, int kdTreeStartPositionOffset);

float squaredDistance3D(atomCoords targetAtom, atomCoords currentAtom);
bool viableDirection(atomCoords targetAtom, atomCoords currentAtom, atomCoords childAtom, int treeLevel, int requiredDistance);


void processSingleKdTreeRangeSearch(rangeSearchSettings& settings, ProteinDataHandler heldProteinSets, AtomToNumHashTable atomReferenceTable, int set, int currentEntry);



#endif
