function [ FinalVector, Images ] = ExtractFeatures( im, DermLogo, TrimCorners, SampleWidthR, SampleHeightR, ...
    SkinWidthR, SkinHeightR, BlobCutOff, ShapeFactor, UnWrapDepth, RoughVal, TextureSampleSizeR, TextureSampleSizeC, ...
    TextureEntropyNeighborhood, ColorClusterSize, NumberToTake, GradientVarLength, EntropyFiltSize)
 
    %The big almighty function. This function takes as input the image and
    %a few (ahem) feature extraction parameters. 
    %It extracts the following features:
    
    %ColorVarMatrix: contains variance values for the three color channels.
    
    %AvgColor: Average color in RGB space. 
    
    %ClusterCentroids: Color centroid in RGB from kmeans 
    
    %SymErrorBinaryX: error in the best symmetry achieved through the
    %X-axis
    
    %SymErrorBinaryY: same as SymErrorBinaryX but applies to the
    %corresponding Y axis
    
    %SymErrorRGBX: error in the best symmetry achieved through the
    %X-axis, RGB
    
    %SymErrorRGBY: same as SymErrorBinaryX but applies to the
    %corresponding Y axis, RGB
    
    %SymErrorGrayScaleX: error in the best symmetry achieved through the
    %X-axis
    
    %SymErrorBinaryY: same as SymErrorBinaryX but applies to the
    %corresponding Y axis
    
    %GradientChangeAvg: Average value of gradient inwards from the
    %perimeter 
    
    %GradientChangeVar: Variance of gradient inwards from the perimeter
    
    %CoOcMatrix: Coocurance matrix for a sample of the lesion
    
    %CoOcMatrixProp: Properties of the CoOcurance matrix.
    
    %SampleEntropy: Resized and scaled entropy filtered segment of the
    %legion
    
    %Roughness: Value of the edge roughness of rhe lesion
    
    %NoOfComponents: No of components found within the cutoff threshold.
    
    %The comments here use the word blob a lot to represent part of the
    %lesion.
    
    %% Basic Image Processing
    [sizeX, sizeY, sizeZ] = size(im); 

    %clipping the dermotology watermark at the bottom of the image so that it
    %doesn't interfere with segmentation.
    if DermLogo == 1 
        im = im(1:sizeX-20, :,:);
        sizeX = sizeX-20;
    end


    %converting image to grayscale
    imgray = rgb2gray(im);


    %stretching image histogram.

    %stretches so that the highest value is now 255
    imgray = imadjust(imgray,[double(min(min(imgray)))/255 double(max(max(imgray)))/255],[]);

    
    %% Initial Segmentation 

    %Otsu's algorithm for bw conversion. Thorws back a threshold for
    %segmentation
    [level EM] = graythresh(imgray);

    %deciding whether or not to negate the image. For cases where the lesion(s)
    %are lighter than the skin or vice versa.
    Invert = InversionDecision(imgray,sizeX,sizeY,sizeZ,SampleWidthR,SampleHeightR,SkinWidthR,SkinHeightR);

    %converting image to BW using the threshold 
    imBW = im2bw(imgray,level);
    if Invert == 1
        imBW = not(imBW);
    end
    
    
    %Filling in holes in case pieces in the middle were not taken during segmentation.
    FilledIn = imfill(imBW, 'holes'); 

    %Trimming corners. This is needed for images with vignetting in the corners.
    if TrimCorners == 1;
        Trim = 1/9;
        trimmed = FilledIn;
        trimmed(1:Trim*sizeX, 1:Trim*sizeY) = 0;
        trimmed( sizeX-(Trim*sizeX): sizeX, 1:(Trim*sizeY) ) = 0;
        trimmed( sizeX-(Trim*sizeX): sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
        trimmed( 1 : Trim*sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
        FilledIn = trimmed;
    end 


    FilledIn = bwareaopen(FilledIn, 5); %helps remove small specs before expanding 
    
    %applying a morphilogocial operation to help connect stary blobs.
    %using a circle with a standerdized radius.
    SE = strel('disk', round((ShapeFactor*sqrt(sizeX*sizeY))));
    AllBlobsMask = imdilate(FilledIn,SE);
    
    %Filling in holes.
    FilledIn = imfill(imBW, 'holes'); 

    %% Initial Labeling 

    %Labelling disconnected blobs
    LabeledMaster = bwlabel(AllBlobsMask);
    %getting areas of blobs.
    s = regionprops(LabeledMaster, 'Area');

    %sorting blobs in descending order based on area.
    [ListedIndecies, ListedIndecies] = sort([s.Area],'descend');
    MaxList = ListedIndecies(1);


    %extracting top NumberToTake blobs if they exist
    for i = 2:numel(ListedIndecies)
        if i>NumberToTake 
            break;
        end

        if s(ListedIndecies(i)).Area > BlobCutOff*s(ListedIndecies(1)).Area
            MaxList = [MaxList ListedIndecies(i)];
        else
            break;
        end
    end

    LargestBlobs = s(MaxList);


    %labeling them as one blob for color and symmetry 
    WorkBlockMask = (LabeledMaster==MaxList(1));
    LargestBlob = WorkBlockMask; %largest blob there is
    for i = 2:numel(MaxList)
        Temp = (LabeledMaster==MaxList(i));
        WorkBlockMask = or(WorkBlockMask, Temp); 
    end
    

    %% Color Information 
    
    [AvgColor, ColorVariance ClusterCentroids] = FindColorParam(im, WorkBlockMask, ColorClusterSize);


    %% Preparing top NumberToTake blobs for symmetry calc. 
    [ CroppedBinaryMask, CroppedRGB, CroppedGray ] = CenterCrop( WorkBlockMask, im, imgray );

    %debugging code.
%     test = regionprops(CroppedBinaryMask*2, 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');

%     hold on
% 
%     phi = linspace(0,2*pi,50);
%     cosphi = cos(phi);
%     sinphi = sin(phi);
% 
%     xbar = test(2).Centroid(1);
%     ybar = test(2).Centroid(2);
% 
%     a = test(2).MajorAxisLength/2;
%     b = test(2).MinorAxisLength/2;
% 
%     theta = pi*test(2).Orientation/180;
%     R = [ cos(theta)   sin(theta)
%          -sin(theta)   cos(theta)];
% 
%     xy = [a*cosphi; b*sinphi];
%     xy = R*xy;
%     x = xy(1,:) + xbar;
%     y = xy(2,:) + ybar;
% 
%     plot(x,y,'r','LineWidth',2);
%     scatter(test(2).Centroid(1),test(2).Centroid(2));
%     hold off
% 
%     figure;
%     imshow(CroppedBinaryMask);
% 
%     figure;
%     imshow(CroppedGray);
%     %testing

    %calling symmetry fucntions on top NumberToTake blobs
    [SymErrorBinaryX, SymErrorBinaryY]  = BinarySymmetryError(CroppedBinaryMask);
    SymErrorBinary = [SymErrorBinaryX SymErrorBinaryY];
    [SymErrorRGBX, SymErrorRGBY] = RGBSymmetryError(CroppedRGB, CroppedBinaryMask);
    SymErrorRGB = [SymErrorRGBX, SymErrorRGBY];
    [SymErrorGrayX, SymErrorGrayY] = GraySymmetryError(CroppedGray, CroppedBinaryMask);
    SymErrorGray = [SymErrorGrayX SymErrorGrayY];

    %% Getting gradient of largest blob 

    %cropping and centering the largesrt blob
    [ CroppedLargeBlobMask, CroppedLargeBlobRGB, CroppedLargeBlobGray ] = CenterCrop( LargestBlob, im, imgray );
    


    %unwrapping blob for gradient analysis, best if I explain this in real
    %life
    LargeBlobProp = regionprops(CroppedLargeBlobMask, 'MinorAxisLength');
    UnWrappedLargeBlob = GetUnwrap(CroppedLargeBlobMask, CroppedLargeBlobGray, LargeBlobProp.MinorAxisLength, UnWrapDepth);

    [FX,FY] = gradient(double(UnWrappedLargeBlob));
    [R, C] = size(UnWrappedLargeBlob);
    GradientChangeAvg = zeros(1,C);
    GradientChangeVar = zeros(1,C);

    %gradient analysis 
    for i = 1:C
        for j = 1:R
            if UnWrappedLargeBlob(j,i) ~= 0
                StartVal = j;
                break;
            end 
        end
        GradientChangeAvg(i) = mean(abs(FY(StartVal:R,i)));
        GradientChangeVar(i) = var(FY(StartVal:R,i));
    end
    
    %% Texture Sampling
    
    SampleSizeC = TextureSampleSizeC*size(CroppedLargeBlobGray,1);
    SampleSizeR = TextureSampleSizeR*size(CroppedLargeBlobGray,2);
    UpperLeftCorner = [ (1/2)*(size(CroppedLargeBlobGray,1)-SampleSizeR), (1/2)*(size(CroppedLargeBlobGray,2)-SampleSizeC) ];
    LowerRightCorner = [ (1/2)*(size(CroppedLargeBlobGray,1)+SampleSizeR), (1/2)*(size(CroppedLargeBlobGray,2)+SampleSizeC) ];

    %getting a cooccurance matrix of the sample area
    CoOcMatrix = graycomatrix(CroppedLargeBlobGray( UpperLeftCorner(1):LowerRightCorner(1), UpperLeftCorner(2):LowerRightCorner(2) ));
    CoOcProp = graycoprops(CoOcMatrix);
    CoOcProp = [CoOcProp.Contrast CoOcProp.Correlation CoOcProp.Energy CoOcProp.Homogeneity];

    %entropy of the sample
    SampleEntropy = entropyfilt(CroppedLargeBlobGray( UpperLeftCorner(1):LowerRightCorner(1), UpperLeftCorner(2):LowerRightCorner(2) ),  true(TextureEntropyNeighborhood));




    %% Edge roughness by approximating polygon fit 

    %using the undialated blob to get true roughness
    JaggedBlobsLabeled = bwlabel(FilledIn);
    JaggedBlobProp = regionprops(JaggedBlobsLabeled, 'Area', 'MinorAxisLength', 'MajorAxisLength');
    [Sorted, Sorted] = sort([JaggedBlobProp.Area],'descend');
    LargestJaggedBlobProp = JaggedBlobProp(Sorted(1));
    LargestJaggedBlob = (JaggedBlobsLabeled == Sorted(1));

    BoundryPointsOfJagged = bwboundaries(LargestJaggedBlob, 8, 'noholes');
    BoundryPointsOfJagged = (cell2mat(BoundryPointsOfJagged(1)))';
    [R JaggedLength] = size(BoundryPointsOfJagged);
    % VertexNum = JaggedLength/RoughVal;
    VertexNum  = RoughVal;
    Simp = (reduce_poly(BoundryPointsOfJagged, VertexNum))';
    Simp = [Simp(:,2) Simp(:,1)];
    SimplePoly = zeros(size(LargestJaggedBlob));

    %reduce-poly returns points. Using breenham to burn in lines between these
    %points
    for i = 1:size(Simp, 1)-1
        [RLin, CLine] = bresenham(Simp(i,2),Simp(i,1),Simp(i+1,2),Simp(i+1,1));
        SimplePoly(sub2ind(size(LargestJaggedBlob), RLin, CLine)) = 1;
    end
    [RLin, CLine] = bresenham(Simp(size(Simp, 1),2),Simp(size(Simp, 1),1),Simp(1,2),Simp(1,1));
    SimplePoly(sub2ind(size(LargestJaggedBlob), RLin, CLine)) = 1;

    %calculating roughness
    SimplePerimLength = sum(sum(SimplePoly));
    Roughness = JaggedLength/SimplePerimLength;
    
    %% Final clean up before output
    
    %resizing Gradient and Entropy filter 
    
    GradientChangeAvg = imresize(GradientChangeAvg, [1,GradientVarLength]);
    GradientChangeVar = imresize(GradientChangeVar, [1,GradientVarLength]);
%     GradientChangeAvg = mean(GradientChangeAvg);
%     GradientChangeVar = mean(GradientChangeVar);
    
    %resizing Entropy filtered image
    EntropSize = size(SampleEntropy);
    minEntropSize = min(EntropSize);
    ScaleFactor = EntropyFiltSize/minEntropSize;
    SampleEntropy = imresize(SampleEntropy, ScaleFactor);
    SampleEntropy = SampleEntropy(1:EntropyFiltSize, 1:EntropyFiltSize);
    
    %final feature vector, best to look at the FinalVector object down
    %below
    FinalVectorStruct = struct('ColorVarMatrix', ColorVariance, ...
        'AvgColor', AvgColor, 'ClusterCentroids', ClusterCentroids, ...
        'SymErrorBinaryX', SymErrorBinaryX,'SymErrorBinaryY', SymErrorBinaryY, ...
        'SymErrorRGBX', SymErrorRGBX,'SymErrorRGBY', SymErrorRGBY, ...
        'SymErrorGrayX', SymErrorGrayX,'SymErrorGrayY', SymErrorGrayY, ...
        'GradientChangeAvg', GradientChangeAvg, 'GradientChangeVar', GradientChangeVar, ...
        'CoOcMatrix', CoOcMatrix, 'CoOcProp', CoOcProp,  ...
        'SampleEntropy', SampleEntropy, ...
        'Roughness', Roughness, 'NoOfComponents', numel(MaxList));
    	
    
    FinalVector = [ reshape(FinalVectorStruct.ColorVarMatrix, [1 numel(FinalVectorStruct.ColorVarMatrix)] ) ...
                    reshape(FinalVectorStruct.AvgColor, [1 numel(FinalVectorStruct.AvgColor)] ) ...
                    reshape(FinalVectorStruct.ClusterCentroids, [1 numel(FinalVectorStruct.ClusterCentroids)] ) ...
                    reshape(FinalVectorStruct.SymErrorBinaryX, [1 numel(FinalVectorStruct.SymErrorBinaryX)] ) ...
                    reshape(FinalVectorStruct.SymErrorBinaryY, [1 numel(FinalVectorStruct.SymErrorBinaryY)] ) ...
                    reshape(FinalVectorStruct.SymErrorRGBX, [1 numel(FinalVectorStruct.SymErrorRGBX)] ) ...
                    reshape(FinalVectorStruct.SymErrorRGBY, [1 numel(FinalVectorStruct.SymErrorRGBY)] ) ...
                    reshape(FinalVectorStruct.SymErrorGrayX, [1 numel(FinalVectorStruct.SymErrorGrayX)] ) ...
                    reshape(FinalVectorStruct.SymErrorGrayY, [1 numel(FinalVectorStruct.SymErrorGrayY)] ) ...
                    reshape(FinalVectorStruct.SampleEntropy, [1 numel(FinalVectorStruct.SampleEntropy)] ) ...
                    reshape(FinalVectorStruct.GradientChangeAvg, [1 numel(FinalVectorStruct.GradientChangeAvg)] ) ...
                    reshape(FinalVectorStruct.GradientChangeVar, [1 numel(FinalVectorStruct.GradientChangeVar)] ) ...
                    reshape(FinalVectorStruct.CoOcMatrix, [1 numel(FinalVectorStruct.CoOcMatrix)] ) ...
                    reshape(FinalVectorStruct.CoOcProp, [1 numel(FinalVectorStruct.CoOcProp)] ) ...
                    reshape(FinalVectorStruct.Roughness, [1 numel(FinalVectorStruct.Roughness)] ) ...
                    numel(MaxList)];
                    
    %reshape(FinalVectorStruct.SampleEntropy, [1 numel(FinalVectorStruct.SampleEntropy)] ) ...
    
    %ignore this
    Images = struct('WorkBlockMask', WorkBlockMask);
    
    %ColorVarMatrix: contains variance values for the three color channels.
    
    %AvgColor: Average color in RGB space. 
    
    %ClusterCentroids: Color centroid in RGB from kmeans 
    
    %SymErrorBinaryX: error in the best symmetry achieved through the
    %X-axis
    
    %SymErrorBinaryY: same as SymErrorBinaryX but applies to the
    %corresponding Y axis
    
    %GradientChangeAvg: Average value of gradient inwards from the
    %perimeter 
    
    %GradientChangeVar: Variance of gradient inwards from the perimeter
    
    %CoOcMatrix: Coocurance matrix for a sample of the lesion
    
    %CoOcMatrixProp: Properties of the CoOcurance matrix.
    
    %SampleEntropy: Resized and scaled entropy filtered segment of the
    %legion
    
    %Roughness: Value of the edge roughness of rhe lesion
    
    %NoOfComponents: No of components found within the cutoff threshold.
    
    
end

