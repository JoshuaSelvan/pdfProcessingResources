
#include "ESBTL_ProteinHandler.h"
#include "ESBTL/default.h"
#include "miscFunctions.h"



typedef ESBTL::Accept_none_occupancy_policy<ESBTL::PDB::Line_format<> > Accept_none_occupancy_policy;



ProteinDataHandler::ProteinDataHandler(rangeSearchSettings currentSettings)
{
	int totalNumbersToReserve;

	for (int i = 0; i<5; i++)
	{
		ProteinDataHolder[i].heldEntries = 0;
		ProteinDataHolder[i].MaxEntrySize = currentSettings.maxProteinLengthPerRange[i];
		ProteinDataHolder[i].MaxNumOfEntries = currentSettings.maxNumOfEntriesPerRange[i];
		ProteinDataHolder[i].KdTreeSize = currentSettings.maxProteinLengthPerRange[i] * 2;

		totalNumbersToReserve = ProteinDataHolder[i].MaxEntrySize * ProteinDataHolder[i].MaxNumOfEntries;

		ProteinDataHolder[i].namesSets = new short[totalNumbersToReserve];
		ProteinDataHolder[i].xCoordsSets = new int[totalNumbersToReserve];
		ProteinDataHolder[i].yCoordsSets = new int[totalNumbersToReserve];
		ProteinDataHolder[i].zCoordsSets = new int[totalNumbersToReserve];
		ProteinDataHolder[i].proteinLengthCounts = new int[ProteinDataHolder[i].MaxNumOfEntries];
		ProteinDataHolder[i].kdTrees = new int[totalNumbersToReserve*2];
		ProteinDataHolder[i].xyzCoordsSets = new int[totalNumbersToReserve * 3];
		ProteinDataHolder[i].compositionLists = new int[totalNumbersToReserve];
		ProteinDataHolder[i].compositionPointers = new int[totalNumbersToReserve];
		ProteinDataHolder[i].compositionCountsList = new int[ProteinDataHolder[i].MaxNumOfEntries];
	}
	

    for (int i = 0; i < 5; i++)
	{
		assert(ProteinDataHolder[i].namesSets != NULL);
		assert(ProteinDataHolder[i].xCoordsSets != NULL);
		assert(ProteinDataHolder[i].yCoordsSets != NULL);
		assert(ProteinDataHolder[i].zCoordsSets != NULL);
		assert(ProteinDataHolder[i].namesSets != NULL);
		assert(ProteinDataHolder[i].kdTrees != NULL);

		assert(ProteinDataHolder[i].compositionLists != NULL);
		assert(ProteinDataHolder[i].compositionCountsList != NULL);
		assert(ProteinDataHolder[i].proteinLengthCounts != NULL);
	}
    
	clock_t start, stop;
	start = clock();

	for (int i = 0; i<5; i++)
	{
		totalNumbersToReserve = ProteinDataHolder[i].MaxEntrySize * ProteinDataHolder[i].MaxNumOfEntries; //not abbreviating like this is extremely expensive

		std::fill(ProteinDataHolder[i].namesSets, ProteinDataHolder[i].namesSets + totalNumbersToReserve, -1);
		std::fill(ProteinDataHolder[i].xCoordsSets, ProteinDataHolder[i].xCoordsSets + totalNumbersToReserve, 999999);
		std::fill(ProteinDataHolder[i].yCoordsSets, ProteinDataHolder[i].yCoordsSets + totalNumbersToReserve, 999999);
		std::fill(ProteinDataHolder[i].zCoordsSets, ProteinDataHolder[i].zCoordsSets + totalNumbersToReserve, 999999);
		std::fill(ProteinDataHolder[i].kdTrees, ProteinDataHolder[i].kdTrees + totalNumbersToReserve, -1);
	}

	stop = clock();
	if (currentSettings.debugLevel>0)
		print_elapsed(start, stop, "Reserve memory runtime: ");

}


