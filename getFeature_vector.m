function [train_0,train_r,M_0,M_r, Q_0, Q_r] = getFeature_vector(Class_0,Class_r,P,cnt_c,m)
% figure
fp_n = [];
for i = Class_0    
    % One trial data
    E = cnt_c(:,i:i+313);
    
    % Project data using calculated spatial filter
    Z = P'*E;
    
    % Feature vector
    tmp_ind = size(Z,1);
    Z_reduce = [Z(1:m,:); Z(tmp_ind-(m-1):tmp_ind,:)];   
    var_vector = var(Z_reduce,0,2)';
    var_vector = (1/sum(var_vector))*var_vector;
    
    fp = log(var_vector);
    fp = fp';
    
     fp_n = [fp_n fp];
%      scatter3(fp(1),fp(2),fp(4),'b'); hold on;
end

train_0 = fp_n;


M_0 = mean(fp_n,2);

Q = zeros(2*m);
for i = 1:length(fp_n)
    tmp = (fp_n(:,i) - M_0)*(fp_n(:,i) - M_0)';
    Q = Q + tmp;
end
Q = (1/(length(fp_n)-1))*Q;

Q_0 = Q;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fp_n = [];
for i = Class_r    
    % One trial data
    E = cnt_c(:,i:i+313);
    
    % Project data using calculated spatial filter
    Z = P'*E;
    
    % Feature vector
    tmp_ind = size(Z,1);
    Z_reduce = [Z(1:m,:); Z(tmp_ind-(m-1):tmp_ind,:)];   
    var_vector = var(Z_reduce,0,2)';
    var_vector = (1/sum(var_vector))*var_vector;
    
    fp = log(var_vector);
    fp = fp';
    
     fp_n = [fp_n fp];
%      scatter3(fp(1),fp(2),fp(4),'r'); hold on;
end

train_r = fp_n;


M_r = mean(fp_n,2);

Q = zeros(2*m);
for i = 1:length(fp_n)
    tmp = (fp_n(:,i) - M_r)*(fp_n(:,i) - M_r)';
    Q = Q + tmp;
end
Q = (1/(length(fp_n)-1))*Q;

Q_r = Q;

end