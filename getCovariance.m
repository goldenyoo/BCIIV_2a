function [N, Cov] = getCovariance(Class,cnt_c)


Cov = zeros(size(cnt_c,1));
for i=Class
    % One trial data
    E = cnt_c(:,i:i+313);
    
%     %BPF Design
%     bpFilt = designfilt('bandpassfir','FilterOrder',25, ...
%         'CutoffFrequency1',8,'CutoffFrequency2',30, ...
%         'SampleRate',250);
%     % Apply BPF
%     for i = 1:size(E,1)
%         E(i,:) = filtfilt(bpFilt, E(i,:));
%         %     cnt_c(i,:) = filter(bpFilt, cnt_c(i,:));
%     end      
    
    % Covariance 연산
    C = E*E'/ trace( E*E');
    
    Cov = Cov + C;
end
Cov = Cov/length(Class);
N = length(Class);
end