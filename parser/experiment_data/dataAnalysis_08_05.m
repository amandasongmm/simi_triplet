% dataAnalysis.m
clc; clear; close all; 

%% import from doublet.csv
[subInd, trialType, RT, rating, im1, im2] = importData('doublet_initial10.csv');
testInd = (trialType==2); 
intergratedData = [trialType, subInd, im1, im2, rating, RT];
intergratedData = intergratedData(testInd, :);


%% Step 1: plot a histgram of 1-9 rating distribution
effectRating = rating(testInd);
temp = zeros(9,1);
for curItr = 1 : 9
    temp(curItr) = sum(effectRating==curItr);
    disp(temp(curItr));
end
figure(1);
a = bar(temp);
title('Rating Distribution across 10 subjects');
xlabel('Similarity Rating');
ylabel('# of times');
saveas(gcf, 'RatingDistribution.png');

%% Step 2: plot a histgram of RT times. 
figure(2);
hist(RT, 500);
title('RT distribution');
xlabel('Reaction Time per trial (sec)');
ylabel('Num');
axis([0,60,0,140]);
saveas(gcf, 'RT distributions.png');

%% Step 3: plot intersubject std
% prepare sub2ind
feFaceNum = 1000;
linearInd = sub2ind([feFaceNum, feFaceNum], intergratedData(:,3), intergratedData(:,4));

uniquePair = unique(linearInd);
pairNum = length(uniquePair);
interStatArray = zeros(pairNum, 5);%repetitiveTimes, average rating, averageRT, rating variance, RT variance. 
for curPair = 1 : length(uniquePair)
    tempInd = linearInd==uniquePair(curPair);
    interStatArray(curPair, 1) = sum(tempInd);
    interStatArray(curPair, 2) = mean(intergratedData(tempInd, 5));%average rating
    interStatArray(curPair, 3) = mean(intergratedData(tempInd, 6));%average RT
    interStatArray(curPair, 4) = std(intergratedData(tempInd, 5));%std of rating
    interStatArray(curPair, 5) = std(intergratedData(tempInd, 6));%std of RT
end

figure(3);% inter subject: rating mean, RT mean, rating STD, RT STD
subplot(2,2,1);hist(interStatArray(:,2),100);%average Rating
title('average rating');
subplot(2,2,2);hist(interStatArray(:,3),100);%average RT
title('average RT');
subplot(2,2,3);hist(interStatArray(:,4),100);%std rating
title('std rating');
subplot(2,2,4);hist(interStatArray(:,5),100);%std RT
title('std RT');
saveas(gcf, 'intersubjectVariance.png');

%% step 4: plot intra subject STD
subNum = max(subInd);
subArray = cell(subNum, 1);
subArrayMatrix = zeros(10000,5);
counter = 1; 
for curSub = 1 : subNum
    curSubInd = find(intergratedData(:,2)==curSub); 
    curData = intergratedData(curSubInd, :);
    curLinearList = linearInd(curSubInd);
    uniqueLocal = unique(curLinearList);
    startInd = counter; 
    endInd = counter + length(uniqueLocal)-1; 
    figure(curSub);
    subArray{curSub} = zeros(length(uniqueLocal),5);%Rating Mean, RT mean, Rating STD, RT STD
    for curUni = 1: length(uniqueLocal)
        tempInd = find(curLinearList == uniqueLocal(curUni)); 
        subArray{curSub}(curUni, 1) = curSub; 
        subArray{curSub}(curUni, 2) = mean(curData(tempInd,5));%Rating
        subArray{curSub}(curUni, 3) = mean(curData(tempInd,6));%RT
        subArray{curSub}(curUni, 4) = std(curData(tempInd,5));%Rating
        subArray{curSub}(curUni, 5) = std(curData(tempInd,6));%RT
    end
    subplot(2,2,1);hist(subArray{curSub}(:,2),20);title(sprintf('average rating. sub%d',curSub));
    subplot(2,2,2);hist(subArray{curSub}(:,3),20);title(sprintf('average RT. sub%d',curSub));
    subplot(2,2,3);hist(subArray{curSub}(:,4),20);title(sprintf('STD rating. sub%d',curSub));
    subplot(2,2,4);hist(subArray{curSub}(:,5),20);title(sprintf('STD rating. sub%d',curSub));
    subArrayMatrix(startInd:endInd, :) = subArray{curSub};
    counter = counter + length(uniqueLocal);
    saveas(gcf, sprintf('sub%d.png',curSub));
end














































