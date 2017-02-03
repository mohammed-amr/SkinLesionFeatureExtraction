clear;
clc;

load('SecondRun2.mat');

MelanomaVec = [MelanomaVectors ones(size(MelanomaVectors,1), 1)];
NotMelVec = [NotMelVectors zeros(size(NotMelVectors,1), 1)];

Joined = [MelanomaVec; NotMelVec];

Joined = Joined(randperm(end),:);


inputs = (Joined(:,1:end-1))';
targets = (Joined(:,end))';

% Create a Pattern Recognition Network
net = patternnet([400 300 200 200 100]);
net.trainFcn = 'trainbr';


% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

net.trainParam.max_fail = 25;


% Train the Network
net = init(net);

[net,tr] = train(net,inputs,targets, 'useGPU', 'yes');

% Test the Network
outputs = net(inputs);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