void  ProteinDataHandler::createSubListsContainingValidFilesForEachRangeOnly(rangeSearchSettings &currentSettings)
{
	std::ofstream range1("range1FileList.txt");
	std::ofstream range2("range2FileList.txt");
	std::ofstream range3("range3FileList.txt");
	std::ofstream range4("range4FileList.txt");
	std::ofstream range5("range5FileList.txt");
	std::ofstream rangeAll("AllRangesFileList.txt");

	int currentFileRange=-1;
	int debugLvl = currentSettings.debugLevel;
	std::ifstream fileLoader;
	fileLoader.open(currentSettings.inputListFileLocation.c_str());
	std::string currentFile;

	short filesLoaded = 0;
	// for (int i=0;i<5;i++)
	// ProteinDataHolder[i].heldEntries;


	if (debugLvl>0)
		std::cout << "Max Number of files to store: " << currentSettings.numberOfFiles << std::endl;
	while (fileLoader >> currentFile)
	{
		currentFileRange = determineRangeOfSingleProteinFile(currentFile, currentSettings);
		if (currentFileRange != -1)
		{
			rangeAll <<  currentFile << std::endl;

			filesLoaded++;
			if (currentFileRange == 0 )
				range1 <<  currentFile << std::endl;
			else if (currentFileRange == 1)
				range2 <<  currentFile << std::endl;
			else if (currentFileRange == 2)
				range3 <<  currentFile << std::endl;
			else if (currentFileRange == 3)
				range4 <<  currentFile << std::endl;
			else if (currentFileRange == 4)
				range5 <<  currentFile << std::endl;

		}
		if (debugLvl>1)
			std::cout << filesLoaded << std::endl;
	}
	std::cout << "number of files succesfully split into sublists: " << filesLoaded << std::endl << std::endl;

	std::cout << std::endl;



	range1.close();
	range2.close();
	range3.close();
	range4.close();
	range5.close();
	rangeAll.close();
}


int ProteinDataHandler::determineRangeOfSingleProteinFile(std::string proteinFileLocation, rangeSearchSettings &currentSettings)
{
	
	int numOfAtomsInCurrentProtein = 0;
	int destinationSet = 0;
	std::cout << "Processing file: " << proteinFileLocation << "\t ";// << std::endl;
	ESBTL::PDB_line_selector_two_systems sel;
	std::vector<ESBTL::Default_system> systems;
	ESBTL::All_atom_system_builder<ESBTL::Default_system> builder(systems, sel.max_nb_systems());
	if (ESBTL::read_a_pdb_file(proteinFileLocation, sel, builder, Accept_none_occupancy_policy()))
	{
		if (systems.empty() || systems[0].has_no_model()){
			std::cerr << "No atoms found in file " << proteinFileLocation << std::endl;
			return -1;
		}
		else
		{
			for (ESBTL::Default_system::Models_iterator it_model = systems[0].models_begin(); it_model != systems[0].models_end(); ++it_model)
			{
				const ESBTL::Default_system::Model& model = *it_model;
				for (ESBTL::Default_system::Model::Atoms_const_iterator it_atm = model.atoms_begin(); it_atm != model.atoms_end(); ++it_atm)
				{
					numOfAtomsInCurrentProtein++;
				}
			}

			if (numOfAtomsInCurrentProtein != 0)
			{
				int t = 0;
				for (t = 0; t < 5; t++)
				{
					if (numOfAtomsInCurrentProtein < ProteinDataHolder[t].MaxEntrySize)
					{
						destinationSet = t;
						t = t + 100;
					}
				}
				if ((t>99))
				{
					return destinationSet;
				}
				else
				{
					std::cout << "file of length: " << numOfAtomsInCurrentProtein << " did not fall in valid range" << std::endl;
					return -1;
				}
			}
		}
	}
	else
	{
		std::cout << "error occured with loading file" << std::endl;
		return -1;
	}
	return -1;
}



