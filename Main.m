clear;
clc;
%Image Requirements: 
% 1) The images must be properly exposed
% 2) The images must not have noticable vignetting. 
% 3) The samples must be in the center of the image with at about 1/20 of the image on either side filled with skin
% 4) The sample should be not be covered by hair as this throws off segmentation.
% 5) The images must not have watermarks.

%Run the program. Pick the default parameters or input your own. 

    DermLogo = 1;
    TrimCorners = 0;
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
    
prompt = {'Remove Derm Logo?','Trim Image corners?', 'Sample width ratio:', ...
    'Sample height ratio:', 'Skin sample width ratio:', 'Skin sample height ratio:', 'Blob Cutoff from largest blob:', ...
    'Shaping factor for sterel (morphological op.):', 'Unwrapping depth for gradients [0,1):', 'Roughness metric:', ...
    'Texture sample height ratio:', 'Texture sample width ratio:', 'Entropy filter neighborhood (odd value):', ...
    'Number of color cluster centroids: ', 'Number of maximum separate identified lesions to take:', ...
    'Length of gradient vectors: ', 'Size of entropy filtered sample in pixels:' };
dlg_title = 'Input';
num_lines = 1;
defaultans = {'yes','no', '1/5', '1/5', '1/4', '1/20', '1/12', '1/100', '0.9', '40', '1/5', '1/5', '9', '5', '4', '500', '50'};
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




%Image input

dirlist = dir('Melanoma');
for i=3:size(dirlist,1)
    if ~strcmp(dirlist(i).name, 'Thumbs.db') 
        im = imread(['Melanoma\' dirlist(i).name]);
        if size(im,1) > size(im, 2)
            im = imrotate(im, 90);
        end
        [MelanomaVectors(i-2, :), Images(i-2)] = ExtractFeatures( im, DermLogo, TrimCorners, SampleWidthR, SampleHeightR, ...
        SkinWidthR, SkinHeightR, BlobCutOff, ShapeFactor, UnWrapDepth, RoughVal, TextureSampleSizeR, TextureSampleSizeC, ...
        TextureEntropyNeighborhood, ColorClusterSize, NumberToTake, GradientVarLength, EntropyFiltSize);
    end
end

dirlist2 = dir('NotMel');
for i=3:size(dirlist2,1)
    if ~strcmp(dirlist2(i).name, 'Thumbs.db') 
        im = imread(['NotMel\' dirlist2(i).name]);
        if size(im,1) > size(im, 2)
            im = imrotate(im, 90);
        end
        [NotMelVectors(i-2, :), Images2(i-2)] = ExtractFeatures( im, DermLogo, TrimCorners, SampleWidthR, SampleHeightR, ...
        SkinWidthR, SkinHeightR, BlobCutOff, ShapeFactor, UnWrapDepth, RoughVal, TextureSampleSizeR, TextureSampleSizeC, ...
        TextureEntropyNeighborhood, ColorClusterSize, NumberToTake, GradientVarLength, EntropyFiltSize);
    end
end

%printing

% for i = 1:size(dirlist,1)-2
%     
%     figure('name',strcat('Mel ', num2str(i)));
%     subplot(1,3,1);
%     imshow(Images(i).im);
%     
%     subplot(1,3,2);
%     imshow(Images(i).WorkBlockMask);
%     
% %     descr = {strcat('SymX Error: ',
% %     num2str(MelanomaVectors(i).SymErrorBinaryX)); strcat('SymY Error: ',
% %     num2str(MelanomaVectors(i).SymErrorBinaryY)); strcat('R: ',
% %     num2str(MelanomaVectors(i).Roughness)); strcat('No. of components: ',
% %     num2str(MelanomaVectors(i).NoOfComponents)); strcat('AvgColor: ',
% %     num2str(MelanomaVectors(i).AvgColor)); };
% %    
% %     h2 = subplot(1,3,3); imshow(ones(1,1)); text(0.5,0.7,descr, 'Parent',
% %     h2)
% end
% 
% for i = 1:size(dirlist2,1)-2
%     
%     figure('name',strcat('NotMel ', num2str(i)));
%     subplot(1,3,1);
%     imshow(Images2(i).im);
%     
%     subplot(1,3,2);
%     imshow(Images2(i).WorkBlockMask);
% %     
% %     descr = {strcat('SymX Error: ',
% %     num2str(NotMelVectors(i).SymErrorBinaryX)); strcat('SymY Error: ',
% %     num2str(NotMelVectors(i).SymErrorBinaryY)); strcat('R: ',
% %     num2str(NotMelVectors(i).Roughness)); strcat('No. of components: ',
% %     num2str(NotMelVectors(i).NoOfComponents)); strcat('AvgColor: ',
% %     num2str(NotMelVectors(i).AvgColor)); };
% % 
% %     h2 = subplot(1,3,3); imshow(ones(1,1)); text(0.5,0.7,descr, 'Parent',
% %     h2)
% end

NDIM = 100;

TempCombined = [MelanomaVectors; NotMelVectors];
[RESIDUALS,RECONSTRUCTED] = pcares(TempCombined,NDIM);

MelanomaVectors = RECONSTRUCTED(1:size(MelanomaVectors,1), 1:NDIM);
NotMelVectors = RECONSTRUCTED(size(MelanomaVectors,1)+1:end, 1:NDIM);

MelanomaVectors = [MelanomaVectors ones(size(MelanomaVectors,1), 1)];
NotMelVectors = [NotMelVectors zeros(size(NotMelVectors,1), 1)];



MelanomaVectorsTraining = MelanomaVectors(1:floor(size(MelanomaVectors, 1)*0.9),:);
MelanomaVectorsValidation = MelanomaVectors(ceil(size(MelanomaVectors, 1)*0.9):end,:);

NotMelVectorsTraining = NotMelVectors(1:floor(size(NotMelVectors, 1)*0.9),:);
NotMelVectorsValidation = NotMelVectors(ceil(size(NotMelVectors, 1)*0.9):end,:);

FinalVecTraining = [MelanomaVectorsTraining; NotMelVectorsTraining];
FinalVecValidation = [MelanomaVectorsValidation; NotMelVectorsValidation];

FinalVecTrainingShuffled = FinalVecTraining(randperm(end),:);
FinalVecValidationShuffled = FinalVecValidation(randperm(end),:);

dlmwrite('Training.txt',FinalVecTrainingShuffled,' ');
dlmwrite('Validation.txt',FinalVecValidationShuffled,' ');

%%save('FeatureVectors.mat', 'MelanomaVectors', 'NotMelVectors');





