% Name: ConstructTrainTestMatrices.m
% Description: Divide the data into training and testing trials
% Authors: Meena AbdelMaseeh, Tsu-Wei Chen, and Daniel Stashuk
% Data: March 23, 2015 

function [TestingGestureTrialMatrix,TrainingGestureTrialMatrix] =  ConstructTrainTestMatrices(RawGestureTrialMatrix)
NumOfGestures = length(unique(cell2mat(RawGestureTrialMatrix(:,1)))) - 1;
TestingGestureTrialMatrix = cell(0); 
% 1st column: label, 2nd column: RMS data, 3rd column: channel-normalized
% signal
TrainingGestureTrialMatrix = cell(0); 
TrialLabels = cell2mat(RawGestureTrialMatrix(:,1)); 
NoOfRepetitions = 6; 
TestingMatrixIndex = 1; 
TrainingMatrixIndex =1; 
for i = 1:NumOfGestures
    CurrGestureIndices = find(TrialLabels == i );
    for j = 1:NoOfRepetitions
        if j == 4 || (i==1 && j ==1)
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j)-1,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j) ,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)+1,1}; 
            FollowingRestRaw = RawGestureTrialMatrix {CurrGestureIndices(j)+1,4}; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,2} =  FollowingRestRaw (1:floor(length(FollowingRestRaw)/2),:); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
        elseif j == 3 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)-1,1}; 
            PrevRest = RawGestureTrialMatrix {CurrGestureIndices(j)-1,4}; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,2} =  PrevRest (floor(length(PrevRest)/2)+1:end,:); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j) ,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
        elseif i == NumOfGestures && j == NoOfRepetitions
            TrainingGestureTrialMatrix {TrainingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)-1,1};
            PrevRest = RawGestureTrialMatrix {CurrGestureIndices(j)-1,4}; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,2} =  PrevRest (floor(length(PrevRest)/2)+1:end,:); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j) ,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j)+1 ,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
        elseif j ==2 || j == 5
            TestingGestureTrialMatrix {TestingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)-1,1};
            PrevRest = RawGestureTrialMatrix {CurrGestureIndices(j)-1,4}; 
            TestingGestureTrialMatrix {TestingMatrixIndex,2} =  PrevRest (floor(length(PrevRest)/2)+1:end,:); 
            TestingMatrixIndex = TestingMatrixIndex +1; 
            TestingGestureTrialMatrix (TestingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j) ,[1,4]); 
            TestingMatrixIndex = TestingMatrixIndex +1; 
            TestingGestureTrialMatrix {TestingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)+1,1}; 
            FollowingRestRaw = RawGestureTrialMatrix {CurrGestureIndices(j)+1,4}; 
            TestingGestureTrialMatrix {TestingMatrixIndex,2} =  FollowingRestRaw (1:floor(length(FollowingRestRaw)/2),:); 
            TestingMatrixIndex = TestingMatrixIndex +1; 
        else
            TrainingGestureTrialMatrix {TrainingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)-1,1};
            PrevRest = RawGestureTrialMatrix {CurrGestureIndices(j)-1,4}; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,2} =  PrevRest (floor(length(PrevRest)/2)+1:end,:); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix (TrainingMatrixIndex,:) = RawGestureTrialMatrix (CurrGestureIndices(j) ,[1,4]); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,1} =  RawGestureTrialMatrix {CurrGestureIndices(j)+1,1}; 
            FollowingRestRaw = RawGestureTrialMatrix {CurrGestureIndices(j)+1,4}; 
            TrainingGestureTrialMatrix {TrainingMatrixIndex,2} =  FollowingRestRaw (1:floor(length(FollowingRestRaw)/2),:); 
            TrainingMatrixIndex = TrainingMatrixIndex +1; 
        end
    end
end
end
