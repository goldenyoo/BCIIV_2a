function P = getProjection_matrix(Cov_a,Cov_b)
Cov_total = Cov_a +Cov_b;
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
S_1 = W*Cov_a*W';
S_2 = W*Cov_b*W';

% EVD for transformed covariance
[U, phsi] = eig(S_1,S_2);

% sort
[d, ind] = sort(abs(diag(phsi)),'descend');
phsi_new = diag(d);
U_new = U(:,ind);

% Total Projection matrix,   Z = P'*X
P = (U_new'*W)';
end