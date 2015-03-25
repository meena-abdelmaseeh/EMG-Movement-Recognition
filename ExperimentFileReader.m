function ExperimentSettings =  ExperimentFileReader (FilePath)
fid = fopen(FilePath); 
tline = fgets(fid);
ExperimentSettings = containers.Map;
while ischar(tline)
    % This pattern needs to be improved
    DelimiterExpr = '(\s=\s)|(;)'; 
    [ matstr] = regexpi(tline, DelimiterExpr,...
        'split');
    % The split always returns an extra item
    if size(matstr,2) == 3
        ExperimentSettings(matstr{1}) = matstr{2}; 
    else 
       error(strcat('Wrong Settings line',tline));
    end 
    tline = fgets(fid);
end
fclose(fid);
end 
