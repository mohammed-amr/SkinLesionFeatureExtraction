This repo has code for old school segmentation of skin lesions in dermoscopic images. It also houses code for extracting features of these lesions for further analysis down the line.

It has a bunch of useful functions specific to this task and can be used in other domains. The task of segmentation here is completely unsupervised if a few assumptions are allowed.

-You'll need a version of Matlab with the Image Processing Toolbox installed. 
-The code was written in MATLAB 2013, and I know it runs in MATLAB 2016
-Extract Features is the main core function that ex
-MainISIC is for batch processing. 
-Main is an older batprocessing file.


There's a tester script, Tester.m, that runs the function on one image. 
MainISIC extracts features in the ISIC dataset.

I wrote this code while working with Dr. Tawfik Ismail at Cairo University.