void ProteinDataHandler::loadAllProteinsToArrays(std::string inputFileLocationsList, AtomToNumHashTable &atomReferenceTable, rangeSearchSettings &currentSettings)
{
	int debugLvl = currentSettings.debugLevel;
    std::ifstream fileLoader;
    fileLoader.open(inputFileLocationsList.c_str());
	std::string currentFile;
    
    int filesLoaded =0;
   // for (int i=0;i<5;i++)
   // ProteinDataHolder[i].heldEntries;


	if (debugLvl>0)
		std::cout<<"Max Number of files to store: "<<currentSettings.numberOfFiles<<std::endl;
	while ((fileLoader >> currentFile) && (filesLoaded<currentSettings.numberOfFiles))
	{
		filesLoaded = filesLoaded + loadSingleProteinDetailsIntoArrays(currentFile, atomReferenceTable,currentSettings);
		if (debugLvl>1)
		{
			if (filesLoaded > 0)
				std::cout << filesLoaded << std::endl;
			else
				return;
		}
		//	std::cout<<filesLoaded<<std::endl;
	}
	std::cout<<"number of files succesfully loaded into the holding arrays: "<<filesLoaded<<std::endl<<std::endl;
   
	for (int i=0; i<5;i++)
    {
		std::cout << "Number of entries in the " << ProteinDataHolder[i].MaxEntrySize << " range is: " << ProteinDataHolder[i].heldEntries << std::endl;
    }
	std::cout << std::endl;
    
};

int ProteinDataHandler::loadSingleProteinDetailsIntoArrays(std::string proteinFileLocation, AtomToNumHashTable &atomReferenceTable, rangeSearchSettings &currentSettings)
{
	int debugLvl = currentSettings.debugLevel;
    int numOfAtomsInCurrentProtein = 0;
    int destinationSet = 0;
    int arrayInsertionStartPoint =0;
    
	std::cout << "Processing file: " << proteinFileLocation<<"\t ";// << std::endl;
    ESBTL::PDB_line_selector_two_systems sel;
    std::vector<ESBTL::Default_system> systems;
    ESBTL::All_atom_system_builder<ESBTL::Default_system> builder(systems, sel.max_nb_systems());
	if (ESBTL::read_a_pdb_file(proteinFileLocation, sel, builder, Accept_none_occupancy_policy()))
    {
           if (systems.empty() || systems[0].has_no_model()){
			   std::cerr << "No atoms found in file " << proteinFileLocation << std::endl;
                    return 0;
            }
            else
            {
                    for (ESBTL::Default_system::Models_iterator it_model = systems[0].models_begin(); it_model != systems[0].models_end(); ++it_model)
                    {
                           const ESBTL::Default_system::Model& model = *it_model;
                           for (ESBTL::Default_system::Model::Atoms_const_iterator it_atm = model.atoms_begin(); it_atm != model.atoms_end(); ++it_atm)
                           {
                                   numOfAtomsInCurrentProtein++;
                           }
                    } 
                    
                    
                    if(numOfAtomsInCurrentProtein!=0)
                    {
						
						int t = 0;
                        for ( t = 0; t < 5; t++)
			            {
				           if (numOfAtomsInCurrentProtein < ProteinDataHolder[t].MaxEntrySize)
				           {
					           destinationSet = t;
					           t = t + 100;
				           }
			           }
                       if((t>99)&&(ProteinDataHolder[destinationSet].heldEntries<ProteinDataHolder[destinationSet].MaxNumOfEntries))
                       { 
                           int localCounter=0;
                           arrayInsertionStartPoint= ProteinDataHolder[destinationSet].heldEntries* ProteinDataHolder[destinationSet].MaxEntrySize;
                           for (ESBTL::Default_system::Models_iterator it_model = systems[0].models_begin(); it_model != systems[0].models_end(); ++it_model)
                           {
                               const ESBTL::Default_system::Model& model = *it_model;
                               for (ESBTL::Default_system::Model::Atoms_const_iterator it_atm = model.atoms_begin(); it_atm != model.atoms_end(); ++it_atm)
                               { 
								   ProteinDataHolder[destinationSet].namesSets[arrayInsertionStartPoint + localCounter] = atomReferenceTable.retrieveHashValue(it_atm->atom_name());
                                    ProteinDataHolder[destinationSet].xCoordsSets[arrayInsertionStartPoint+localCounter] = (it_atm->x()*1000);
                                    ProteinDataHolder[destinationSet].yCoordsSets[arrayInsertionStartPoint+localCounter] = (it_atm->y()*1000);
                                    ProteinDataHolder[destinationSet].zCoordsSets[arrayInsertionStartPoint+localCounter] = (it_atm->z()*1000);
                                    localCounter++;
                               }
                           }
                           ProteinDataHolder[destinationSet].proteinLengthCounts[ProteinDataHolder[destinationSet].heldEntries]=localCounter;
                           ProteinDataHolder[destinationSet].heldEntries++;
                           return 1;
                       }
                       else
                       {
						   std::cout << "file of length: " << numOfAtomsInCurrentProtein << " did not fall in valid range" << std::endl;
                           return 0; 
                       }
                    }
            }
    }
    else
    {
        std::cout<<"error occured with loading file"<<std::endl;
        return 0;
    }


	return 0;
    
};

