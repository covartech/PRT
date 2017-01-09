function clusters = prtUtilBicluster(A,delta,alpha)
% Cheng and Church
% http://www.kemaleren.com/cheng-and-church.html
% 
% Sorry, choosing the input parameters is hard...
% Try delta = 1 and alpha = 1.2 for starters.

N = 10;

aMax = max(A(:));
aMin = min(A(:));

for iCluster = 1:N
    I = 1:size(A,1);
    J = 1:size(A,2);

    % multi-node deletion
    while true
        [aiJ,aIj,Hij,HIJ] = msresidual(A,I,J);
        if HIJ<delta
            break
        end
        di = mean(Hij(I,J),2);
        dj = mean(Hij(I,J),1);

        badi = find(di>alpha*HIJ);
        badj = find(dj>alpha*HIJ); % & length(dj)>100);

        if isempty(badi) && isempty(badj)
            break
        end

        I = setdiff(I,I(badi));
        J = setdiff(J,J(badj));
    end

    % single-node deletion
    while true
        [aiJ,aIj,Hij,HIJ] = msresidual(A,I,J);
        if HIJ<delta
            break
        end
        di = mean(Hij(I,J),2);
        dj = mean(Hij(I,J),1);

        [maxiVal,maxi] = max(di);
        [maxjVal,maxj] = max(dj);

        if maxiVal>maxjVal
            I = setdiff(I,I(maxi));
        else
            J = setdiff(J,J(maxj));
        end
    end

    % node addition
    while true
        [aiJ,aIj,Hij,HIJ] = msresidual(A,I,J);

        Jp = setdiff(find(mean(Hij(I,:),1)<=HIJ),J);

        [aiJ,aIj,Hij,HIJ] = msresidual(A,I,J);

        Ip = setdiff(find(mean(Hij(:,J),2)<=HIJ),I);

        if isempty(Jp) && isempty(Ip)
            break
        end

        J = union(J,Jp);
        I = union(I,Ip);

    end
    clusters(iCluster,:) = {I,J};
    A(I,J) = rand(length(I),length(J))*(aMax-aMin)+aMin;
end