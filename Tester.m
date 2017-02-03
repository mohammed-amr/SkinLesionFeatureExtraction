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
   
im = imread('Mel.jpg');

[MelanomaVector, im] = ExtractFeatures( im, DermLogo, TrimCorners, SampleWidthR, SampleHeightR, ...
    SkinWidthR, SkinHeightR, BlobCutOff, ShapeFactor, UnWrapDepth, RoughVal, TextureSampleSizeR, TextureSampleSizeC, ...
    TextureEntropyNeighborhood, ColorClusterSize, NumberToTake, GradientVarLength, EntropyFiltSize);

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


