
////////////////
//Include files
#include <stdlib.h>
#include <fstream>
#include <vector>
#include <string> 
#include <algorithm>
#include "windows.h"
#include "EasyBMP.h"
#include "faridAlg.h"

using namespace std;


////////////////////////
//Compilation flags
#define DEBUG



////////////////////////
//Precompiler constants
#define C_INTENSITY_LEVELS		256										/*number of bins in each histogram */
#define C_WORKING_DIRECTORY		"E:\\My Documents\\Ido\\Matlab Code\\Thesis\\Lens Artifacts\\Images\\BMP images\\Authentic images\\" /*the directory where the files should be written/read from*/
#define C_IMAGES_FILE_NAME		"Authentic BMP images.txt"				/*a file containing the images to work on*/
#define C_WINDOWS_PER_ROW_COL	1										/*the number of windows per rows/cols when analyzing a forged image. 
																		 *Each such window is analyzed seperately to detect forged regions*/
#define C_OUTLIERS_PERCENTAGE		(0.15)								/*percentage of pixels concidered as outliers*/
#define C_OUTLIERS_ITERATIONS_NUM	2									/*number of outliers removal iterations*/


////////////////////////
//Enums

typedef enum{
	regular,		//analysis of authentic images. Outputs the calculated center
	croppedImages,	//analysis of cropped images. The calculated center is used to estimate the original size
	forgedImages	//analysis of forged images. Outputs the calculated center for every window in the image
}E_analysisMode;




//////////////////////////////
// Globals

//this vector holds the IRG values for every (b,g) pair 
vector<irgInfo> irgPerIntensity (C_INTENSITY_LEVELS * C_INTENSITY_LEVELS); 





///////////////////////////////////////////////////////////////////////////////////////////////////////
// Description:
//
// This function runs the forgery detection algorithm proposed by Farid.
// Its main steps are:
//	1- read an image
//	2- generate blue and green histograms and the joint probability P(b,g)
//	3- calculate the probability that this is the best match between the 2 color channels
//
// These steps are repeated with various center locations and scaling factors to find the best match
// and thus pinpoint the image's center.
//
// Input:
//	The file containing the image to work on is set as a pre-compiler constant
//
// Restrictions:
//	Currently the code supports only BMP images
//
// Comments:
//	The EasyBMP package was taken from: http://easybmp.sourceforge.net 
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

