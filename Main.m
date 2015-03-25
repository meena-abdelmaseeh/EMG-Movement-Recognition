%% Prepare the work space 
clc; 
clearvars; 
close all;
clear global Settings;

%% Read the Settings 
global Settings;
Settings = ExperimentFileReader('Configuration.exp');
DatabaseLocation = Settings('DatabaseLocation');
Inertia = str2num(Settings('Inertia'));
LinkingMaxWait = ceil(Inertia/2);
MinimalTrajectoryLength = ceil(Inertia/2);
InitialDecimationFactor = str2num(Settings('InitialDecimationFactor'));
CutOffFrequency = str2double(Settings('CutOffFrequency'));
SampleFrequency = str2double(Settings('SampleFrequency'));
DecimatedSampleFrequency = SampleFrequency / InitialDecimationFactor;
FilterOrder = str2double(Settings('FilterOrder'));
DecimationFactor = str2double(Settings('DecimationFactor'));
RMSWindowLength = str2double(Settings('RMSWindowLength'));
MovingWindowLength =str2double(Settings('MovingWindowLength'));
MovingWindowThreshold = str2double(Settings('MovingWindowThreshold'));
MovingWindowNumActive = str2double(Settings('MovingWindowNumActive'));

%% Design Highpass Filter 
[BHPF,AHPF] = butter(FilterOrder,2*CutOffFrequency/DecimatedSampleFrequency,'high');

%% Load the Data
[UpperPath, SubjectFolder, ~] = fileparts(DatabaseLocation);
FileName = [upper(SubjectFolder) '_E1_A1.mat'];
FileLocation = fullfile(DatabaseLocation,FileName); 
load(FileLocation);
emg_E1 = emg;
restimulus_E1 = restimulus;
stimulus_E1 = stimulus;
FileName = [upper(SubjectFolder) '_E2_A1.mat'];
FileLocation = fullfile(DatabaseLocation,FileName); 
load(FileLocation);
emg = [emg_E1; emg];
restimulus = [restimulus_E1; restimulus];
stimulus = [stimulus_E1; stimulus];
NumChannels = size(emg,2);

%% Decimate the emg signal 
DecimatedEMG = zeros(ceil(size(emg,1)/InitialDecimationFactor),size(emg,2));
for j = 1:size(emg,2)
    DecimatedEMG(:,j) = decimate(double(emg(:,j)),InitialDecimationFactor);
end
DecimatedRestimulus = restimulus(1:InitialDecimationFactor:end); %restimulus(1:InitialDecimationFactor:end);

%% Apply Highpass Filter
FilteredEMG = filter(BHPF, AHPF, DecimatedEMG);

%% Apply RMS window
RMSEMG = PreprocessRMSWithLessComputation(FilteredEMG, RMSWindowLength);

%% Construct the Gesture Trial Matrix 
% 1st column: label, 2nd column: raw data, 3rd column: high pass filtered
% data, 4th column: RMS data
Temp = diff(DecimatedRestimulus);
Indices = find(Temp ~= 0);
Indices = cat(1,Indices,length(DecimatedRestimulus)); 
TrueGestureSequence = DecimatedRestimulus(Indices);
RawGestureTrialMatrix = cell(1,3);
NumTrials = length(Indices);
CurrentIndex = 1;
for i = 1:NumTrials
    RawGestureTrialMatrix{i,1} = TrueGestureSequence(i);
    RawGestureTrialMatrix{i,2} = DecimatedEMG(CurrentIndex:Indices(i),:);
    RawGestureTrialMatrix{i,3} = FilteredEMG(CurrentIndex:Indices(i),:);
    RawGestureTrialMatrix{i,4} = RMSEMG(CurrentIndex:Indices(i),:);
    CurrentIndex = Indices(i)+1;
end

%% Construct Training and Testing Gesture Matrices
[TestingGestureTrialMatrix,TrainingGestureTrialMatrix] =  ConstructTrainTestMatrices(RawGestureTrialMatrix);
% TestingGestureTrialMatrix,TrainingGestureTrialMatrix:: 1st column: label, 2nd column: RMS data, 3rd column: channel-normalized
% signal

%% Training: Estimate the mean and standard deviation of Rest Activation-Level Signals
NumTrials = size(TrainingGestureTrialMatrix,1);
AppendedMultiChannelRestSignal = []; 
AppendedMultiChannelNonRestSignal = [];
for i = 1:NumTrials
    GestureName = TrainingGestureTrialMatrix{i,1};
    if GestureName == 0
        MultiChannelSignal = TrainingGestureTrialMatrix{i,2};
        AppendedMultiChannelRestSignal = [AppendedMultiChannelRestSignal; MultiChannelSignal];
    else
        MultiChannelSignal = TrainingGestureTrialMatrix{i,2};
        AppendedMultiChannelNonRestSignal = [AppendedMultiChannelNonRestSignal; MultiChannelSignal];
    end
