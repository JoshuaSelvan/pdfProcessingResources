#include"gpuBruteForceSearch.cuh"



#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort = true)
{
	if (code != cudaSuccess)
	{
		fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
		if (abort) exit(code);
	}
}



void gpuBruteForceRangeSearchAllLoadedSets(rangeSearchSettings& settings, ProteinDataHandler heldProteinSets, AtomToNumHashTable atomReferenceTable)
{
	std::cout << "PERFORMING GPU BASED BRUTE FORCE RANGE SEARCH" << std::endl;
	//all data has been preloaded into the host side ProteinDataHandler object. All that is needed is to initialise containers, moves sets of data to the gpu, process those sets of data and then return the results.

	//Initialise host and device data holders
	gpuRangeSearchResources rangeSearch;
	int safeHolderSize = 32000 *1200* 4; //home gpu probably cant hold this many -.-
	//int blocks = 0;
	//int threads = 0;
	//int currentEntry = 0;
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomACount, sizeof(int)));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomAPositionList, safeHolderSize));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomACurrentSearchDimensions, safeHolderSize));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomACurrentSearchKdTreePositions, safeHolderSize));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomAMatches, safeHolderSize));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_atomBMatches, safeHolderSize));
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_MatchesCount, sizeof(int)));
//	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_nextSearchCount, sizeof(int)));
//	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_completionFlag, sizeof(int)));
//	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_kdTreeSets, safeHolderSize * 2));

	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_namesSets, safeHolderSize / 2));
	
	//gpuErrchk(cudaMalloc((void**)&rangeSearch.d_xyzCoordsSets, safeHolderSize * 3));

	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_xCoordsSets, safeHolderSize));
	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_yCoordsSets, safeHolderSize));
	gpuErrchk(cudaMalloc((void**)&rangeSearch.d_zCoordsSets, safeHolderSize));

//	rangeSearch.h_atomACount = (int*)malloc(sizeof(int));
//	rangeSearch.h_atomAPositionList = (int*)malloc(safeHolderSize);
//	rangeSearch.h_nextSearchCount = (int*)malloc(sizeof(int));
//	rangeSearch.h_completionFlag = (int*)malloc(sizeof(int));
//	rangeSearch.h_MatchesCount = (int*)malloc(sizeof(int));
//	rangeSearch.h_atomAMatches = (int*)malloc(safeHolderSize);
//	rangeSearch.h_atomBMatches = (int*)malloc(safeHolderSize);

	//cudaStream_t streams[3];


	//cudaStreamCreate(&streams[0]);
	//cudaStreamCreate(&streams[1]);
	//cudaStreamCreate(&streams[2]);

	//load data into holder arrays:
	//int entrySize = heldProteinSets.ProteinDataHolder[0].MaxEntrySize;
	//int kdEntrySize = heldProteinSets.ProteinDataHolder[0].KdTreeSize;

	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_xCoordsSets, heldProteinSets.ProteinDataHolder[0].xCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[0]));
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_yCoordsSets, heldProteinSets.ProteinDataHolder[0].yCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[1]));
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_zCoordsSets, heldProteinSets.ProteinDataHolder[0].zCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[2]));
	//Leaving this here as backup notation for the kd tree search - delete when its operational
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_xyzCoordsSets, heldProteinSets.ProteinDataHolder[0].xCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[0]));
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_xyzCoordsSets + entrySize, heldProteinSets.ProteinDataHolder[0].yCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[1]));
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_xyzCoordsSets + entrySize * 2, heldProteinSets.ProteinDataHolder[0].zCoordsSets, entrySize*sizeof(int), cudaMemcpyHostToDevice, streams[2]));
	//gpuErrchk(cudaMemcpyAsync(rangeSearch.d_namesSets, heldProteinSets.ProteinDataHolder[0].namesSets, entrySize / sizeof(int)*sizeof(short), cudaMemcpyHostToDevice, streams[0]));
