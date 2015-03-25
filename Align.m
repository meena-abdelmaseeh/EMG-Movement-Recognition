function [Score Alignment] = Align(S, T, SubstitutionMatrix, LinearGapScore)
n = length(S);
m = length(T);
ScoreMatrix = zeros(n+1,m+1);
AlignmentLengthMatrix = ones(n+1,m+1);
DirectionMatrix = zeros(n+1,m+1);
for i = 1:n
    ScoreMatrix(i+1,1) = LinearGapScore * i;
    AlignmentLengthMatrix(i+1,1) = 1 + i;
    DirectionMatrix(i+1,1) = 2;
end
for j = 1:m
    ScoreMatrix(1,j+1) = LinearGapScore * j;
    AlignmentLengthMatrix(1,j+1) = 1 + j;
    DirectionMatrix(1,j+1) = 3;
end
for i = 1:n
    for j = 1:m
        DiagonalScore = SubstitutionMatrix(S(i),T(j)) + ScoreMatrix(i,j);
        VerticalScore = LinearGapScore + ScoreMatrix(i,j+1);
        HorizontalScore = LinearGapScore + ScoreMatrix(i+1,j);
        [Value Index] = max([DiagonalScore VerticalScore HorizontalScore]);
        ScoreMatrix(i+1,j+1) = Value;
        PrevLength = 0;
        if (Index == 1)
            PrevLength = AlignmentLengthMatrix(i,j);
            DirectionMatrix(i+1,j+1) = 1;
        elseif (Index == 2)
            PrevLength = AlignmentLengthMatrix(i,j+1);
            DirectionMatrix(i+1,j+1) = 2;
        else
            PrevLength = AlignmentLengthMatrix(i+1,j);
            DirectionMatrix(i+1,j+1) = 3;
        end
        AlignmentLengthMatrix(i+1,j+1) = 1 + PrevLength;
    end
end
i = n+1;
j = m+1;
Score = ScoreMatrix(i,j);
AlignmentLength = AlignmentLengthMatrix(i,j);
Alignment = zeros(AlignmentLength,2);
for k = AlignmentLength:-1:1
    Alignment(k,:) = [i j];
    if (DirectionMatrix(i,j) == 1)
        i = i - 1;
        j = j - 1;
    elseif (DirectionMatrix(i,j) == 2)
        i = i - 1;
    else
        j = j - 1;
    end
end
end