end
PercentForRestStat = 0.6; 
for ij = 1:size(AppendedMultiChannelRestSignal,2)
    SortedChannelVals = sort(AppendedMultiChannelRestSignal(:,ij),'Ascend'); 
    KeepPercent = floor(PercentForRestStat*size(AppendedMultiChannelRestSignal,1));
    TrainingMeanRMSValues(ij,1) = mean(SortedChannelVals(1:KeepPercent));
    TrainingStdRMSValues(ij,1) = std(SortedChannelVals(1:KeepPercent));
end
for i = 1:NumTrials
    MultiChannelSignal = TrainingGestureTrialMatrix{i,2};
    for j = 1:size(MultiChannelSignal,2)
        MultiChannelSignal(:,j) = MultiChannelSignal(:,j)./TrainingMeanRMSValues(j);
    end
    TrainingGestureTrialMatrix{i,3} = MultiChannelSignal;
end

%% Training: Find the std Deviation Factor
StdFactor  = FindStdDevFactor (TrainingGestureTrialMatrix,TrainingMeanRMSValues,TrainingStdRMSValues);
  
%% Training: Extract trajectories for the training database
TrainingTrajectoryDatabase = cell(0);
TrueTrainingTrajectoryLabels = [];
ExtractedTrainingTrajectoryLabels= [];
SeparationBetTrajOfTrial = cell(0); 
Counter = 1;
GestureCounter = 1;
StoredIndex = 1;
for i = 1:NumTrials 
    GestureName = TrainingGestureTrialMatrix{i,1};
    MultiChannelTrajectory = TrainingGestureTrialMatrix{i,3};
    if (GestureName ~= 0) 
        % For the fourth repetition(the one preceeded by a whole rest), we should only concatenate the later half to avoid potential labeling problems due to mislabeling the the end of the third repetion
        MultiChannelTrajectory = [TrainingGestureTrialMatrix{i-1,3}; TrainingGestureTrialMatrix{i,3}; TrainingGestureTrialMatrix{i+1,3}];
        TrueTrainingTrajectoryLabels = [TrueTrainingTrajectoryLabels;zeros(size(TrainingGestureTrialMatrix{i-1,3},1),1);ones(size(TrainingGestureTrialMatrix{i,3},1),1) ;zeros(size(TrainingGestureTrialMatrix{i+1,3},1),1)];
        Onsets = [];
        EndPoss = [];
        MeanRMSValues = TrainingMeanRMSValues; 
        StdRMSValues = TrainingStdRMSValues; 
        IsActive = 0;
        Signal = MultiChannelTrajectory; 
        SignalLen =  size(MultiChannelTrajectory,1);
        ChannelCount = size(MultiChannelTrajectory,2);
        ActiveThres = (MeanRMSValues + StdFactor'.*StdRMSValues)./MeanRMSValues;
        [Onsets, EndPoss] = FindTrajectories (Signal, SignalLen, ChannelCount,...
           ActiveThres,MovingWindowLength,MovingWindowThreshold,MovingWindowNumActive, LinkingMaxWait,MinimalTrajectoryLength);
        IsActive =1; 
        CurrExtractedTrainingTrajectoryLabels = zeros(size(MultiChannelTrajectory,1),1) ;
        if isempty(Onsets)
            IsActive = 0;
        end
        if IsActive
            for jj = 1:length(Onsets)
                CurrExtractedTrainingTrajectoryLabels(Onsets(jj):EndPoss(jj)) =1;
            end
            [Value Index] = max(EndPoss - Onsets);
            TrainingTrajectoryDatabase{StoredIndex,1} = GestureName;
            TrainingTrajectoryDatabase{StoredIndex,2} = MultiChannelTrajectory(Onsets(Index):EndPoss(Index),:);
            StoredIndex = StoredIndex + 1;
        end
        ExtractedTrainingTrajectoryLabels = [ExtractedTrainingTrajectoryLabels;CurrExtractedTrainingTrajectoryLabels];
        GestureCounter = GestureCounter + 1;
    end
end
for i = 1:size(TrainingTrajectoryDatabase,1)
    Temp = [];
    CurData = TrainingTrajectoryDatabase{i,2};
    for j = 1:size(CurData,2)
        Temp = [Temp decimate(CurData(:,j),DecimationFactor)];
    end
    TrainingTrajectoryDatabase{i,3} = Temp;
end

%% Testing: Construct testing signal
TestingSignal = [];
TestingLabels = [];
SampleTestingLabels = [];
TrialNumberSamples = [];
for i = 1:size(TestingGestureTrialMatrix,1)
    TestingSignal = [TestingSignal; TestingGestureTrialMatrix{i,2}];
    TestingLabels = [TestingLabels; TestingGestureTrialMatrix{i,1}];
    SampleTestingLabels = [SampleTestingLabels; double(TestingGestureTrialMatrix{i,1}) * ones(size( TestingGestureTrialMatrix{i,2},1),1) ];
    TrialNumberSamples = [TrialNumberSamples; i * ones(size( TestingGestureTrialMatrix{i,2},1),1)];
end

%% Testing: Trajectory Extraction
Trajectory = [];
TrajectorySamples = zeros(1,size(TestingSignal,1)); 
MatchedDatabaseTrajectoryIndices = zeros(1,size(TestingSignal,1)); 
LabelSet = [];
LinkingWait = 0; 
CandidateTraj = [];
Reset =1;
TrajectoryIndex = 0;
MeanRMSValuesMatrix = repmat(MeanRMSValues',size(TestingSignal,1),1);
TestingSignal = TestingSignal./MeanRMSValuesMatrix;
Signal = TestingSignal; 
SignalLen =  size(TestingSignal,1);
ChannelCount = size(TestingSignal,2);
ActiveThres = (MeanRMSValues + StdFactor'.*StdRMSValues)./MeanRMSValues;
[TestOnsets, TestEndPoss] = FindTrajectories (Signal, SignalLen, ChannelCount,...
    ActiveThres, MovingWindowLength, MovingWindowThreshold,MovingWindowNumActive, LinkingMaxWait,MinimalTrajectoryLength);

%%  Testing: DTW matching
for i = 1:length(TestOnsets)
    Trajectory = TestingSignal(TestOnsets(i):TestEndPoss(i),:);
    BestSoFar = inf;
    BestSoFarIndex = -1;
    DecimatedTrajectory = [];
    for j = 1:size(Trajectory,2)
        DecimatedTrajectory(:,j) = decimate(Trajectory(:,j), DecimationFactor);
    end
    for p = 1:size(TrainingTrajectoryDatabase,1)
        TrainingData =   TrainingTrajectoryDatabase{p,3};
        [Dist, k] = DTW(DecimatedTrajectory, ...
            TrainingData);
        if (Dist) < BestSoFar
            BestSoFar =  Dist;
            BestSoFarIndex = p;
        end
    end
    Label = TrainingTrajectoryDatabase(BestSoFarIndex,1);
    LabelSet = [LabelSet; Label];
    TrajectorySamples(1,TestOnsets(i):TestEndPoss(i)) = cell2mat(Label);
    MatchedDatabaseTrajectoryIndices(1,TestOnsets(i):TestEndPoss(i)) = BestSoFarIndex;
end

%% Testing: MER
TrueSequence = [];
TrueSequence (1) = TestingLabels(1); 
CountSoFar = size(TestingGestureTrialMatrix{1,2},1);
for i = 2:length(TestingLabels)
    if TestingLabels (i) ~= TrueSequence(end)
        TrueSequence = [TrueSequence; TestingLabels(i)];
    end
    CountSoFar = CountSoFar +size(TestingGestureTrialMatrix{i,2},1);
end
TestSequence = [0];
TestPredictedOnsets = [0]; 
for i = 1:length(LabelSet)
    TestSequence = [TestSequence; LabelSet{i}; 0];
end
Symbols = ''; 
Symbols(1) =' ';
for i =66 :105
    Symbols(i-65+1) =char(i) ;%'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
end
NumSymbols = length(Symbols);
SubstitutionMatrix = [];
MatchScore = 0;
MismatchScore = -1;
LinearGapScore = -1;
TestSequence = TestSequence + 1;
TrueSequence = TrueSequence + 1;
SubstitutionMatrix = eye(NumSymbols) * (MatchScore - MismatchScore) + MismatchScore;
[Score Alignment] = Align(TrueSequence, TestSequence, SubstitutionMatrix, LinearGapScore);
AlignmentDisplay = ConvertAlignmentToStringDisplay(TrueSequence, TestSequence, SubstitutionMatrix, Symbols, Alignment);
LevenshteinDistance = -Score;
MER = LevenshteinDistance/length(TrueSequence);