int checkNumberOfProteinFilesInList(std::string inputFileLocationList)
{
	int numberOfFiles=0;

	std::ifstream fileLoader;
	fileLoader.open(inputFileLocationList.c_str());
	std::string currentFile;

	while (fileLoader >> currentFile)
	{
		numberOfFiles++;
	}
	std::cout << "Total number of files in inputted list: " << numberOfFiles << std::endl<<std::endl;
	return numberOfFiles;
};


void ProteinDataHandler::populateXYZarrayForGPUProcessing() //places sets of x,y and z coords next to each other in a larger array;
{
	int offsetOfAtomCoordsinSet;
	int lengthOfCoordSet;
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < ProteinDataHolder[i].heldEntries; j++)
		{
			for (int currentAtom = 0; currentAtom < ProteinDataHolder[i].MaxEntrySize; currentAtom++)
			{
				offsetOfAtomCoordsinSet = j * 3 * ProteinDataHolder[i].MaxEntrySize;
				lengthOfCoordSet = ProteinDataHolder[i].MaxEntrySize;
				ProteinDataHolder[i].xyzCoordsSets[offsetOfAtomCoordsinSet + currentAtom] = ProteinDataHolder[i].xCoordsSets[j*lengthOfCoordSet + currentAtom];
				ProteinDataHolder[i].xyzCoordsSets[offsetOfAtomCoordsinSet + lengthOfCoordSet + currentAtom] = ProteinDataHolder[i].yCoordsSets[j*lengthOfCoordSet + currentAtom];
				ProteinDataHolder[i].xyzCoordsSets[offsetOfAtomCoordsinSet + lengthOfCoordSet * 2 + currentAtom] = ProteinDataHolder[i].zCoordsSets[j*lengthOfCoordSet + currentAtom];
			}
		}
	}
	
};

