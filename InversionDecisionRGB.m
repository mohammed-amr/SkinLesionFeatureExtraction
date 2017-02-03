function [ Invert ] = InversionDecisionRGB( im, ClusterCenters, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR  )
%INVERSIONDECISION 
%   This function checks the edges of the image and compares it to the
%   middle. It figures out which one is lighter and throws back a decisin
%   on whether ot not to invert the image.
%calculating average sample intensity

[sizeX, sizeY, ~] = size(im);

SampleHeight = SampleHeightR*sizeX;
SampleWidth = SampleWidthR*sizeY;
SampleSquare = im( (sizeX-SampleHeight)/2:(sizeX+SampleHeight)/2, (sizeY-SampleWidth)/2:(sizeY+SampleWidth)/2 , :);
SampleAverage = mean(mean(SampleSquare));
SampleAverage = [SampleAverage(1,1,1) SampleAverage(1,1,2) SampleAverage(1,1,3)]; 

%calculating average skin intensity
SkinWidth = floor(SkinWidthR*sizeY);
SkinHeight = floor(SkinHeightR*sizeX);
UpperSkin = im( 1:SkinHeight, (sizeY-SkinWidth)/2:(sizeY+SkinWidth)/2, :);
LowerSkin = im( sizeX-SkinHeight:sizeX, (sizeY-SkinWidth)/2:(sizeY+SkinWidth)/2, :);

%inverted for sides (X and Y length)
SkinWidth = floor(SkinHeightR*sizeY);
SkinHeight = floor(SkinWidthR*sizeX);
RSideSkin = im( (sizeX-SkinHeight)/2:(sizeX+SkinHeight)/2, sizeY-SkinWidth:sizeY, :);
LSideSkin = im( (sizeX-SkinHeight)/2:(sizeX+SkinHeight)/2, 1:SkinWidth, :);

UpperAverage = mean(mean(UpperSkin));
LowerAverage = mean(mean(LowerSkin));
RSideAverage = mean(mean(RSideSkin));
LSideAverage = mean(mean(LSideSkin));
SkinAverage = mean([UpperAverage LowerAverage RSideAverage LSideAverage]);
SkinAverage = [SkinAverage(1,1,1) SkinAverage(1,1,2) SkinAverage(1,1,3)]; 

%Get cluster errors for skin. 
ClusterOneError = sqrt(sum( (SkinAverage - ClusterCenters(1, :)).^2 ));
ClusterTwoError = sqrt(sum( (SkinAverage - ClusterCenters(2, :)).^2 ));

%Decision

if ClusterOneError < ClusterTwoError
    Invert = 0;
else
    Invert = 1;
end


end