//	gpuErrchk(cudaMemcpyAsync(rangeSearch.d_kdTreeSets, heldProteinSets.ProteinDataHolder[0].kdTrees, kdEntrySize*sizeof(int), cudaMemcpyHostToDevice, streams[0]));



	int soughtAtomANumber = atomReferenceTable.retrieveHashValue(settings.AtomTypeOne);
	int soughtAtomBNumber = atomReferenceTable.retrieveHashValue(settings.AtomTypeTwo);

	//gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomACount, 0, sizeof(int), streams[0]));
	//gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomAPositionList, -1, safeHolderSize, streams[1]));
	//gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomAMatches, -1, safeHolderSize, streams[2]));
	//gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomBMatches, -1, safeHolderSize, streams[0]));
//	gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomACurrentSearchDimensions, 0, safeHolderSize, streams[1]));
//	gpuErrchk(cudaMemsetAsync(rangeSearch.d_atomACurrentSearchKdTreePositions, -1, safeHolderSize, streams[2]));
//	gpuErrchk(cudaMemsetAsync(rangeSearch.d_MatchesCount, 0, sizeof(int), streams[0]));
//	gpuErrchk(cudaMemsetAsync(rangeSearch.d_nextSearchCount, 0, sizeof(int), streams[1]));
//	gpuErrchk(cudaMemsetAsync(rangeSearch.d_completionFlag, 0, sizeof(int), streams[2]));
//	rangeSearch.h_MatchesCount[0] = 0;

//	calculateInitialBlocksAndThreads(blocks, threads, heldProteinSets.ProteinDataHolder[0].MaxEntrySize);



//	cudaDeviceSynchronize();

//	device_side__locateElement << <blocks, threads, 0, streams[0] >> >(rangeSearch.d_namesSets, currentEntry, soughtAtomANumber, rangeSearch.d_atomAPositionList, rangeSearch.d_atomACount, rangeSearch.d_atomACurrentSearchDimensions, rangeSearch.d_atomACurrentSearchKdTreePositions, heldProteinSets.ProteinDataHolder[0].MaxEntrySize);

