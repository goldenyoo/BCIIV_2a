% ----------------------------------------------------------------------- %
%    File_name: Eval.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_02_02                           
%                                                            
 % ----------------------------------------------------------------------- %
function output = Eval(answer,M_1,M_2,M_3,M_4,Q_1,Q_2,Q_3,Q_4,P)
data_label = string(answer(1,1));
m = double(string(answer(2,1)));
order = double(string(answer(3,1)));
low_f = double(string(answer(4,1)));
high_f = double(string(answer(5,1)));
%% Call true label
FILENAME = strcat('C:\Users\유승재\Desktop\BCIIV_2a_mat\true_labels\A0',data_label,'E');
load(FILENAME);

%% Call evaluation data
FILENAME = strcat('C:\Users\유승재\Desktop\BCIIV_2a_mat\A0',data_label,'E_mat');
load(FILENAME);

s = 0.1*double(s);
cnt = s';
cnt(~isfinite(cnt)) = min(min(cnt)); % Encode Nan as the negative maximum value

%% Preprocessing
for i = 1 : size(cnt,1)
        cnt(i,:) = cnt(i,:) - cnt(10,:);
end
cnt_c = cnt(2:18,:);
Means = (1/size(cnt_c,1))*sum(cnt_c);
for i = 1 : size(cnt_c,1)
    cnt_c(i,:) = cnt_c(i,:) - Means; % CAR
end
%%
%BPF Design
bpFilt = designfilt('bandpassfir','FilterOrder',order, ...
    'CutoffFrequency1',low_f,'CutoffFrequency2',high_f, ...
    'SampleRate',250);
% Apply BPF
for i = 1:size(cnt_c,1)
    cnt_c(i,:) = filtfilt(bpFilt, cnt_c(i,:));
%     cnt_c(i,:) = filter(bpFilt, cnt_c(i,:));
end
%% 
Class_1 = [];

i=1;
while i <=length(h.EVENT.TYP)
    if h.EVENT.TYP(i)== 1023
        i = i + 1;
    elseif h.EVENT.TYP(i)== 783
        Class_1 = [Class_1 h.EVENT.POS(i)];
        i = i + 1;
    else
        i = i + 1;
    end    
end

%% 
score = [];
predictions = [];
checks = [];

for i = 1: length(Class_1)
    j = Class_1(i);
    E = cnt_c(:,j:j+313);
    Z = P'*E;
    
    % Feature vector
    tmp_ind = size(Z,1);
    Z_reduce = [Z(1:m,:); Z(tmp_ind-(m-1):tmp_ind,:)];
    
    var_vector = var(Z_reduce,0,2)';
    var_vector = (1/sum(var_vector))*var_vector;
    
    fp = log(var_vector);
    fp = fp';
    
    % Run classifier
    [check, prediction] = myClassifier(fp,M_1,M_2,M_3,M_4,Q_1,Q_2,Q_3,Q_4);
    if prediction == classlabel(i)
        score = [score 1];        
    else
        score = [score 0];
        
    end
    predictions = [predictions prediction];
    checks = [checks check];    
%     
    % Graphical represent
%     figure(f1)
%     scatter3(Z(1,:), Z(size(Z,1),:),Z(2,:),'b'); hold on;
end
  
% Caculation score
output = 100*sum(score)/length(score);
end