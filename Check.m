function [conf_mat, kappa] = Check(answer,output)
data_label = string(answer(1,1));   

%% Call true label
FILENAME = strcat('C:\Users\유승재\Desktop\BCIIV_2a_mat\true_labels\A0',data_label,'E');
load(FILENAME);


conf_mat = zeros(4,4);


for i = 1:length(classlabel)
    predictions = output{i};
    for k = 1:length(predictions)
        conf_mat(classlabel(i),predictions(k)) = conf_mat(classlabel(i),predictions(k)) + 1;
    end
end


N = sum(sum(conf_mat));
p0 = sum(diag(conf_mat))/N;
pe = (sum(conf_mat(:,1))*sum(conf_mat(1,:)) + sum(conf_mat(:,2))*sum(conf_mat(2,:)) + sum(conf_mat(:,3))*sum(conf_mat(3,:)))/N^2;

kappa = (p0-pe)/(1-pe);

end