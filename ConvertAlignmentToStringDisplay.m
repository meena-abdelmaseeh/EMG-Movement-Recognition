function [AlignmentDisplay] = ConvertAlignmentToStringDisplay(NumericS, NumericT, SubstitutionMatrix, Symbols, Alignment)
AlignmentLength = size(Alignment,1);
AlignmentDisplay1 = '';
AlignmentDisplay2 = '';
PrevP1 = 0;
PrevP2 = 0;
for k = 1:AlignmentLength
    AlignedP1 = Alignment(k,1) - 1;
    AlignedP2 = Alignment(k,2) - 1;
    AlignedChar1 = '';
    AlignedChar2 = '';
    if (AlignedP1 == 0 || AlignedP1 == PrevP1)
        AlignedChar1 = '-';
    else
        AlignedChar1 = Symbols(NumericS(AlignedP1));
    end
    if (AlignedP2 == 0 || AlignedP2 == PrevP2)
        AlignedChar2 = '-';
    else
        AlignedChar2 = Symbols(NumericT(AlignedP2));
    end
    AlignmentDisplay1(k) = AlignedChar1;
    AlignmentDisplay2(k) = AlignedChar2;
    PrevP1 = AlignedP1;
    PrevP2 = AlignedP2;
end
AlignmentDisplay = [AlignmentDisplay1(2:end); AlignmentDisplay2(2:end)];
end