function [AvgColor ColorVariance ClusterCentroids] = FindColorParam(im, WorkBlockMask, ColorClusterSize)
%FINDCOLORPARAM 
%   This function gets the average color of the blobs, the variance of the
%   RGB values, and a few (ahem) color centroids using kmeans. Color
%   Centroids basically represent the average colors in the image.
%   Detailed explanation goes here
cutout = uint8(double(im).*repmat(WorkBlockMask,[1,1,3]));
RedSum = sum(sum(cutout(:,:,1)));
GreenSum = sum(sum(cutout(:,:,2)));
BlueSum = sum(sum(cutout(:,:,3)));

RedAvg = RedSum/sum(sum(WorkBlockMask));
GreenAvg = GreenSum/sum(sum(WorkBlockMask));
BlueAvg = BlueSum/sum(sum(WorkBlockMask));
AvgColor = [RedAvg GreenAvg BlueAvg];


RVals = im(:,:,1);
RVals = double(RVals(WorkBlockMask));

GVals = im(:,:,2);
GVals = double(GVals(WorkBlockMask));

BVals = im(:,:,3);
BVals = double(BVals(WorkBlockMask));

[idx, ClusterCentroids] = kmeans([RVals GVals BVals], ColorClusterSize, 'EmptyAction', 'singleton');

RG = cov(RVals, GVals);
RB = cov(RVals, BVals);
GB = cov(GVals, BVals);

ColorVariance = [RG(1,1) GB(1,1) RB(1,1);
                 RG(1,2) GB(1,2) RB(1,2)];


end

