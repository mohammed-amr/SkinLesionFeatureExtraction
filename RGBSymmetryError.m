function [ ErrorX, ErrorY ] = RGBSymmetryError( Im, mask)
%RGBSYMMETRYERROR This function takes an RGB image, Im, and calculates the
%square error of the pixels along the axes X and Y. 0,0,0 pixels are
%ignored. IM should already be cutout. Mask is the mask of the object in
%question.
%   Detailed explanation goes here
[sizeX sizeY sizeZ] = size(Im);

%%%Horizontal Symmetry 
if(mod(sizeX,2) == 0)
    FirstHalf = Im(1:sizeX/2,:,:);
    SecondHalf = Im(sizeX:-1:(sizeX/2)+1,:,:);
    FirstMask = mask(1:sizeX/2,:,:);
    SecondMask = mask(sizeX:-1:(sizeX/2)+1,:,:);
else
    FirstHalf = Im(1:floor(sizeX/2),:,:);
    SecondHalf = Im(sizeX:-1:floor(sizeX/2)+2,:,:);
    FirstMask = mask(1:floor(sizeX/2),:,:);
    SecondMask = mask(sizeX:-1:floor(sizeX/2)+2,:,:);
end
UnionMask = or(FirstMask, SecondMask);  
Area = sum(sum(UnionMask))*2;

Diff = FirstHalf - SecondHalf;
% figure;
% imshow(uint8(abs(Diff)));
Diff = Diff./255;
ErrorX = sum(sum( sqrt( double((Diff(:,:,1).^2) + (Diff(:,:,2).^2) + (Diff(:,:,3).^2)) ) ))/Area;


%%%Vertical Symmetry 
if(mod(sizeY,2) == 0)
    FirstHalf = Im(:,1:sizeY/2,:);
    SecondHalf = Im(:,sizeY:-1:(sizeY/2)+1,:);
    FirstMask = mask(:,1:sizeY/2,:);
    SecondMask = mask(:,sizeY:-1:(sizeY/2)+1,:);
else
    FirstHalf = Im(:,1:floor(sizeY/2),:);
    SecondHalf = Im(:,sizeY:-1:floor(sizeY/2)+2,:);
    FirstMask = mask(:,1:floor(sizeY/2),:);
    SecondMask = mask(:,sizeY:-1:floor(sizeY/2)+2,:);
end
UnionMask = or(FirstMask, SecondMask);  
Area = sum(sum(UnionMask))*2;

Diff = FirstHalf - SecondHalf;
% figure;
% imshow(uint8(abs(Diff)));
Diff = Diff./255;
ErrorY = sum(sum( sqrt( double((Diff(:,:,1).^2) + (Diff(:,:,2).^2) + (Diff(:,:,3).^2)) ) ))/Area;



end

