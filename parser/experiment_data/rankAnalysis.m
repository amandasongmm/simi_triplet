% rankAnalysis.m
% the purpose is to rank each subject's trials so as to estimate the
% variance of ranking in each trial(pair) and in each subject

clc; clear; 
[workerID,RT,score,im1,im2,set] = importDataPost('doubletPost.csv',2, 1321);
dataArray = [workerID, RT, score, im1, im2, set];%1320/*6

% just do for set ==3 for now. 
curInd = find(set ==3); 
curData = dataArray(curInd, :);%660*6
curRate = curData(:,3);%660*1

curSubNum = 5; 
curPairNum = 33; 
curRepNum =4; 

temp = reshape(curRate, [curRepNum, curSubNum*curPairNum]);%4*165
trialArray = zeros(curSubNum*curRepNum, curPairNum);%20*33 divided by trials. 
for curSub = 1 : curSubNum
    for curRep = 1 : curRepNum
        trialArray((curSub-1)*curRepNum+curRep, :) = temp(curRep, (curSub-1)*curPairNum+1:curSub*curPairNum);
    end
end

%% Next, we need to rank every row in trialArray. 
rankArray = zeros(curSubNum*curRepNum, curPairNum);%20*33
for curItr = 1 : curSubNum*curRepNum
    rankArray(curItr, :) = tiedrank(trialArray(curItr, :));% tied rank
end
pairVariance = std(rankArray);
figure(3);
bar(pairVariance);
title('variance of each pair');

rankDistance = zeros(curSubNum*curRepNum, curPairNum);
temp = mean(rankArray);%1*33
for curItr = 1 : curSubNum*curRepNum
    rankDistance(curItr, :) = rankArray(curItr,:)-temp;
end
rankDistance = abs(rankDistance);


%% Visualize the rank data. 
figure(1);
bar(mean(rankDistance));
title('Pair specific variance');

figure(2);
title('Subject specific variance');
bar(mean(rankDistance,2));

%% 
[a, b] = sort(mean(rankArray));
topInd = b(1:5);
endInd = b(end-4:end);
topIndArray = zeros(5,2);
endIndArray = zeros(5,2);
curData = dataArray(curInd, :);%660*6
for curItr = 1 : 5
    topIndArray(curItr, 1) = curData(topInd(curItr)*4,4);
    topIndArray(curItr, 2) = curData(topInd(curItr)*4,5);
    endIndArray(curItr, 1) = curData(endInd(curItr)*4,4);
    endIndArray(curItr, 2) = curData(endInd(curItr)*4,5);
end

%% prepare to see the figures
for curItr = 1 %: 33
    figure;
    subplot(1,2,1);
    file1 = sprintf('../../static/images/2kFemale/F%d.jpg',curData(curItr*4,4));
    imshow(file1);
    subplot(1,2,2);
    file2 = sprintf('../../static/images/2kFemale/F%d.jpg',curData(curItr*4,5));
    imshow(file2);
end