void formatSecondaryPositionStructure(short* namesSetsArray, int maximumLengthOfChains, int EntryCount, int* chainLengthsList, int* compositionCountsList, int*compositionListArray, int*compositionPointerArray)
{


	std::fill(compositionCountsList, compositionCountsList + EntryCount, 0);
	std::fill(compositionPointerArray, compositionPointerArray + EntryCount*maximumLengthOfChains,-1);

	for (int i = 0; i < EntryCount*maximumLengthOfChains; i = i + 2)
	{
		compositionListArray[i] = -1;
		compositionListArray[i + 1] = 0;

	}

	for (int i = 0; i < EntryCount; i++)
	{
		//std::cout << "Processing entry " <<i<<"of "<<EntryCount<< std::endl;
		int startOffSet = i*maximumLengthOfChains;
		int numberOfAtomsPlaced = 0;//purely for testing
		for (int j = 0; j < chainLengthsList[i]; j++) //We look at every actual atom in the array, not the blank spaces
		{
			int atomRecordSearcher = 0;

			int currentName = namesSetsArray[startOffSet + j];
			while (atomRecordSearcher< chainLengthsList[i]) //This first loops fetches the names and numbers of each atom in a protein and stores that data in compositionListArray. If a protein has a number of unique atoms which is greater then half the length of the protein ranges maximum size, the approach will crash.
			{
				if (compositionListArray[startOffSet + atomRecordSearcher] == -1)
				{
					compositionListArray[startOffSet + atomRecordSearcher] = currentName;
					compositionListArray[startOffSet + atomRecordSearcher + 1]++;
					compositionCountsList[i]++;
					numberOfAtomsPlaced++;
					atomRecordSearcher = atomRecordSearcher + chainLengthsList[i] + 1;//break out of while loop
					if (compositionCountsList[0] == (maximumLengthOfChains / 2))
						std::cout << "This will cause errors" << std::endl;
				}
				else if (compositionListArray[startOffSet + atomRecordSearcher] == currentName)
				{
					compositionListArray[startOffSet + atomRecordSearcher + 1]++;
					atomRecordSearcher = atomRecordSearcher + chainLengthsList[i] + 1;//break out of while loop
					numberOfAtomsPlaced++;
				}
				else if (atomRecordSearcher >= chainLengthsList[i])
				{
					std::cout << "MAXIMUM LIST SIZE EXEEDED" << std::endl;
					atomRecordSearcher = atomRecordSearcher + chainLengthsList[i] + 1;//break out of while loop

				}


				atomRecordSearcher++;
				atomRecordSearcher++;
			}

		}
		if (numberOfAtomsPlaced != chainLengthsList[i])
		{
			std::cout << "something went wrong" << std::endl;
		}
	}


	for (int i = 0; i < EntryCount; i++)
	{
		int startOffSet = i*maximumLengthOfChains;
		int numOfAtomTypesToProcess = compositionCountsList[i];
		int placedEntries = 0;
		for (int j = 0; j < numOfAtomTypesToProcess; j++)
		{
			int nameType = compositionListArray[startOffSet + j * 2];
			int nameEntries = compositionListArray[startOffSet + j * 2 + 1];
			int PlacedEntriesOfSet = 0;
			int PosInSet = 0;
			while (PlacedEntriesOfSet < nameEntries)
			{
				if (namesSetsArray[startOffSet + PosInSet] == nameType)
				{
					compositionPointerArray[startOffSet + placedEntries] = (startOffSet + PosInSet);
					placedEntries++;
					PlacedEntriesOfSet++;
				}
				PosInSet++;
				if ((PosInSet >= maximumLengthOfChains) || (PosInSet > chainLengthsList[i]))
				{
					std::cout << "We have issues" << std::endl;
					for (int i = PlacedEntriesOfSet; i < nameEntries; i++)
					{
						compositionPointerArray[startOffSet + placedEntries] = -5;
						placedEntries++;
						PlacedEntriesOfSet++;

					}
					PlacedEntriesOfSet = nameEntries;
				}
			}
		}
	}
}

void ProteinDataHandler::setSecondarySearchStructure()
{
	//Null all secondary Structure arrays;
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < ProteinDataHolder[i].heldEntries; j++)
		{
			ProteinDataHolder[i].compositionCountsList[j] = 0; //holds the number of atom types in each protein
		}
	}

	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < ProteinDataHolder[i].heldEntries*ProteinDataHolder[i].MaxEntrySize; j++)
		{
			ProteinDataHolder[i].compositionLists[j] = 0;//Holds pointers to the positions of all the atoms in each protein set
			ProteinDataHolder[i].compositionPointers[j] = 0;//Will hold the names of each aotm type present followed by the position in the composition list where those atoms start
		}
	}

	//Construct secondary structures 
	for (int i = 0; i<5; i++)
	{
		formatSecondaryPositionStructure(ProteinDataHolder[i].namesSets, ProteinDataHolder[i].MaxEntrySize, ProteinDataHolder[i].heldEntries, ProteinDataHolder[i].proteinLengthCounts, ProteinDataHolder[i].compositionCountsList, ProteinDataHolder[i].compositionLists, ProteinDataHolder[i].compositionPointers);
	}



}

