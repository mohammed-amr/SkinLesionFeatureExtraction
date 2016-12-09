function [ Invert ] = InversionDecision( imgray, sizeX, sizeY, sizeZ, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR  )
%INVERSIONDECISION Summary of this function goes here
%   Detailed explanation goes here
%calculating average sample intensity
SampleHeight = SampleHeightR*sizeX;
SampleWidth = SampleWidthR*sizeY;
SampleSquare = imgray( (sizeX-SampleHeight)/2:(sizeX+SampleHeight)/2, (sizeY-SampleWidth)/2:(sizeY+SampleWidth)/2 );
SampleAverage = mean(mean(SampleSquare));

%calculating average skin intensity
SkinWidth = floor(SkinWidthR*sizeY);
SkinHeight = floor(SkinHeightR*sizeX);
UpperSkin = imgray( 1:SkinHeight, (sizeY-SkinWidth)/2:(sizeY+SkinWidth)/2 );
LowerSkin = imgray( sizeX-SkinHeight:sizeX, (sizeY-SkinWidth)/2:(sizeY+SkinWidth)/2 );

%inverted for sides (X and Y length)
SkinWidth = floor(SkinHeightR*sizeY);
SkinHeight = floor(SkinWidthR*sizeX);
RSideSkin = imgray( (sizeX-SkinHeight)/2:(sizeX+SkinHeight)/2, sizeY-SkinWidth:sizeY);
LSideSkin = imgray( (sizeX-SkinHeight)/2:(sizeX+SkinHeight)/2, 1:SkinWidth);

UpperAverage = mean(mean(UpperSkin));
LowerAverage = mean(mean(LowerSkin));
RSideAverage = mean(mean(RSideSkin));
LSideAverage = mean(mean(LSideSkin));
SkinAverage = mean([UpperAverage LowerAverage RSideAverage LSideAverage]);

%Decision
if SampleAverage > SkinAverage
    Invert = 0;
else
    Invert = 1;
end


end

