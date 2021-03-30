% ----------------------------------------------------------------------- %
%    File_name: Eval.m
%    Programmer: Seungjae Yoo                             
%                                           
%    Last Modified: 2020_03_30                           
%                                                            
 % ----------------------------------------------------------------------- %
function [output] = Eval(answer,P,V_train,X_train,ref)
data_label = string(answer(1,1));
m = double(string(answer(2,1)));
low_f = double(string(answer(3,1)));
high_f = double(string(answer(4,1)));
referencing = double(string(answer(5,1)));
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
if referencing ~= 0
    %%% Calculate differential voltage
    for i = 1 : size(cnt,1)
        cnt(i,:) = cnt(i,:) - cnt(ref,:);
    end
    
    % common average
    if referencing == 1
        cnt_y = cnt; % Exclude electrode (AF3, AF4, O1, O2, PO1, PO2)
        Means = (1/size(cnt,1))*sum(cnt);
        for i = 1 : size(cnt_y,1)
            cnt_y(i,:) = cnt_y(i,:) - Means; % CAR
        end
        cnt_y = cnt_y([2:9 11:18],:);
        % LAP
    elseif referencing == 2
        cnt_n = myLAP(cnt,nfo); % Laplacian
        cnt_y = cnt_n([2:9 11:18],:); % Exclude electrode (AF3, AF4, O1, O2, PO1, PO2)
    end
else
    %%% Calculate differential voltage
    for i = 1 : size(cnt,1)
        cnt(i,:) = cnt(i,:) - cnt(ref,:);
    end
    
    cnt_y = cnt([2:9 11:18],:); % Exclude electrode (AF3, AF4, O1, O2, PO1, PO2)
end
%%
%BPF Design
bpFilt = designfilt('bandpassiir','SampleRate',250,'PassbandFrequency1',low_f, ...
        'PassbandFrequency2',high_f,'StopbandFrequency1',low_f-2,'StopbandFrequency2',high_f+2, ...
        'StopbandAttenuation1',40,'StopbandAttenuation2',40, 'PassbandRipple',1,'DesignMethod','cheby2');
% Apply BPF
for i = 1:size(cnt_y,1)
    cnt_c(i,:) = filtfilt(bpFilt, cnt_y(i,:));
%     cnt_c(i,:) = filter(bpFilt, cnt_c(i,:));
end
%% 
  checker = [];
  checker_tt = [];


pip = 1;
for i = 1: length(h.EVENT.POS)
   if h.EVENT.TYP(i)== 783
       predictions = [];
      
       for j = 0:50
           E = cnt_c(:,h.EVENT.POS(i)+20*j-500:h.EVENT.POS(i)+20*j);
           
           for k = 1:4
               Z = P{k}'*E;
               % Feature vector
               tmp_ind = size(Z,1);
               Z_reduce = [Z(1:m,:); Z(tmp_ind-(m-1):tmp_ind,:)];
               var_vector = diag(Z_reduce*Z_reduce')/trace(Z_reduce*Z_reduce');
               fp(:,k) = log(var_vector);
           end
           clear Z Z_reduce
           
           [tt1 prediction1, insert1] = myClassifier2(fp(:,1),X_train{1,1},X_train{1,2},V_train{1,1},1); %%%  0 vs -1
           
           [tt2 prediction2, insert2] = myClassifier2(fp(:,2),X_train{2,1},X_train{2,2},V_train{2,1},2); %%% 0 vs +1
           
           [tt3 prediction3, insert3] = myClassifier2(fp(:,3),X_train{3,1},X_train{3,2},V_train{3,1},3); %%% -1 vs +1
           
           [tt4 prediction4, insert4] = myClassifier2(fp(:,4),X_train{4,1},X_train{4,2},V_train{4,1},4); %%% -1 vs +1
           
%            checker = [checker;[classlabel(pip) prediction1 prediction2 prediction3 prediction4 tt1 tt2 tt3 tt4 insert1 insert2 insert3 insert4]];
           checker_tt = [tt1 tt2 tt3 tt4];
           checker_in = [prediction1 prediction2 prediction3 prediction4];
           % Decision algorithm
           if prediction1 == -10 && prediction2 == -10 && prediction3 == -10 && prediction4 == -10
               [M, I] = min(abs(checker_tt));
               prediction = I;
           else
               ind = find(checker_in ~=-10 );
               [M, I] = max(checker_tt(ind));
               prediction = checker_in(ind(I));
           end
           
           predictions = [predictions prediction];
       end
       output{pip} = predictions;
       pip = pip + 1;
   end
end
  

end