//	gpuErrchk(cudaMemcpyAsync(rangeSearch.h_atomACount, rangeSearch.d_atomACount, sizeof(int), cudaMemcpyDeviceToHost, streams[0]));
//	gpuErrchk(cudaMemcpyAsync(rangeSearch.h_atomAPositionList, rangeSearch.d_atomAPositionList, safeHolderSize, cudaMemcpyDeviceToHost, streams[1]));
       	int currentMaxEntrySize;
	int currentHeldEntries;
        for (int i = 0; i < 5; i++)
	{
			currentMaxEntrySize = heldProteinSets.ProteinDataHolder[i].MaxEntrySize;
			currentHeldEntries = heldProteinSets.ProteinDataHolder[i].heldEntries;
			cudaHostRegister(heldProteinSets.ProteinDataHolder[i].xCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), 0);
			cudaHostRegister(heldProteinSets.ProteinDataHolder[i].yCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), 0);
			cudaHostRegister(heldProteinSets.ProteinDataHolder[i].zCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), 0);
			cudaHostRegister(heldProteinSets.ProteinDataHolder[i].namesSets, currentMaxEntrySize * currentHeldEntries * sizeof(short), 0);
	}

	for (int i = 0; i < 5; i++)
	{
		

		if (heldProteinSets.ProteinDataHolder[i].heldEntries>0)
		{
			currentMaxEntrySize = heldProteinSets.ProteinDataHolder[i].MaxEntrySize;
			currentHeldEntries = heldProteinSets.ProteinDataHolder[i].heldEntries;
			std::cout << "Processing Range set: " << i << std::endl;
			std::cout << "Number of present entries is: " << currentHeldEntries << std::endl;
			gpuErrchk(cudaMemcpy(rangeSearch.d_namesSets, heldProteinSets.ProteinDataHolder[i].namesSets, currentMaxEntrySize * currentHeldEntries * sizeof(short), cudaMemcpyHostToDevice));
			gpuErrchk(cudaMemcpy(rangeSearch.d_xCoordsSets, heldProteinSets.ProteinDataHolder[i].xCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), cudaMemcpyHostToDevice));
			gpuErrchk(cudaMemcpy(rangeSearch.d_yCoordsSets, heldProteinSets.ProteinDataHolder[i].yCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), cudaMemcpyHostToDevice));
			gpuErrchk(cudaMemcpy(rangeSearch.d_zCoordsSets, heldProteinSets.ProteinDataHolder[i].zCoordsSets, currentMaxEntrySize * currentHeldEntries * sizeof(int), cudaMemcpyHostToDevice));

			//run bruteForce set runner
			clock_t n, m;
			n = clock();
			bruteForceSearchPreLoadedArraySets(rangeSearch.d_namesSets, rangeSearch.d_xCoordsSets, rangeSearch.d_yCoordsSets, rangeSearch.d_zCoordsSets, currentMaxEntrySize, soughtAtomANumber, soughtAtomBNumber, currentHeldEntries, settings, heldProteinSets.ProteinDataHolder[i].xCoordsSets, heldProteinSets.ProteinDataHolder[i].yCoordsSets, heldProteinSets.ProteinDataHolder[i].zCoordsSets, heldProteinSets.ProteinDataHolder[i].namesSets, i);
			m = clock();
			print_elapsed(n, m, "run time for bruteset mini: ");
			std::cout << std::endl;
		}

	} 



		
	for (int i = 0; i < 5; i++)
	{

		currentMaxEntrySize = heldProteinSets.ProteinDataHolder[i].MaxEntrySize;
		currentHeldEntries = heldProteinSets.ProteinDataHolder[i].heldEntries;
		cudaHostUnregister(heldProteinSets.ProteinDataHolder[i].xCoordsSets);
		cudaHostUnregister(heldProteinSets.ProteinDataHolder[i].yCoordsSets);
		cudaHostUnregister(heldProteinSets.ProteinDataHolder[i].zCoordsSets);
		cudaHostUnregister(heldProteinSets.ProteinDataHolder[i].namesSets);

	}


	gpuErrchk(cudaFree(rangeSearch.d_xCoordsSets));
	gpuErrchk(cudaFree(rangeSearch.d_yCoordsSets));
	gpuErrchk(cudaFree(rangeSearch.d_zCoordsSets));
	gpuErrchk(cudaFree(rangeSearch.d_namesSets));

}




