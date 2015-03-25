// Name: Align.m
// Description: Mex function to extract EMG Trajectories
// Authors: Meena AbdelMaseeh, Tsu-Wei Chen, and Daniel Stashuk
// Data: March 23, 2015 
# include "mex.h"
# include <math.h>
#include <list>
#include <iterator>
#include <vector>
#include <algorithm> 
using namespace std;
int DecodeMatlabIndices (int Row, int Column, int NumberOfRows)
{
	return (Row + Column*NumberOfRows); 
}
void TrajectoryExtraction(double* Signal ,int  SignalLen, int ChannelCount,double* ActiveThres, int MovingWindowLength, int MovingWindowThreshold, int MovingWindowNumActive,int LinkingMaxWait, int MinimalTrajectoryLength, list<int>* Onset, list<int>* EndPos)
{ 
	vector<short*> AuxiliaryBuffer(MovingWindowLength);
	short ThresholdMet = 0;
	int LinkingWait = 0;
	long TempOnset = -1; 
	long TempEndPos = -1; 
	long TempCandOnset = -1; 
	long TempCandEndPos = -1; 
	for (int i = 0; i < MovingWindowLength; i++)
	{
		short* AuxillaryPoint = (short*) malloc(ChannelCount * sizeof(short));
		for (int j = 0; j < ChannelCount; j++)
		{
			AuxillaryPoint[j] = 0;
		}
		AuxiliaryBuffer[i] = AuxillaryPoint;
	}
	for (int RowIndex = 0; RowIndex < SignalLen; RowIndex++)
	{
		short IsTrajectoryEnded = 0; 
		short* AuxillaryPoint = (short*) malloc(ChannelCount * sizeof(short));
		for (int ChannelIndex = 0; ChannelIndex < ChannelCount; ChannelIndex++)
		{
			if (Signal[DecodeMatlabIndices(RowIndex,ChannelIndex,SignalLen)] > ActiveThres[ChannelIndex])
			{
				AuxillaryPoint[ChannelIndex] = 1;
			}
			else
			{
				AuxillaryPoint[ChannelIndex] = 0;
			}
		}
		free(AuxiliaryBuffer[0]);
		AuxiliaryBuffer.erase(AuxiliaryBuffer.begin()); 
		AuxiliaryBuffer.push_back(AuxillaryPoint);
		int WindowValue = 0;
		for (int ChannelIndex = 0 ; ChannelIndex<ChannelCount;ChannelIndex++)
		{
			int NumOfActiveSamplesInChannel = 0;
			for (int AuxBufferIndex = 0 ; AuxBufferIndex<MovingWindowLength; AuxBufferIndex++)
			{
				if (*(AuxiliaryBuffer[AuxBufferIndex]+ChannelIndex) == 1)
				{
					NumOfActiveSamplesInChannel ++; 
				}
			}
			if (NumOfActiveSamplesInChannel > MovingWindowNumActive)
			{
				WindowValue++;
			}
		}
		if (LinkingWait == 0)
		{
			if (WindowValue > MovingWindowThreshold)
			{
				if (!ThresholdMet)
				{
					TempOnset = RowIndex; 
				}
				ThresholdMet = 1; 				
			}
			if (WindowValue < MovingWindowThreshold && ThresholdMet)
			{
				ThresholdMet = 0;
				TempEndPos = RowIndex;
				LinkingWait = LinkingMaxWait;
				TempCandOnset = RowIndex +1; 
			}
			else if (ThresholdMet)
			{
				TempEndPos = RowIndex;
			}
		}
		else
		{
			 LinkingWait --;
			 if (WindowValue <= MovingWindowThreshold)
			 {
				 TempCandEndPos = RowIndex;
			 }
			 if (LinkingWait == 1)
			 {
				 if((TempEndPos - TempOnset + 1) > MinimalTrajectoryLength)
				 {
					 IsTrajectoryEnded  = 1; 
				 }
				 else
				 {
					 TempOnset = -1; 
					 TempEndPos = -1; 
				 }
				 LinkingWait = 0; 
				 TempCandOnset = -1; 
				 TempCandEndPos = -1; 
			 }
			 if ( WindowValue > MovingWindowThreshold && LinkingWait > 1 )
			 {
				 ThresholdMet = 1;
				 TempEndPos = RowIndex;
				 LinkingWait = 0; 
				 TempCandOnset = -1; 
				 TempCandEndPos = -1; 
			 }
		}
		if (IsTrajectoryEnded)
		{
			Onset->push_back(TempOnset); 
			EndPos->push_back(TempEndPos); 
			TempOnset = -1;
			TempEndPos = -1; 
			TempCandOnset = -1; 
			TempCandEndPos = -1; 
		}
	}
	if (TempOnset != -1)
	{
		if((TempEndPos - TempOnset + 1) > MinimalTrajectoryLength)
		{
			Onset->push_back(TempOnset); 
			EndPos->push_back(TempEndPos); 
		}
	}
	for (int i = 0; i < MovingWindowLength; i++)
	{
		free(AuxiliaryBuffer[i]);
	}
}

void mexFunction(int nlhs, mxArray *plhs [], 
        int nrhs , const mxArray *prhs[])
{
	/*
	0 - CPPSignal
	1- CPPSignalLen
	2- CPPChannelCount
	3- CPPActiveThres
	4- CPPMovingWindowLength
	5- CPPMovingWindowThreshold
	6- CPPMovingWindowNumActive
	7- CPPLinkingMaxWait
	8- CPPMinimalTrajectoryLength);
	*/
	double* Signal; 
	int		SignalLen;
	double  ChannelCount; 
	double * ActiveThres;
	double MovingWindowLength; 
	double MovingWindowThreshold; 
	double MovingWindowNumActive; 
	double LinkingMaxWait; 
	double MinimalTrajectoryLength; 
	Signal = mxGetPr(prhs[0]); 
	SignalLen = (int) mxGetScalar(prhs[1]);
	ChannelCount = mxGetScalar(prhs[2]); 
	ActiveThres = mxGetPr(prhs[3]);
	MovingWindowLength = mxGetScalar(prhs[4]); 
	MovingWindowThreshold= mxGetScalar(prhs[5]); 
	MovingWindowNumActive= mxGetScalar(prhs[6]); 
	LinkingMaxWait= mxGetScalar(prhs[7]); 
	MinimalTrajectoryLength= mxGetScalar(prhs[8]); 
	list<int> Onset;
	list<int> EndPos; 
	TrajectoryExtraction(Signal ,  SignalLen, ChannelCount, ActiveThres, MovingWindowLength,  MovingWindowThreshold,  MovingWindowNumActive, LinkingMaxWait,  MinimalTrajectoryLength, &Onset, &EndPos);
	list<int>::const_iterator iterator;
	list<int>::const_iterator iteratorEndPos;
	double* ResOnsets; 
	double* ResEndPos;
	plhs[0] = mxCreateDoubleMatrix(1,Onset.size() ,mxREAL);
	plhs[1] = mxCreateDoubleMatrix(1,EndPos.size() ,mxREAL);
	ResOnsets = mxGetPr (plhs[0]);
	ResEndPos = mxGetPr (plhs[1]);
	int i;
	for (iterator = Onset.begin(),iteratorEndPos = EndPos.begin(),  i = 0; iterator != Onset.end(); ++iterator,++iteratorEndPos, i++) 
	{
		ResOnsets[i] = *iterator;
		ResEndPos [i] = *iteratorEndPos;
	}
}
