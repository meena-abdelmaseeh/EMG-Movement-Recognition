
% Name: FindStdDevFactor.m
% Description: Find the standard Dev Factor
% Authors:Meena AbdelMaseeh, Tsu-Wei Chen, and Daniel Stashuk
% Data: March 23, 2015 
function StdFactor  = FindStdDevFactor (TrainingGestureTrialMatrix,TrainingMeanRMSValues,TrainingStdRMSValues)
	global Settings;
    Settings = ExperimentFileReader('Configuration.exp');
    Inertia = str2double(Settings('Inertia'));
    LinkingMaxWait = ceil(Inertia/2);
    MinimalTrajectoryLength = ceil(Inertia/2);
    MovingWindowLength =str2double(Settings('MovingWindowLength'));
    MovingWindowThreshold = str2double(Settings('MovingWindowThreshold'));
    MovingWindowNumActive = str2double(Settings('MovingWindowNumActive'));
    UpperLimitForStd =  str2double(Settings('UpperLimitForStd'));
    Labels = cell2mat(TrainingGestureTrialMatrix(:,1));
    NoOfGesturesInTheTraining = length(find(Labels > 0)); 
    NoOfRestInTheTraining = length(find(Labels == 0)); 
    NumTrials = size(TrainingGestureTrialMatrix,1);
    StdFactor = -1;
    NumChannels = size(TrainingGestureTrialMatrix{1,3},2);
    CurStdDevFactors = zeros(1,NumChannels);
    NumChannelToSearch = NumChannels;
    AllCriteria = zeros(NumChannelToSearch+1,UpperLimitForStd,3);
    StoredStdFactor = []; 
    TrainingLabels = cell2mat(TrainingGestureTrialMatrix(:,1)); 
    Indices = find(TrainingLabels ~= 0);
    TrueSampleLabel = [];
    for i = 1:size(TrainingGestureTrialMatrix,1)
        TrueSampleLabel = [TrueSampleLabel ;(TrainingGestureTrialMatrix{i,1}>0)* ones(size(TrainingGestureTrialMatrix{i,2},1),1)];
    end
    TrajDuringNonRestSampleLabel = zeros(size(TrueSampleLabel));
    TrajDuringRestSampleLabel = zeros(size(TrueSampleLabel)); 
    for SearchIteration  = 1:(NumChannelToSearch+1)
        NumRestConfusedAsActive = zeros(UpperLimitForStd,1);
        NumActiveConfusedAsRest =zeros(UpperLimitForStd,1);
        NumActiveHasMoreThanOneActive =zeros(UpperLimitForStd,1);
        for k = 1:UpperLimitForStd
            skip = 0; 
            for i = 1:NumTrials 
                if skip == 1
                    skip = 0; 
                    continue ; 
                end
                GestureName = TrainingGestureTrialMatrix{i,1};
                MultiChannelTrajectory = TrainingGestureTrialMatrix{i,3};
                CurrentSampleIndex = 0;
                for m = 1:i-1
                    CurrentSampleIndex = CurrentSampleIndex +size(TrainingGestureTrialMatrix{m,2},1); 
                end
                if (GestureName ~= 0)
                    % For the fourth repetition(the one preceeded by a whole rest), we should only concatenate the later half to avoid potential labeling problems due to mislabeling the the end of the third repetion
                    MultiChannelTrajectory = [TrainingGestureTrialMatrix{i-1,3}; TrainingGestureTrialMatrix{i,3}; TrainingGestureTrialMatrix{i+1,3}];
                    CurrentSampleIndex = 0;
                    for m = 1:i-2
                        CurrentSampleIndex = CurrentSampleIndex +size(TrainingGestureTrialMatrix{m,2},1); 
                    end
                else
                    if i+1 <= NumTrials
                        NextGestureName =  TrainingGestureTrialMatrix{i+1,1};
                        if NextGestureName == 0
                            MultiChannelTrajectory = [TrainingGestureTrialMatrix{i,3}; TrainingGestureTrialMatrix{i+1,3}];
                            skip = 1; 
                        end
                    end
                end
                Onsets = [];
                EndPoss = [];
                % Initialization of trajectory extraction algorithm for a given
                % trial
                MeanRMSValues = TrainingMeanRMSValues;         
                StdRMSValues = TrainingStdRMSValues; 
                IsActive = 0;
                ActiveChannelsArray = zeros(size(MultiChannelTrajectory)); 
                StdFactor = [];  
                if (SearchIteration == 1)
                    StdFactor = k*ones(1,size(MultiChannelTrajectory,2));
                elseif (SearchIteration == 2)
                    StdFactor = CurStdDevFactors;
                    StdFactor(9) = k;
                elseif (SearchIteration == 3)
                    StdFactor = CurStdDevFactors;
                    StdFactor(10) = k;
                elseif (SearchIteration == 4)
                    StdFactor = CurStdDevFactors;
                    StdFactor(11) = k;
                elseif (SearchIteration == 5)
                    StdFactor = CurStdDevFactors;
                    StdFactor(12) = k;
                elseif (SearchIteration == 6)
                    StdFactor = CurStdDevFactors;
                    StdFactor(1) = k;
                elseif (SearchIteration == 7)
                    StdFactor = CurStdDevFactors;
                    StdFactor(2) = k;
                elseif (SearchIteration == 8)
                    StdFactor = CurStdDevFactors;
                    StdFactor(3) = k;
                elseif (SearchIteration == 9)
                    StdFactor = CurStdDevFactors;
                    StdFactor(4) = k;
                elseif (SearchIteration == 10)
                    StdFactor = CurStdDevFactors;
                    StdFactor(5) = k;
                elseif (SearchIteration == 11)
                    StdFactor = CurStdDevFactors;
                    StdFactor(6) = k;
                elseif (SearchIteration == 12)
                    StdFactor = CurStdDevFactors;
                    StdFactor(7) = k;
                elseif (SearchIteration == 13)
                    StdFactor = CurStdDevFactors;
                    StdFactor(8) = k;
                end
         
                SignalLen =  size(MultiChannelTrajectory,1);
                ChannelCount = size(MultiChannelTrajectory,2);
                ActiveThres = (MeanRMSValues + StdFactor'.*StdRMSValues)./MeanRMSValues;
                [Onsets, EndPoss] = FindTrajectories (MultiChannelTrajectory, SignalLen, ChannelCount, ActiveThres, MovingWindowLength, MovingWindowThreshold,MovingWindowNumActive, LinkingMaxWait,MinimalTrajectoryLength);
                if (length(Onsets)>0)
                    IsActive = 1; 
                end
                if TrainingGestureTrialMatrix{i,1} == 0
                    for mn = 1:length(Onsets)
                        TrajDuringRestSampleLabel(Onsets(mn)+CurrentSampleIndex:EndPoss(mn)+CurrentSampleIndex) = 1; 
                    end
                else
                    for mn = 1:length(Onsets)
                        TrajDuringNonRestSampleLabel(Onsets(mn)+CurrentSampleIndex:EndPoss(mn)+CurrentSampleIndex) = 1; 
                    end
                end
                if TrainingGestureTrialMatrix{i,1} == 0
                    if IsActive
                        if length(Onsets) >= 3
                            NumRestConfusedAsActive(k) =  NumRestConfusedAsActive(k)+1;
                        elseif length(Onsets) == 2
                            if ~(Onsets(1) < (2 * MovingWindowLength) && EndPoss(end) >( (size(MultiChannelTrajectory,1) - 2 * MovingWindowLength)))
                                NumRestConfusedAsActive(k) =  NumRestConfusedAsActive(k)+1;
                            end
                        elseif length(Onsets) == 1
                            cond1 =Onsets(1) < 2*MovingWindowLength; 
                            cond2 = EndPoss(1) > (size(MultiChannelTrajectory,1) - 2*MovingWindowLength); 
                            if ((~cond1)&(~cond2))||((cond1)&(cond2))
                                NumRestConfusedAsActive(k) =  NumRestConfusedAsActive(k)+1;
                            end
                        end
                    end
                else
                    if ~IsActive
                        NumActiveConfusedAsRest(k) =  NumActiveConfusedAsRest(k)+1;
                    end
                    if IsActive && length( Onsets)>1
                        NumActiveHasMoreThanOneActive (k) = NumActiveHasMoreThanOneActive(k) +1; 
                    end
                end
            end
            StoredStdFactor = [StoredStdFactor; StdFactor];
            AllCriteria(SearchIteration,k,:)= [NumRestConfusedAsActive(k),NumActiveConfusedAsRest(k),NumActiveHasMoreThanOneActive(k)];
        end
        Criteria = NumRestConfusedAsActive /NoOfRestInTheTraining + NumActiveConfusedAsRest/NoOfGesturesInTheTraining +NumActiveHasMoreThanOneActive/NoOfGesturesInTheTraining;
        [Val Ind] = min(Criteria);
        IndicesOfSmallestValues = find(Criteria == Val);
        LoosestIndex = IndicesOfSmallestValues(end);
        StdFactor = 1*(LoosestIndex - Ind)/2 + Ind;
        if (SearchIteration == 1)
            CurStdDevFactors = StdFactor * ones(1,NumChannels);
        elseif (SearchIteration == 2)
            CurStdDevFactors(9) = StdFactor;
        elseif (SearchIteration == 3)
            CurStdDevFactors(10) = StdFactor;
        elseif (SearchIteration == 4)
            CurStdDevFactors(11) = StdFactor;
        elseif (SearchIteration == 5)
            CurStdDevFactors(12) = StdFactor;
        elseif (SearchIteration == 6)
            CurStdDevFactors(1) = StdFactor;
        elseif (SearchIteration == 7)
            CurStdDevFactors(2) = StdFactor;
        elseif (SearchIteration == 8)
            CurStdDevFactors(3) = StdFactor;
        elseif (SearchIteration == 9)
            CurStdDevFactors(4) = StdFactor;
        elseif (SearchIteration == 10)
            CurStdDevFactors(5) = StdFactor;
        elseif (SearchIteration == 11)
            CurStdDevFactors(6) = StdFactor;
        elseif (SearchIteration == 12)
            CurStdDevFactors(7) = StdFactor;
        elseif (SearchIteration == 13)
            CurStdDevFactors(8) = StdFactor;
        end
    end
    StdFactor = CurStdDevFactors;
end