void bruteForceSearchPreLoadedArraySets(short * d_namesSet, int*d_xValsSet, int*d_yValsSet, int*d_zValsSet, int MaximumlengthOfChains, short elementA, short  elementB, int numOfEntries, rangeSearchSettings& settings, int * h_xValsSets, int * h_yValSets, int *h_zValSets, short* h_names, int currentSet)
{
	
	gpuBruteForceResources resources;

	resources.h_resultsCount = (int*)malloc(1 * sizeof(int));
	resources.h_resultsA = (int*)malloc(MaximumlengthOfChains * 100 * sizeof(int));
	resources.h_resultsB = (int*)malloc(MaximumlengthOfChains * 100 * sizeof(int));
	resources.h_aCount = (int*)malloc(1 * sizeof(int));
	resources.h_bCount = (int*)malloc(1 * sizeof(int));
	resources.h_elementAList = (int*)malloc(MaximumlengthOfChains * sizeof(int)); //I used these for loading the element arrays back from the device to check what was in them, otherwise commented out.
	resources.h_elementBList = (int*)malloc(MaximumlengthOfChains * sizeof(int));
	gpuErrchk(cudaMalloc((void**)&resources.d_resultsCount, 1 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_resultsA, MaximumlengthOfChains * 100 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_resultsB, MaximumlengthOfChains * 100 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_elementAList, MaximumlengthOfChains * 10 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_elementBList, MaximumlengthOfChains * 10 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_aCount, 1 * sizeof(int)));
	gpuErrchk(cudaMalloc((void**)&resources.d_bCount, 1 * sizeof(int)));
	gpuErrchk(cudaMemset(resources.d_resultsCount, 0, 1 * sizeof(int)));
	gpuErrchk(cudaMemset(resources.d_resultsA, -1, MaximumlengthOfChains * 10 * sizeof(int)));
	gpuErrchk(cudaMemset(resources.d_resultsB, -1, MaximumlengthOfChains * 10 * sizeof(int)));
	gpuErrchk(cudaMemset(resources.d_aCount, 0, 1 * sizeof(int)));
	gpuErrchk(cudaMemset(resources.d_bCount, 0, 1 * sizeof(int)));

	//I assume these are for testing purposes
	gpuErrchk(cudaMemcpy(resources.h_resultsCount, resources.d_resultsCount, 1 * sizeof(int), cudaMemcpyDeviceToHost));
	gpuErrchk(cudaMemcpy(resources.h_resultsA, resources.d_resultsA, 200 * sizeof(int), cudaMemcpyDeviceToHost));

	//Configure the block and thread size based on max chain length size.
	resources.threads = 512;
	if (MaximumlengthOfChains < 513)
	{
		resources.blocks = 1;
	}
	else
	{
		resources.blocks = (MaximumlengthOfChains + resources.threads - 1) / resources.threads; //may need to check this behaves as expected.}
	}
	resources.concurrentThreads = resources.blocks*resources.threads;

	int outputType = settings.resultsPrintFormat;
	outputHandler filePrinter;
	std::string printType;

	if (outputType == 3)
	{
		printType = "_Summary";
	}
	else if (outputType == 4)
	{
		printType = "_Detailed";
	}


	if (outputType == 3 || outputType == 4)//will move into loop shortly
	{
		filePrinter.initializeOutputfile("GpuBruteResults_Range_", MaximumlengthOfChains, "_Files_", numOfEntries, printType);
	}



	short * names = (short*)malloc(MaximumlengthOfChains*numOfEntries*sizeof(short));

	int numberOfFilesProcessed = 0;
	for (short i = 0; i < numOfEntries; i++)
	{
		gpuErrchk(cudaMemset(resources.d_resultsCount, 0, 1 * sizeof(int))); //working
		gpuErrchk(cudaMemset(resources.d_resultsA, -1, MaximumlengthOfChains * 100 * sizeof(int)));
		gpuErrchk(cudaMemset(resources.d_resultsB, -1, MaximumlengthOfChains * 100 * sizeof(int)));
		gpuErrchk(cudaMemset(resources.d_aCount, 0, 1 * sizeof(int)));
		gpuErrchk(cudaMemset(resources.d_bCount, 0, 1 * sizeof(int)));
		gpuErrchk(cudaMemset(resources.d_elementAList, -1, MaximumlengthOfChains * 10 * sizeof(int)));
		gpuErrchk(cudaMemset(resources.d_elementBList, -1, MaximumlengthOfChains * 10 * sizeof(int)));

		resources.h_aCount[0] = 0;
		resources.h_bCount[0] = 0; //just for testing



		DeviceLoadedArrays_SingleProtein_LocateElements << <resources.blocks, resources.threads >> >(d_namesSet, resources.d_elementAList, resources.d_elementBList, elementA, elementB, resources.d_aCount, resources.d_bCount, MaximumlengthOfChains, i, resources.concurrentThreads, resources.d_resultsA, resources.d_resultsB, resources.d_resultsCount, d_xValsSet, d_yValsSet, d_zValsSet, settings.requiredProximity);
		DeviceLoadedArrays_SingleProtein_BruteForceSearch << <resources.blocks, resources.threads >> >(d_namesSet, resources.d_elementAList, resources.d_elementBList, elementA, elementB, resources.d_aCount, resources.d_bCount, MaximumlengthOfChains, i, resources.concurrentThreads, resources.d_resultsA, resources.d_resultsB, resources.d_resultsCount, d_xValsSet, d_yValsSet, d_zValsSet, settings.requiredProximity);
		
		gpuErrchk(cudaMemcpy(resources.h_elementAList, resources.d_elementAList, MaximumlengthOfChains * sizeof(int), cudaMemcpyDeviceToHost));
		gpuErrchk(cudaMemcpy(resources.h_elementBList, resources.d_elementBList, MaximumlengthOfChains * sizeof(int), cudaMemcpyDeviceToHost));
		gpuErrchk(cudaMemcpy(resources.h_aCount, resources.d_aCount, 1 * sizeof(int), cudaMemcpyDeviceToHost));
		gpuErrchk(cudaMemcpy(resources.h_bCount, resources.d_bCount, 1 * sizeof(int), cudaMemcpyDeviceToHost));

	
		if (outputType == 1 || outputType == 2)
			std::cout << "Number of matches in file " << i << " in set " << currentSet << " is: " << resources.h_aCount[0] << std::endl; //contains a slight hack to get the current range for the first 2
		else if (outputType == 3 || outputType == 4)
			filePrinter.printLineToOutputFile("Number of matches in file ", i, " in set ", currentSet, "  is: ", resources.h_aCount[0]);

		//retrieve result arrays from device
		gpuErrchk(cudaMemcpy(resources.h_resultsCount, resources.d_resultsCount, sizeof(int), cudaMemcpyDeviceToHost));

	
		if (resources.h_resultsCount[0]<(MaximumlengthOfChains * 9)) //If there are too many results, the program can fail. Not sure what the max limit on results (relative to reserved space) is though.
		{


			gpuErrchk(cudaMemcpy(resources.h_resultsA, resources.d_resultsA, resources.h_resultsCount[0] * 2 * sizeof(int), cudaMemcpyDeviceToHost));
			gpuErrchk(cudaMemcpy(resources.h_resultsB, resources.d_resultsB, resources.h_resultsCount[0] * 2 * sizeof(int), cudaMemcpyDeviceToHost));

			if (resources.h_resultsCount[0]>0)
			{

				//if ((resources.h_bCount[0]>0) || (resources.h_aCount[0]>0)) //just for testing
				//{

				//	int larger = resources.h_aCount[0];
				//	if (resources.h_bCount[0]>larger)
				//		larger = resources.h_bCount[0];
				//	for (int t = 0; t < larger; t++)
				//	{
						//              outputFile << h_elementAList[t]<<"\t"<<h_names[i*MaximumlengthOfChains+h_elementAList[t]] << "\t" << h_elementBList[t] << "\t"<< h_names[i*MaximumlengthOfChains+h_elementBList[t]] <<endl;
				//	}
				//}
				if (resources.h_resultsCount[0]>0)
				{
					for (int j = 0; j < resources.h_resultsCount[0]; j++)
					{
						if (outputType == 2)
						{
							std::cout << "AtomA: " << h_names[i*MaximumlengthOfChains + resources.h_resultsA[j]] << "\t - Pos : " << resources.h_resultsA[j] << "\t X: " << (double(h_xValsSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000) << "\t Y: " << (double(h_yValSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000) << "\t Z: " << (double(h_zValSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000) << std::endl;
							std::cout << "AtomB: " << h_names[i*MaximumlengthOfChains + resources.h_resultsB[j]] << "\t - Pos : " << resources.h_resultsB[j] << "\t X: " << (double(h_xValsSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000) << "\t Y: " << (double(h_yValSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000) << "\t Z: " << (double(h_zValSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000) << std::endl;
							std::cout << std::endl;
						}
						else if (outputType == 4)
						{
							filePrinter.printLineToOutputFile("Atom A: ", h_names[i*MaximumlengthOfChains + resources.h_resultsA[j]], "\t - Pos : ", resources.h_resultsA[j], "\t X: ", (double(h_xValsSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000), "\t Y: ", (double(h_yValSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000), "\t Z: ", (double(h_zValSets[i*MaximumlengthOfChains + resources.h_resultsA[j]]) / 1000));
							filePrinter.printLineToOutputFile("Atom B: ", h_names[i*MaximumlengthOfChains + resources.h_resultsB[j]], "\t - Pos : ", resources.h_resultsB[j], "\t X: ", (double(h_xValsSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000), "\t Y: ", (double(h_yValSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000), "\t Z: ", (double(h_zValSets[i*MaximumlengthOfChains + resources.h_resultsB[j]]) / 1000));
							filePrinter.printLineToOutputFile("");
						}

					}
				}
			}
		}
		numberOfFilesProcessed++;
	}


	filePrinter.closeOpenFile();

	gpuErrchk(cudaFree(resources.d_resultsCount));
	gpuErrchk(cudaFree(resources.d_resultsA));
	gpuErrchk(cudaFree(resources.d_resultsB));
	gpuErrchk(cudaFree(resources.d_elementAList));
	gpuErrchk(cudaFree(resources.d_elementBList));
	gpuErrchk(cudaFree(resources.d_aCount));
	gpuErrchk(cudaFree(resources.d_bCount));



};



//not currently used as combining the kernel creates a fault due to blocks not syncing before the second half.
__global__ void DeviceLoadedArrays_SingleProtein_CompleteBruteForceSearch(short * d_namesSet, int* d_elementAList, int* d_elementBList, short atomA, short atomB, int * d_aCount, int * d_bCount, int standardizedEntrySize, int entryNumber, int concurrentThreads, int*d_resultsAList, int*d_resultsBList, int*d_resultsCount, int* d_xValsSet, int* d_yValsSet, int* d_zValsSet, int requiredProximity)
{
	int id = threadIdx.x + blockDim.x * blockIdx.x;
	int secondroundId = id;
	int resultsArrayInsertPosition;
	int currentDeviceName;
	int currentOffset = entryNumber*standardizedEntrySize;


	if (id == 0)
	{
		d_resultsCount[0] = 0;
		d_aCount[0] = 0;
		d_bCount[0] = 0;
	}
	__syncthreads();
	//while (id < (standardizedEntrySize +currentOffset))
	{
		currentDeviceName = d_namesSet[id + currentOffset];
		if (currentDeviceName == atomA)
		{
			resultsArrayInsertPosition = atomicAdd(&d_aCount[0], 1);
			d_elementAList[resultsArrayInsertPosition] = id;
			
		}
		if (currentDeviceName == atomB)
		{
			resultsArrayInsertPosition = atomicAdd(&d_bCount[0], 1);
			d_elementBList[resultsArrayInsertPosition] = id;
		}
	//	id = id + concurrentThreads;
	}
	__syncthreads();



	if (secondroundId<d_aCount[0])
	{
		int requiredProximitySquared = requiredProximity*requiredProximity;

		int insertPosition;
		short localAtomA = d_elementAList[secondroundId];

		int currentSetOffset = entryNumber*standardizedEntrySize;

		int localXCoord = d_xValsSet[currentSetOffset + localAtomA];
		int localYCoord = d_yValsSet[currentSetOffset + localAtomA];
		int localZCoord = d_zValsSet[currentSetOffset + localAtomA];

		short currentAtomB;
		int BCurrentXCoord;
		int BCurrentYCoord;
		int BCurrentZCoord;
		int distanceBetweenAtoms;

		for (int i = 0; i < d_bCount[0]; i++)
		{
			currentAtomB = d_elementBList[i];
			BCurrentXCoord = d_xValsSet[currentSetOffset + currentAtomB];
			BCurrentYCoord = d_yValsSet[currentSetOffset + currentAtomB];
			BCurrentZCoord = d_zValsSet[currentSetOffset + currentAtomB];		
			distanceBetweenAtoms = ((localXCoord - BCurrentXCoord)*(localXCoord - BCurrentXCoord) + (localYCoord - BCurrentYCoord)*(localYCoord - BCurrentYCoord) + (localZCoord - BCurrentZCoord)*(localZCoord - BCurrentZCoord));
			
			int f = (requiredProximitySquared-distanceBetweenAtoms)/100;
		
			//This loop is triggering regardless of it being right or wrong -.-
			//if (distanceBetweenAtoms < requiredProximitySquared)
			if (f>0)
			{
				insertPosition = atomicAdd(&d_resultsCount[0], 1);
				d_resultsAList[insertPosition] = localAtomA;
				d_resultsBList[insertPosition] = currentAtomB;
			}
		}
	}
};





__global__ void DeviceLoadedArrays_SingleProtein_LocateElements(short * d_namesSet, int* d_elementAList, int* d_elementBList, short atomA, short atomB, int * d_aCount, int * d_bCount, int standardizedEntrySize, int entryNumber, int concurrentThreads, int*d_resultsAList, int*d_resultsBList, int*d_resultsCount, int* d_xValsSet, int* d_yValsSet, int* d_zValsSet, int requiredProximity)
{
	int id = threadIdx.x + blockDim.x * blockIdx.x;
	int resultsArrayInsertPosition;
	int currentDeviceName;
	int currentOffset = entryNumber*standardizedEntrySize;


	if (id == 0)
	{
		d_resultsCount[0] = 0;
		d_aCount[0] = 0;
		d_bCount[0] = 0;
	}
	__syncthreads();
	//while (id < (standardizedEntrySize +currentOffset))
	{
		currentDeviceName = d_namesSet[id + currentOffset];
		if (currentDeviceName == atomA)
		{
			resultsArrayInsertPosition = atomicAdd(&d_aCount[0], 1);
			d_elementAList[resultsArrayInsertPosition] = id;

		}
		if (currentDeviceName == atomB)
		{
			resultsArrayInsertPosition = atomicAdd(&d_bCount[0], 1);
			d_elementBList[resultsArrayInsertPosition] = id;
		}
		//	id = id + concurrentThreads;
	}

};



__global__ void DeviceLoadedArrays_SingleProtein_BruteForceSearch(short * d_namesSet, int* d_elementAList, int* d_elementBList, short atomA, short atomB, int * d_aCount, int * d_bCount, int standardizedEntrySize, int entryNumber, int concurrentThreads, int*d_resultsAList, int*d_resultsBList, int*d_resultsCount, int* d_xValsSet, int* d_yValsSet, int* d_zValsSet, int requiredProximity)
{
	int secondroundId = threadIdx.x + blockDim.x * blockIdx.x;
	

	if (secondroundId<d_aCount[0])
	{
		int requiredProximitySquared = requiredProximity*requiredProximity;

		int insertPosition;
		short localAtomA = d_elementAList[secondroundId];

		int currentSetOffset = entryNumber*standardizedEntrySize;

		int localXCoord = d_xValsSet[currentSetOffset + localAtomA];
		int localYCoord = d_yValsSet[currentSetOffset + localAtomA];
		int localZCoord = d_zValsSet[currentSetOffset + localAtomA];

		short currentAtomB;
		int BCurrentXCoord;
		int BCurrentYCoord;
		int BCurrentZCoord;
		int distanceBetweenAtoms;

		for (int i = 0; i < d_bCount[0]; i++)
		{
			currentAtomB = d_elementBList[i];
			BCurrentXCoord = d_xValsSet[currentSetOffset + currentAtomB];
			BCurrentYCoord = d_yValsSet[currentSetOffset + currentAtomB];
			BCurrentZCoord = d_zValsSet[currentSetOffset + currentAtomB];
			distanceBetweenAtoms = ((localXCoord - BCurrentXCoord)*(localXCoord - BCurrentXCoord) + (localYCoord - BCurrentYCoord)*(localYCoord - BCurrentYCoord) + (localZCoord - BCurrentZCoord)*(localZCoord - BCurrentZCoord));

			int f = (requiredProximitySquared - distanceBetweenAtoms) / 100;

			//This loop is triggering regardless of it being right or wrong -.-
			//if (distanceBetweenAtoms < requiredProximitySquared)
			if (f>0)
			{
				insertPosition = atomicAdd(&d_resultsCount[0], 1);
				d_resultsAList[insertPosition] = localAtomA;
				d_resultsBList[insertPosition] = currentAtomB;
			}
		}
	}
};
