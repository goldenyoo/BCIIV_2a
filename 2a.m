% ----------------------------------------------------------------------- %
%    File_name: deep_learning_cnn.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_01_13                            
%                                                            
 % ----------------------------------------------------------------------- %
 %% Call raw data
close all
clear all

% Ask user for input parameters
prompt = {'Data label: ','train test split ratio: '};
dlgtitle = 'Input';
dims = [1 50];
definput = {'a','0.8'};
answer = inputdlg(prompt,dlgtitle,dims,definput);


% Error detection
if isempty(answer), error("Not enough input parameters."); end

% Input parameters
data_label = string(answer(1,1));   % Calib_ds1 + "data_label"
train_test_ratio = double(string(answer(2,1))); % train_test_split ratio


% Load file
FILENAME = strcat('C:\Users\유승재\Desktop\Motor Imagery EEG data\BCICIV_1_mat\BCICIV_calib_ds1',data_label,'.mat');
load(FILENAME);

% Data rescale
cnt= 0.1*double(cnt);
cnt = cnt';

% Exclude electrode (AF3, AF4, O1, O2, PO1, PO2)
cnt_c = cnt(3:55,:);
%% 
%train test split
a = 1; b = 1;
% s = rng;
r = randperm(length(mrk.pos));
k = round(length(r)*train_test_ratio);

for j = 1:k
    i = r(1,j);
    
    % One trial data
    E = cnt_c(:,mrk.pos(1,i):mrk.pos(1,i)+350);   
    
    XTrain(j,1) = {E};    
    YTrain(j,1) = mrk.y(1,i);
    if mrk.y(1,i) == 1 
       
        a = a+1;
    else
       
        b = b+1;
    end
end
YTrain = categorical(YTrain);

for j = k+1:length(r)
    i = r(1,j);
    
    % One trial data
    E = cnt_c(:,mrk.pos(1,i):mrk.pos(1,i)+350);   
    
    XTest(j-k,1) = {E};    
    YTest(j-k,1) = mrk.y(1,i);
end
YTest = categorical(YTest);

%%
inputSize = 53;
numHiddenUnits = 60; %%%%%%%%%%%%%% Change hidden unit number
numClasses = 2;

layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
%     dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]; % Can Add: InputWeightsLearnRateFactor, RecurrentWeightsLearnRateFactor, BiasLearnRateFactor, InputWeightsL2Factor

maxEpochs = 100;
miniBatchSize = 351; %%%%%%%%%%%%%% Change BatchSize -> our data is already chunked

options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...   % "once', 'never', 'every-epoch'
    'ValidationData',{XTest,YTest}, ...
    'ValidationFrequency',10, ...
    'Verbose',0, ...
    'Plots','training-progress');
    
%'LearnRateSchedule','piecewise', ...
    %'LearnRateDropPeriod',10, ...


net = trainNetwork(XTrain,YTrain,layers,options);
%% 
YPred = classify(net,XTest, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');

acc = sum(YPred == YTest)./numel(YTest);
 err = immse(str2num(char(YPred(:))), str2num(char(YTest(:))));
 
 disp(sprintf('Score: %f   MSE: %f',acc,err));
