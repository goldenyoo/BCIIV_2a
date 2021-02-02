function [M Q] = getFeature_vector(Class,P,cnt_c,m)
fp_n = [];
for i = Class    
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
end

M = mean(fp_n,2);

Q = zeros(2*m);
for i = 1:length(fp_n)
    tmp = (fp_n(:,i) - M)*(fp_n(:,i) - M)';
    Q = Q + tmp;
end
Q = (1/(length(fp_n)-1))*Q;

end