function ProcessedData =  PreprocessRMSWithLessComputation(Data, WindowSize)
NoOfChannels  = size(Data,2); 
NoOfSamples = size(Data,1); 
ProcessedData = zeros(size(Data));
for i = 1:NoOfChannels
    ChannelData = Data(:,i);
    PrevProcessedPoint = -1;
    for j = 1: NoOfSamples
        if (j <=WindowSize)
            UsedWindowSize = j;
            ProcessedData(j,i) =  mean(ChannelData(j:-1:j-UsedWindowSize+1).^2);
        else 
            UsedWindowSize = WindowSize;
            ProcessedData(j,i) =  PrevProcessedPoint + (ChannelData(j).^2 - ChannelData(j-WindowSize).^2)/WindowSize;
        end
        PrevProcessedPoint = ProcessedData(j,i);
    end
end 
ProcessedData = sqrt(ProcessedData);
end 