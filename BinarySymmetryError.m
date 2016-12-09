function [ ErrorX, ErrorY ] = BinarySymmetryError( Im )
%BinarySymmetryError This function takes a binary image, Im, and calculates the
%square error of the pixels along the axes X and Y. IM should already be 
%cutout.
% Detailed explanation goes here
[sizeX sizeY sizeZ] = size(Im);

%%%Horizontal Symmetry 
if(mod(sizeX,2) == 0)
    FirstMask = Im(1:sizeX/2,:);
    SecondMask = Im(sizeX:-1:(sizeX/2)+1,:);
else
    FirstMask = Im(1:floor(sizeX/2),:);
    SecondMask = Im(sizeX:-1:floor(sizeX/2)+2,:);
end
UnionMask = or(FirstMask, SecondMask);  
Area = sum(sum(UnionMask))*2;



Diff = (FirstMask - SecondMask);
ErrorX = sum(sum( sqrt( double(Diff.^2) ) ) )/Area;

%%%Vertical Symmetry 
if(mod(sizeY,2) == 0)
    FirstMask = Im(:,1:sizeY/2);
    SecondMask = Im(:,sizeY:-1:(sizeY/2)+1);
else
    FirstMask = Im(:,1:floor(sizeY/2));
    SecondMask = Im(:,sizeY:-1:floor(sizeY/2)+2);
end
UnionMask = or(FirstMask, SecondMask);  
Area = sum(sum(UnionMask))*2;

Diff = (FirstMask - SecondMask);
ErrorY = sum(sum( sqrt( double(Diff.^2) ) ) )/Area;

end

