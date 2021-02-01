% ----------------------------------------------------------------------- %
%    File_name: BCI_2a.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_01_29                            
%
% [s, h] = sload('C:\Users\유승재\Desktop\BCICIV_2a_gdf\A09E.gdf', 0);
% ----------------------------------------------------------------------- %
 %% input parameter
close all
clear all

data_label = "1";
m = 3;
order = 50;
low_f = 8;
high_f = 30;
%% 

FILENAME = strcat('C:\Users\유승재\Desktop\BCIIV_2a_mat\A0',data_label,'T_2_mat');
load(FILENAME);

s = 0.1*double(s);
cnt = s';
cnt(~isfinite(cnt)) = -471.5; % Encode Nan as the negative maximum value
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

%% Calculate covariance for all Classes
Class_1 = [];
Class_2 = [];
Class_3 = [];
Class_4 = [];

i=1;
while i <=length(h.EVENT.TYP)
    if h.EVENT.TYP(i)== 1023
        i = i + 2;
    elseif h.EVENT.TYP(i)== 769
        Class_1 = [Class_1 h.EVENT.POS(i)];
        i = i + 1;
    elseif h.EVENT.TYP(i)== 770
        Class_2 = [Class_2 h.EVENT.POS(i)];
        i = i + 1;
    elseif h.EVENT.TYP(i)== 771
        Class_3 = [Class_3 h.EVENT.POS(i)];
        i = i + 1;
    elseif h.EVENT.TYP(i)== 772
        Class_4 = [Class_4 h.EVENT.POS(i)];
        i = i + 1;
    else
        i = i + 1;
    end    
end

Cov_1 = getCovariance(Class_1,cnt_c);
Cov_2 = getCovariance(Class_2,cnt_c);
Cov_3 = getCovariance(Class_3,cnt_c);
Cov_4 = getCovariance(Class_4,cnt_c);
%% 
% Cov_total = Cov_1 + Cov_2 + Cov_3 + Cov_4;
Cov_total = Cov_1 + Cov_2;

% EVD for composite covariance
[V, D] = eig(Cov_total);

% sort eigen vector with descend manner
[d, ind] = sort(abs(diag(D)),'descend');
D_new = diag(d);
V_new = V(:,ind);

% whitening transformation
whiten_tf = V_new*D_new^(-0.5);
W = whiten_tf';

% Apply whitening to each averaged covariances
S_1 = W*Cov_1*W';
S_2 = W*Cov_2*W';
S_3 = W*Cov_3*W';
S_4 = W*Cov_4*W';

% EVD for transformed covariance
[U, phsi] = eig(S_1,S_2);

% sort
[d, ind] = sort(abs(diag(phsi)),'descend');
phsi_new = diag(d);
U_new = U(:,ind);

% Total Projection matrix,   Z = P'*X
P = (U_new'*W)';
%% 

[M_1 Q_1] = getFeature_vector(Class_1,P,cnt_c);
[M_2 Q_2] = getFeature_vector(Class_2,P,cnt_c);
[M_3 Q_3] = getFeature_vector(Class_3,P,cnt_c);
[M_4 Q_4] = getFeature_vector(Class_4,P,cnt_c);


%% 
f1 = figure;
score = [];
predictions = [];
checks = [];

for j = Class_1
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
    [check, prediction] = myClassifier(fp,M_1,M_2,Q_1,Q_2);
    if prediction == 1
        score = [score 1];
        
    else
        score = [score 0];
        
    end
    predictions = [predictions prediction];
    checks = [checks check];    
%     
    % Graphical represent
    figure(f1)
    scatter3(Z(1,:), Z(size(Z,1),:),Z(2,:),'b'); hold on;
end
for j = Class_2
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
    [check, prediction] = myClassifier(fp,M_1,M_2,Q_1,Q_2);
    if prediction == -1
        score = [score 1];
        
    else
        score = [score 0];
        
    end
    predictions = [predictions prediction];
    checks = [checks check];    
%     
    % Graphical represent
    figure(f1)
    scatter3(Z(1,:), Z(size(Z,1),:),Z(2,:),'r'); hold on;
end
% for j = Class_3
%     E = cnt_c(:,j:j+313);
%     Z = P'*E;
%     % Graphical represent
%     figure(f1)
%     scatter3(Z(1,:), Z(size(Z,1),:),Z(2,:),'g'); hold on;
% end
% for j = Class_4
%     E = cnt_c(:,j:j+313);
%     Z = P'*E;
%     % Graphical represent
%     figure(f1)
%     scatter3(Z(1,:), Z(size(Z,1),:),Z(2,:),'k'); hold on;
% end
output = 100*sum(score)/length(score);
disp(output)