int main(void)
{
	//debug flags
	bool saveWorkingImage = false; //defines if the working image should be saved to a file


	//general variables
	int i,j;
	const E_analysisMode analysisMode = regular;


	//rows, columns and center information
	int rowCenterOffset, colCenterOffset, imFirstRow, imFirstCol; //center offset, in pixels
	int minRowCntrShift, maxRowCntrShift, rowCntrShiftStep, minColCntrShift, maxColCntrShift, colCntrShiftStep;
	int rowIndex, colIndex;


	//NOTE: always use an EVEN VALUE here, to make sure that the geometric center of the image will be analyzed
	const int cntrsNumPerRowCol = 4; //the number(-1) of centers per each row and per each column. i.e: is the value here is 4, then the number of centers is (4+1)^2=25


	//scaling factor (alpha)
	double alphaScale;
	const double minApha = 99.226;
	const double maxApha = 99.960;
	const int numOfAlphaScales = 3;
	const double aphaStep = (maxApha-minApha) / (numOfAlphaScales-1);



	//open the log file (and clear it)
	const string folderName(C_WORKING_DIRECTORY);
	string debugSubDir("SW debug\\");
	const string logFileName("Log_file.txt");
	ofstream logFileHandle((folderName+debugSubDir+logFileName).c_str());

	if(logFileHandle.bad())
	{
		//report failure and exit
		cout << "Can't open result file: "<< (folderName+debugSubDir+logFileName)<< ". ABORTING!" << endl;
		return (-1);
	}

	//open the results file in append mode
	const string resultsFileName("Result_file.txt");
	ofstream resultsFileHandle(((folderName+resultsFileName).c_str()), ios_base::app);

	if(resultsFileHandle.bad())
	{
		//report failure and exit
		logFileHandle << "Can't open result file: "<< (folderName+resultsFileName)<< ". ABORTING!" << endl;
		return (-1);
	}
	switch (analysisMode)
	{
	case regular:
		resultsFileHandle <<endl<<endl<<endl<<endl<<"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"<<endl
			<< "The list below is ordered as follows:" << endl 
			<< "imageName ,center column index ,center row index ,center column ,center row ,maximal Irg ,alpha factor. " <<endl<<endl;

		resultsFileHandle << "Analysis type: regular" <<endl<<endl;

		//sanity check
		if (C_WINDOWS_PER_ROW_COL != 1)
		{
			logFileHandle << "Error: Regular analysis chosen with multiple windows analysis. ABORTING!" << endl;
			return (-1);
		}
		break;

	case croppedImages:
		resultsFileHandle <<endl<<endl<<endl<<endl<<"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"<<endl
			<< "The list below is ordered as follows:" << endl 
			<< "imageName ,center column index ,center row index ,center column ,center row ,maximal Irg ,alpha factor, sizeRatio, uncroppedImSize, cvrdSize, excessiveSize. " <<endl<<endl;

		resultsFileHandle << "Analysis type: croppedImages" <<endl<<endl;

		//sanity check
		if (C_WINDOWS_PER_ROW_COL != 1)
		{
			logFileHandle << "Error: cropped images analysis chosen with multiple windows analysis. ABORTING!" << endl;
			return (-1);
		}
		break;

	case forgedImages: 
		resultsFileHandle <<endl<<endl<<endl<<endl<<"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"<<endl
			<< "The list below is ordered as follows:" << endl 
			<< "imageName ,center column index ,center row index ,center column ,center row ,maximal Irg ,alpha factor, window col index, window row index. " <<endl<<endl;
		
		resultsFileHandle << "Analysis type: forgedImages" <<endl<<endl;
		
			//sanity check
		if (1 == C_WINDOWS_PER_ROW_COL)
		{
			logFileHandle << "Error: forged images analysis chosen with single window analysis. ABORTING!" << endl;
			return (-1);
		}
		break;

	default:
		//report failure and exit
		cout << "Unknown analysis type: "<< analysisMode << ". ABORTING!" << endl;
		return (-1);
	}

	const int numberOfCenters =(const int) pow((double)cntrsNumPerRowCol+1, 2);
	resultsFileHandle << "NOTE:"<< endl<<" THIS TEST CONTAINS: " << numberOfCenters <<" centers. "<<endl 
		<< "Other Parameters: minApha ="<<minApha<<", maxApha ="<<maxApha<<", numOfAlphaScales = "<<numOfAlphaScales
		<< endl<<endl;




	//////////////////////////////////////////////
	//run over the images listed in the input file

	//open the file for reading
	const string imagesFileName(C_IMAGES_FILE_NAME);
	ifstream imagesFileHandle((folderName+imagesFileName).c_str()); 

	if(imagesFileHandle.bad())
	{
		//report failure and exit	
		logFileHandle << "Can't open file: " << folderName+imagesFileName << ". ABORTING!" <<endl;
		return (-1);
	}

	string imageName;
	getline(imagesFileHandle,imageName, '\n');

	while(!imagesFileHandle.eof())
	{
		//global parameters that are reset every image
		vector<vector<double>>	curImageIrg(C_WINDOWS_PER_ROW_COL, vector<double>(C_WINDOWS_PER_ROW_COL, -10000));
		vector<vector<int>>		curImageCntrRow(C_WINDOWS_PER_ROW_COL, vector<int>(C_WINDOWS_PER_ROW_COL, -10000));
		vector<vector<int>>		curImageCntrCol(C_WINDOWS_PER_ROW_COL, vector<int>(C_WINDOWS_PER_ROW_COL, -10000));
		vector<vector<double>>	curImageAlpha(C_WINDOWS_PER_ROW_COL, vector<double>(C_WINDOWS_PER_ROW_COL, 0));
		vector<vector<int>>		curImageRowIndex(C_WINDOWS_PER_ROW_COL, vector<int>(C_WINDOWS_PER_ROW_COL, -1));
		vector<vector<int>>		curImageColIndex(C_WINDOWS_PER_ROW_COL, vector<int>(C_WINDOWS_PER_ROW_COL, -1));



		//read the image from the file
		BMP image;
		bool openSuccess = image.ReadFromFile((folderName+imageName).c_str());
		if (false == openSuccess)
		{
			//log the problem
			logFileHandle << "Unable to open image: " << (folderName+imageName) << endl;
			imagesFileHandle >> imageName; //try to get the next word - perhaps it will be better
			continue;
		}


		//load some parameters about the file
		const int imCols = image.TellWidth();
		const int imRows = image.TellHeight();
		const int colsPerWindow = (int)(imCols/C_WINDOWS_PER_ROW_COL);
		const int rowsPerWindow = (int)(imRows/C_WINDOWS_PER_ROW_COL);
		double pixelNumPerWindow = colsPerWindow * rowsPerWindow;
		const int wrapingRegion = max(imCols, imRows); //the number of pixels constituting a wrapping region around the original image
		const int discardPixelsSize = (int) (((100-minApha)/100)*2*(max(imCols, imRows))); //the number of pixels that are discarded from the edges of the image during the analysis



		//define the center searching region
		minRowCntrShift = -(imRows/2) + (imRows/cntrsNumPerRowCol); //dont start from the bottom row
		maxRowCntrShift =  (imRows/2) - (imRows/cntrsNumPerRowCol);
		rowCntrShiftStep = (maxRowCntrShift- minRowCntrShift) /cntrsNumPerRowCol ;
		minColCntrShift = -(imCols/2) + (imCols/cntrsNumPerRowCol); //dont start from the bottom col
		maxColCntrShift =  (imCols/2) - (imCols/cntrsNumPerRowCol);
		colCntrShiftStep = (maxColCntrShift- minColCntrShift) /cntrsNumPerRowCol ;

		//run over the different scales (alpha) and center locations
		for (alphaScale = minApha; alphaScale <= maxApha; alphaScale += aphaStep)
		{
			for(rowCenterOffset = minRowCntrShift, rowIndex=1; rowCenterOffset <= maxRowCntrShift; rowCenterOffset += rowCntrShiftStep, rowIndex++)
			{
				for(colCenterOffset = minColCntrShift, colIndex=1; colCenterOffset <= maxColCntrShift; colCenterOffset += colCntrShiftStep, colIndex++)
				{

					//shift the image (center shift)
					imFirstRow = wrapingRegion + rowCenterOffset;
					imFirstCol = wrapingRegion + colCenterOffset;
					BMP workingImage;
					workingImage.SetSize(imCols+(2*wrapingRegion), imRows+(2*wrapingRegion));
					RangedPixelToPixelCopy(image, 0 , imCols, 0, imRows,workingImage, imFirstCol , imFirstRow );

					//scale the BLUE CHANNEL of the image around the new center
					if (false == RescaleBlueChannel(workingImage , 'p', alphaScale) )
					{
						return (-1);
					}


					int winColIndex, winRowIndex;
					for (int windowFirstCol = imFirstCol+discardPixelsSize, winColIndex = 1; 
						winColIndex <= C_WINDOWS_PER_ROW_COL; 
						windowFirstCol += colsPerWindow, winColIndex++)
					{
						for (int windowFirstRow = imFirstRow+discardPixelsSize, winRowIndex = 1; 
							winRowIndex <= C_WINDOWS_PER_ROW_COL; 
							windowFirstRow += rowsPerWindow, winRowIndex++)
						{
							//reset the histograms and joint probability vectors
							vector<double> gHist(C_INTENSITY_LEVELS, 0); //init the vector with zeros
							vector<double> bHist(C_INTENSITY_LEVELS, 0);
							//a 2D matrix for the joint probability of G and B
							vector<vector<double> > bgJointProb ( C_INTENSITY_LEVELS, vector<double> ( C_INTENSITY_LEVELS, 0 ) );
							//reset the number of pixels in the window. Note it is reduced in the outliers removal process
							pixelNumPerWindow = colsPerWindow * rowsPerWindow;

							//calculate the limits of the current window 
							const int windowLastCol = windowFirstCol + colsPerWindow;
							const int windowLastRow = windowFirstRow + rowsPerWindow;

							//calculate the histogram and save the location of the pixels found on the way.
							//ignore the most outer pixels since the image size was slightly changed during the rescale process
							for (i = windowFirstCol; i<windowLastCol; i++)
							{
								for (j = windowFirstRow; j<windowLastRow; j++)
								{
									//update the histograms
									gHist[workingImage(i,j)->Green]++;
									bHist[workingImage(i,j)->Blue]++;

									//update the B/G values matrix P(b,g)
									bgJointProb[workingImage(i,j)->Blue][workingImage(i,j)->Green]++;
								}
							}



							if (saveWorkingImage)
							{
								char rowBuf[20], colBuf[20], alphaBuf[20];
								string imagePrefix("partialWorkingImage_");
								_itoa_s(rowIndex, rowBuf, 20, 10);
								_itoa_s(colIndex, colBuf, 20, 10);
								_itoa_s((int)(alphaScale*1000), alphaBuf, 20, 10);
								imagePrefix += rowBuf ;
								imagePrefix += "_";
								imagePrefix += colBuf;
								imagePrefix += "_";
								imagePrefix += alphaBuf;
								imagePrefix += "__";

								//save to a file the section we are working on
								BMP partialWorkingImage(workingImage);
								partialWorkingImage.SetSize(imCols, imRows);
								RangedPixelToPixelCopy(workingImage, 
									imFirstCol+discardPixelsSize , imCols+imFirstCol-discardPixelsSize, 
									imFirstRow+discardPixelsSize, imRows+imFirstRow-discardPixelsSize,
									partialWorkingImage, 0 , 0 );
								partialWorkingImage.WriteToFile((folderName+debugSubDir+imagePrefix+imageName).c_str());
							}


							
							double localIrg;
							//START OF THE OUTLIERS REMOVAL LOOP
							for (int outliersLoopCntr = 0; outliersLoopCntr < C_OUTLIERS_ITERATIONS_NUM; outliersLoopCntr++) 
							{
								double Pbg, PbPg, curPixNum, curIrg;
								
								//run the equation of Farid
								localIrg = 0;
								for (i = 0; i<C_INTENSITY_LEVELS; i++) //run over the BLUE histogram
								{
									for (j = 0; j<C_INTENSITY_LEVELS; j++) //run over the GREEN histogram
									{
										curPixNum = bgJointProb[i][j];
										Pbg = curPixNum / pixelNumPerWindow;
										PbPg = (bHist[i]/pixelNumPerWindow) * (gHist[j]/pixelNumPerWindow) ;
										if (0 != Pbg && 0 != PbPg)
										{
											curIrg = curPixNum * ( (Pbg) * log10(Pbg/PbPg) );
											localIrg += curIrg;

											//save the current IRG at the corresponding location in the vector 
											//so that outliers could be found and removed later
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].irgVal = curIrg;
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].gVal = j;
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].bVal = i;
										}
										else
										{
											//If there is not IRG calculation for these intensities, set an invalid value
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].irgVal = 0;
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].gVal = C_INTENSITY_LEVELS;
											irgPerIntensity[(i * C_INTENSITY_LEVELS) + j].bVal = C_INTENSITY_LEVELS;
										}
									}
								}

								//sort the IRG values. After the sorting the first element will have the lowest value and the last element the highest value
								sort (irgPerIntensity.begin(), irgPerIntensity.end(), irgSortPredicat);

								//Calculate the number of pixels that should be treated as outliers (from the top / bottom)
								const unsigned int outliersPixsToRemove = (unsigned int) (pixelNumPerWindow * C_OUTLIERS_PERCENTAGE);


								int pixsLeftToRmv, pixToRemoveAtCurStep;
								size_t outlierIndx;
								const size_t lastIndex = irgPerIntensity.size();

								////////////////////////////////////////////////////////////////////////
								//remove from the histograms the pixels which caused the lowest values
								for (outlierIndx = 0, pixsLeftToRmv = outliersPixsToRemove; (pixsLeftToRmv > 0) && (outlierIndx < lastIndex); outlierIndx++)
								{
									//run over valid entries only
									if (C_INTENSITY_LEVELS != irgPerIntensity[outlierIndx].gVal)
									{
										//The joint probability defines the minimum number of pixles that have these blue  
										//or green values, so this is the number pixels that will be removed
										pixToRemoveAtCurStep = (std::min) (bgJointProb[irgPerIntensity[outlierIndx].bVal][irgPerIntensity[outlierIndx].gVal], ((double)pixsLeftToRmv));

#ifdef DEBUG
										//Sanity checks
										if (0 == pixToRemoveAtCurStep)
										{
											logFileHandle << "No pixles to remove. Blue val= " << irgPerIntensity[outlierIndx].bVal << "Green val= "<< irgPerIntensity[outlierIndx].gVal <<". ABORTING!" <<endl;
											return (-1);
										}
										if ((bHist[irgPerIntensity[outlierIndx].bVal] < pixToRemoveAtCurStep) || 
											(gHist[irgPerIntensity[outlierIndx].gVal] < pixToRemoveAtCurStep) )
										{
											logFileHandle << "More pixels to remove than existing. pixToRemoveAtCurStep = " << pixToRemoveAtCurStep << 
												"blue pixs= "<< bHist[irgPerIntensity[outlierIndx].bVal] <<
												"green pixs= "<< gHist[irgPerIntensity[outlierIndx].gVal] << endl;
											return (-1);
										}

#endif //DEBUG

										bgJointProb[irgPerIntensity[outlierIndx].bVal][irgPerIntensity[outlierIndx].gVal] -= pixToRemoveAtCurStep;
										bHist[irgPerIntensity[outlierIndx].bVal] -= pixToRemoveAtCurStep;
										gHist[irgPerIntensity[outlierIndx].gVal] -= pixToRemoveAtCurStep;

										pixsLeftToRmv -= pixToRemoveAtCurStep;
									}// end of: valid value
								}// end of: remove lowest values

								//sanity check - verify that the required number of pixels have been removed
								if (pixsLeftToRmv > 0)
								{
									logFileHandle << "Could not remove required number of pixels (outliers). Unremoved: " << pixsLeftToRmv << "Required: "<< outliersPixsToRemove <<". ABORTING!" <<endl;
									return (-1);
								}


								////////////////////////////////////////////////////////////////////////
								//remove from the histograms the pixels which caused the higest values
								for (outlierIndx = lastIndex-1, pixsLeftToRmv = outliersPixsToRemove; (pixsLeftToRmv > 0) && (outlierIndx > 0); outlierIndx--)
								{
									//run over valid entries only
									if (C_INTENSITY_LEVELS != irgPerIntensity[outlierIndx].gVal)
									{
										//The joint probability defines the minimum number of pixles that have these blue  
										//or green values, so this is the number pixels that will be removed
										pixToRemoveAtCurStep = (std::min) (bgJointProb[irgPerIntensity[outlierIndx].bVal][irgPerIntensity[outlierIndx].gVal], ((double)pixsLeftToRmv));

#ifdef DEBUG
										//Sanity checks
										if (0 == pixToRemoveAtCurStep)
										{
											logFileHandle << "No pixles to remove. Blue val= " << irgPerIntensity[outlierIndx].bVal << "Green val= "<< irgPerIntensity[outlierIndx].gVal <<". ABORTING!" <<endl;
											return (-1);
										}
										if ((bHist[irgPerIntensity[outlierIndx].bVal] < pixToRemoveAtCurStep) || 
											(gHist[irgPerIntensity[outlierIndx].gVal] < pixToRemoveAtCurStep) )
										{
											logFileHandle << "More pixels to remove than existing. pixToRemoveAtCurStep = " << pixToRemoveAtCurStep << 
												"blue pixs= "<< bHist[irgPerIntensity[outlierIndx].bVal] <<
												"green pixs= "<< gHist[irgPerIntensity[outlierIndx].gVal] << endl;
											return (-1);
										}

#endif //DEBUG

										bgJointProb[irgPerIntensity[outlierIndx].bVal][irgPerIntensity[outlierIndx].gVal] -= pixToRemoveAtCurStep;
										bHist[irgPerIntensity[outlierIndx].bVal] -= pixToRemoveAtCurStep;
										gHist[irgPerIntensity[outlierIndx].gVal] -= pixToRemoveAtCurStep;

										pixsLeftToRmv -= pixToRemoveAtCurStep;
									}// end of: valid value
								}// end of: remove highest values

								//sanity check - verify that the required number of pixels have been removed
								if (pixsLeftToRmv > 0)
								{
									logFileHandle << "Could not remove required number of pixels (outliers). Unremoved: " << pixsLeftToRmv << "Required: "<< outliersPixsToRemove <<". ABORTING!" <<endl;
									return (-1);
								}



								//update the number of pixels in the window for the next iteration 
								pixelNumPerWindow -= (outliersPixsToRemove * 2); //outliersPixsToRemove are removed from the higest values and the same amount is removed from the olowest values

							} //END OF THE OUTLIERS REMOVAL LOOP

							


							if (localIrg > curImageIrg[winColIndex-1][winRowIndex-1])
							{
								//save the scaling and center locations , as this may become the global maxmim
								curImageIrg[winColIndex-1][winRowIndex-1]		= localIrg;
								curImageCntrRow[winColIndex-1][winRowIndex-1]	= rowCenterOffset;
								curImageCntrCol[winColIndex-1][winRowIndex-1]	= colCenterOffset;
								curImageColIndex[winColIndex-1][winRowIndex-1]	= colIndex; 
								curImageRowIndex[winColIndex-1][winRowIndex-1]	= rowIndex;
								curImageAlpha[winColIndex-1][winRowIndex-1]		= alphaScale;
							}


						}//end of: windowFirstRow loop
					}//end of: windowFirstCol loop


				}//end of: colCenterOffset loop
			} //end of: rowCenterOffset loop
		}//end of: alphaScale


		const int geoCntrRow = int(imRows/2);
		const int geoCntrCol = int(imCols/2);



		switch (analysisMode)
		{
		case croppedImages:
			{
				//analyze cropped images

				//get the absolute col and row of the center, without the wrapping region
				const int absCntrCol = geoCntrCol+curImageCntrCol[0][0];
				const int absCntrRow = geoCntrRow+curImageCntrRow[0][0];

				const double cropPercentage = 0.33333; //the part of rows (or cols) that was removed from the original image
				/*get the part of the image that was cropped based on its name
				and calculate the expected row and col of the original geometric
				center in the given (cropped) image*/
				double remainderPercentage = 1- cropPercentage;
				double remainderToOrgGeoCntr = 0.5 -cropPercentage;

				//sanity check- the original geometric center is always assumed to
				//be present in the cropped image as well
				if (remainderPercentage<0 || remainderToOrgGeoCntr<0)
				{
					logFileHandle << "Bad percentage calculation for cropped image: "<< imageName << ", remainderPercentage= "<< remainderPercentage<< ", remainderToOrgGeoCntr= "<<remainderToOrgGeoCntr<< endl;
					break;
				}

				//calculate the percentage of the shift of the original geometric center, in the cropped image
				double cntrShiftPercentage = remainderToOrgGeoCntr/remainderPercentage;

				//calculate the percentage of the removed rows/cols relative to the CROPPED IMAGE
				double rmvdSectionPercentage = cropPercentage/remainderPercentage;

				int expectedCntrCol, expectedCntrRow;
				unsigned int uncoveredCols,exceedingCols, uncoveredRows, exceedingRows;
				unsigned int uncroppedRowsNum, uncroppedColsNum;

				if (string::npos != imageName.find("Bottom"))
				{
					expectedCntrCol = geoCntrCol;
					expectedCntrRow = (int)((1-cntrShiftPercentage)*imRows);

					uncoveredCols = 0; //since the width has not changed, all the columns are always covered
					exceedingCols = abs(expectedCntrCol - absCntrCol)*2;//the number of cols that are out of the range of the un-cropped (original) image
					if (absCntrRow>= geoCntrRow)
					{
						uncoveredRows = max((expectedCntrRow-absCntrRow)*2, 0);//the number of rows of the original image that are un-covered
						exceedingRows = max((absCntrRow-expectedCntrRow)*2, 0);
					}
					else
					{
						uncoveredRows = (int)(rmvdSectionPercentage*imRows);//the entire section that was cropped is un-covered
						exceedingRows = (geoCntrRow - absCntrRow)*2;
					}

					//calc the size of the original (un-cropped) image
					uncroppedRowsNum = expectedCntrRow*2;
					uncroppedColsNum = expectedCntrCol*2;
				}
				else
				{
					if (string::npos != imageName.find("Top"))
					{
						expectedCntrCol = geoCntrCol;
						expectedCntrRow = (int)(cntrShiftPercentage*imRows);

						uncoveredCols = 0; //since the width has not changed, all the columns are always covered
						exceedingCols = abs(expectedCntrCol - absCntrCol)*2;//the number of cols that are out of the range of the un-cropped (original) image
						if (absCntrRow<= geoCntrRow)
						{
							uncoveredRows = max((absCntrRow-expectedCntrRow)*2, 0);//the number of rows of the original image that are un-covered
							exceedingRows = max((expectedCntrRow-absCntrRow)*2, 0);
						}
						else
						{
							uncoveredRows = (int)(rmvdSectionPercentage*imRows);//the entire section that was cropped is un-covered
							exceedingRows = (absCntrRow - geoCntrRow)*2;
						}

						//calc the size of the original (un-cropped) image
						uncroppedRowsNum = (imRows-expectedCntrRow)*2;
						uncroppedColsNum = expectedCntrCol*2;
					}
					else
					{
						if (string::npos != imageName.find("Left"))
						{
							expectedCntrCol = (int)(cntrShiftPercentage*imCols);
							expectedCntrRow = geoCntrRow;

							uncoveredRows = 0; //since the hight has not changed, all the rows are always covered
							exceedingRows = abs(expectedCntrRow - absCntrRow)*2;//the number of rows that are out of the range of the un-cropped (original) image
							if (absCntrCol<= geoCntrCol)
							{
								uncoveredCols = max((absCntrCol-expectedCntrCol)*2, 0);//the number of cols of the original image that are un-covered
								exceedingCols = max((expectedCntrCol-absCntrCol)*2, 0);
							}
							else
							{
								uncoveredCols = (int)(rmvdSectionPercentage*imCols);//the entire section that was cropped is un-covered
								exceedingCols = (absCntrCol - geoCntrCol)*2;
							}

							//calc the size of the original (un-cropped) image
							uncroppedRowsNum = expectedCntrRow*2;
							uncroppedColsNum = (imCols-expectedCntrCol)*2;
						}
						else
						{
							if  (string::npos != imageName.find("Right"))
							{
								expectedCntrCol = (int)((1-cntrShiftPercentage)*imCols);
								expectedCntrRow = geoCntrRow;

								uncoveredRows = 0; //since the hight has not changed, all the rows are always covered
								exceedingRows = abs(expectedCntrRow - absCntrRow)*2;//the number of rows that are out of the range of the un-cropped (original) image
								if (absCntrCol>= geoCntrCol)
								{
									uncoveredCols = max((expectedCntrCol-absCntrCol)*2, 0);//the number of cols of the original image that are un-covered
									exceedingCols = max((absCntrCol-expectedCntrCol)*2, 0);
								}
								else
								{
									uncoveredCols = (int)(rmvdSectionPercentage*imCols);//the entire section that was cropped is un-covered
									exceedingCols = (geoCntrCol - absCntrCol)*2;
								}

								//calc the size of the original (un-cropped) image
								uncroppedRowsNum = expectedCntrRow*2;
								uncroppedColsNum = expectedCntrCol*2;
							}
							else
							{
								logFileHandle << "Unable to anlyze name of image: "<< imageName << endl;
								break;
							}
						}
					}
				}

				////////////////////////////////////////////////////////////////////////
				//calculate the difference between the covered and exssesive
				//regions, and normalize by the size of the original (un-cropped) image

				unsigned int uncroppedImSize = uncroppedColsNum * uncroppedRowsNum;
				unsigned int uncoveredSize = (uncoveredCols*uncroppedRowsNum) + (uncoveredRows*uncroppedColsNum);
				//remove the region that was counted twice, if such exists
				uncoveredSize = uncoveredSize - (uncoveredCols*uncoveredRows);
				double cvrdSize = uncroppedImSize - uncoveredSize;

				//get the number of rows/cols of the un-cropped image, BASED ON THE
				//CALCULATED CENTER
				unsigned int imRowsBasedOnCalcCntr = max(absCntrRow, imRows-absCntrRow) * 2;
				unsigned int imColsBasedOnCalcCntr = max(absCntrCol, imCols-absCntrCol) * 2;
				unsigned int excessiveSize = (exceedingCols*imRowsBasedOnCalcCntr) + (exceedingRows*imColsBasedOnCalcCntr);
				//remove the region that was counted twice, if such exists
				excessiveSize = excessiveSize - (exceedingCols*exceedingRows);
				double sizeRatio = (cvrdSize)/(uncroppedImSize+excessiveSize);

				//save the results to a file
				resultsFileHandle <<imageName<<" ,"<<curImageColIndex[0][0]<<" ,"<<curImageRowIndex[0][0]<<" ,"<<absCntrCol<<" ,"
					<<absCntrRow<<" ,"<<curImageIrg[0][0]<<" ,"<<curImageAlpha[0][0] <<" ," << sizeRatio<<" ," << uncroppedImSize<<" ," 
					<<cvrdSize<<" ,"<<excessiveSize <<endl;
			}
			break;

		case regular:
			{
				//get the absolute col and row of the center, without the wrapping region
				const int absCntrCol = geoCntrCol+curImageCntrCol[0][0];
				const int absCntrRow = geoCntrRow+curImageCntrRow[0][0];

				//save the results to a file
				resultsFileHandle <<imageName<<" ,"<<curImageColIndex[0][0]<<" ,"<<curImageRowIndex[0][0]<<" ,"<<absCntrCol<<" ,"
					<<absCntrRow<<" ,"<<curImageIrg[0][0]<<" ,"<<curImageAlpha[0][0]<<endl;
			}
			break;

		case forgedImages:
			{
				//get the absolute col and row of the center, without the wrapping region
				int absCntrCol;
				int absCntrRow;
				//save the results to a file
				
				for (int winColIndex = 1; winColIndex <= C_WINDOWS_PER_ROW_COL; winColIndex++)
				{
					for (int winRowIndex = 1; winRowIndex <= C_WINDOWS_PER_ROW_COL; winRowIndex++)
					{
						//Sanity check
						if((-1) == curImageColIndex[winColIndex-1][winRowIndex-1] || 
						   (-1) == curImageRowIndex[winColIndex-1][winRowIndex-1])
						{
							//The algorithm did not update the result at all! report failure and exit	
							logFileHandle << "Algorithm failure! Image: " << imageName 
								<< ", winColIndex"<<winColIndex <<", winRowIndex"<<winRowIndex <<". ABORTING!" <<endl;
							return (-1);
						}

						
						absCntrCol = geoCntrCol+curImageCntrCol[winColIndex-1][winRowIndex-1];
						absCntrRow = geoCntrRow+curImageCntrRow[winColIndex-1][winRowIndex-1];
						resultsFileHandle <<imageName<<" ,"<<curImageColIndex[winColIndex-1][winRowIndex-1]<<" ,"<<curImageRowIndex[winColIndex-1][winRowIndex-1]<<
							" ,"<<absCntrCol<<" ," <<absCntrRow<<" ,"<<curImageIrg[winColIndex-1][winRowIndex-1]<<" ,"<<curImageAlpha[winColIndex-1][winRowIndex-1]<<
							", "<<winColIndex <<", "<<winRowIndex  <<endl;

					}
				}
			}
			break;

		default:
			//report failure and exit
			cout << "Unknown analysis type: "<< analysisMode << ". Unable to perform analysis. ABORTING!" << endl;
			return (-1);

		} //end of: switch analysisType

		
		//get the next image name from the file
		getline(imagesFileHandle,imageName, '\n');

	}//end of: imagesFileHandle.eof()


	//close the log file, results file and images names file
	logFileHandle.close();
	resultsFileHandle.close();
	imagesFileHandle.close();

}



//The following function is used as a predicat that allows sorting the irgInfo elements.
bool irgSortPredicat (irgInfo a,irgInfo b)
{
	return (a.irgVal < b.irgVal);
}