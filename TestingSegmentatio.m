clear;
clc;
%pctRunOnAll warning off;
%Main batch script. This script takes in images from the ISIC dataset and
%processes them one by one. The output is saved as raw vectors in
%workspace. Use WriteToFiles to save these vectors to text file. 
%NOTE: Do NOT run this unless you expect to leave it running for more than
%12 hours. Matlab will become unresponsive while it runs. To test out the
%feature extractor, use the Tester.m script instead.

%Main.m is a deprecated function for handling images taken directly from a
%normal folder (not in ISIC format).


%Image Requirements: 
% 1) The images must be properly exposed
% 2) The images must not have noticable vignetting. 
% 3) The samples must be in the center of the image with at least about 1/20 of the image on either side filled with skin
% 4) The sample should be not be covered by hair as this throws off segmentation.
% 5) The images must not have watermarks.

%% Feature extraction paramters

%Run the program. Pick the default parameters or input your own. 

    DermLogo = 0;
    TrimCorners = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SampleWidthR = 1/5; 
    SampleHeightR = 1/5;
    SkinWidthR = 1/4; %think of upper and lower boxes
    SkinHeightR = 1/20;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %secondary, tertiary... blob area limit: 
    BlobCutOff = 1/12;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %shaping factor for sterel
    ShapeFactor = 1/100;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %unwrap depth
    UnWrapDepth = 0.9; % [0,1) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RoughVal = 40;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TextureSampleSizeR = 1/5;
    TextureSampleSizeC = 1/5;
    TextureEntropyNeighborhood = 9; %MUST BE ODD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ColorClusterSize = 5;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NumberToTake = 4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    GradientVarLength = 500;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EntropyFiltSize = 50;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HairFactor = 3/100;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    minCutOff = 0.02;
    maxCutOff = 0.81;
    
prompt = {'Remove Derm Logo?','Trim Image corners?', 'Sample width ratio:', ...
    'Sample height ratio:', 'Skin sample width ratio:', 'Skin sample height ratio:', 'Blob Cutoff from largest blob:', ...
    'Shaping factor for sterel (morphological op.):', 'Unwrapping depth for gradients [0,1):', 'Roughness metric:', ...
    'Texture sample height ratio:', 'Texture sample width ratio:', 'Entropy filter neighborhood (odd value):', ...
    'Number of color cluster centroids: ', 'Number of maximum separate identified lesions to take:', ...
    'Length of gradient vectors: ', 'Size of entropy filtered sample in pixels:', 'HairFactor:', 'minCutOff', 'maxCutOff'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'no','yes', '1/5', '1/5', '1/4', '1/20', '1/12', '1/100', '0.9', '40', '1/5', '1/5', '9', '5', '4', '500', '50', '3/100', '2/100', '81/100'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    if strcmp(cell2mat(answer(1)), 'yes')
        DermLogo = 1;
    else
        DermLogo = 0;
    end
    if strcmp(cell2mat(answer(2)), 'yes')
        TrimCorners = 1;
    else
        TrimCorners = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SampleWidthR = eval(cell2mat(answer(3)));
    SampleHeightR = eval(cell2mat(answer(4)));
    SkinWidthR = eval(cell2mat(answer(5)));
    SkinHeightR = eval(cell2mat(answer(6)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %secondary, tertiary... blob area limit: 
    BlobCutOff = eval(cell2mat(answer(7)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %shaping factor for sterel
    ShapeFactor = eval(cell2mat(answer(8)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %unwrap depth
    UnWrapDepth = eval(cell2mat(answer(9))); % [0,1) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RoughVal = eval(cell2mat(answer(10)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TextureSampleSizeR = eval(cell2mat(answer(11)));
    TextureSampleSizeC = eval(cell2mat(answer(12)));
    if mod(eval(cell2mat(answer(13))), 2) ~= 0 
        TextureEntropyNeighborhood = eval(cell2mat(answer(13)));
    else
        error('Even neighborhood value used!');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ColorClusterSize = eval(cell2mat(answer(14)));
    NumberToTake = eval(cell2mat(answer(15)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    GradientVarLength = eval(cell2mat(answer(16)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EntropyFiltSize = eval(cell2mat(answer(17)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Image and labels input from the ISIC dataset
CSVFile = readtable('ISIC.csv');
j = 1;
k = 1;

MelList(1).Name = 'dummy';
NotMelList(1).Name = 'dummy';

%getting file list.
for i = 1:height(CSVFile)
    if CSVFile{i,2} == 1
        if exist(['ISIC\'  char(CSVFile{i,1}) '.jpg'], 'file') == 2
            MelList(end+1).Name = ['ISIC\'  char(CSVFile{i,1}) '.jpg'];
        end
    end
end

for i = 1:height(CSVFile)
    if CSVFile{i,2} == 0 && CSVFile{i,3} == 0 
        if exist(['ISIC\'  char(CSVFile{i,1}) '.jpg'], 'file') == 2
            NotMelList(end+1).Name = ['ISIC\'  char(CSVFile{i,1}) '.jpg'];
        end
    end
end

%NOTE: Both for loops are parallel for loops, meaning they start a paralell
%processing pool in MATLAB. Multiple threads of MATLAB are instantiated and
%used to execute iterations in parallel. This greatly reduces processing
%time.

%running feature extraction for Melanoma samples
for i=2:size(MelList, 2)
    im = imread(MelList(i).Name);
    %MelList(i).Name
    if size(im,1) > size(im, 2)
        im = imrotate(im, 90);
    end
    try
        [AllBlobsMask, RoughSegment, im] = SegmentLesion(im, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR, ShapeFactor, HairFactor, minCutOff, maxCutOff);
        subplot(1,2, 1);
        imshow(im);
        subplot(1,2,2);
        imshow(uint8(AllBlobsMask*255));
    catch ME
        msgText = getReport(ME)
        continue;
    end
end
save('SecondRun1.mat', '-v7.3');

%running feature extraction for non melanoma samples
for i=2:401
    try
        im = imread(NotMelList(i).Name);
        %NotMelList(i).Name
    catch
        continue;
    end
    
    if size(im,1) > size(im, 2)
        im = imrotate(im, 90);
    end
    try
        [AllBlobsMask, RoughSegment, im] = SegmentLesion(im, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR, ShapeFactor, HairFactor, minCutOff, maxCutOff);
        subplot(1,2, 1);
        imshow(im);
        subplot(1,2,2);
        imshow(uint8(AllBlobsMask*255));
    catch ME
        msgText = getReport(ME)
        continue;
    end
end

%% Optional PCA reconstruction. No need to worry about this now.
% NDIM = 100;
% 
% TempCombined = [MelanomaVectors; NotMelVectors];
% [RESIDUALS,RECONSTRUCTED] = pcares(TempCombined,NDIM);
% 
% MelanomaVectors = RECONSTRUCTED(1:size(MelanomaVectors,1), 1:NDIM);
% NotMelVectors = RECONSTRUCTED(size(MelanomaVectors,1)+1:end, 1:NDIM);


%%save('FeatureVectors.mat', 'MelanomaVectors', 'NotMelVectors');


save('SecondRun2.mat', '-v7.3');


