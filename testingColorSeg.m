clear; 
clc;

dirlist = dir('Melanoma');
%for i=3:size(dirlist,1)
    %if ~strcmp(dirlist(i).name, 'Thumbs.db') 
        %he = imread(['Melanoma\' dirlist(i).name]);
        SampleWidthR = 1/5; 
        SampleHeightR = 1/5;
        SkinWidthR = 1/4; 
        SkinHeightR = 1/20;
        ShapeFactor = 2/100;
        HairFactor = 3/100;
        minCutOff = 0.02;
        maxCutOff = 0.81;
        
        for i=1:25

            tic;
            im = imread(['m' num2str(i) '.jpg']);

            [AllBlobsMask, RoughSegment] = SegmentLesion(im, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR, ShapeFactor, HairFactor, minCutOff, maxCutOff);
            toc;

            figure;
            subplot(1,3,1);
            imshow(im);
            subplot(1,3,2);
            imshow(RoughSegment);
            subplot(1,3,3);
            imshow(AllBlobsMask);
        end

        
    %end
%end 


