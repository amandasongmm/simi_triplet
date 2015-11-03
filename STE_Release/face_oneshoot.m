% face_oneshoot.m
%FACE_EXPERIMENT Performs experiments on face triplet data with triplet embedding
%
% face_experiment
%
% The function performs experiments with various triplet embedding
% techniques on the faceTriplet data set, measuring triplet generalization
% errors.

clc; clear;
addpath(genpath('drtoolbox'));
%% Load raw data
disp('Loading raw data...');
load('data/faceTriplet.mat');

%% Initialize some variables for experiments
no_dims = 2;
no_triplets = size(faceTriplet, 1);

%% Split training and test data
sampleSize = size(faceTriplet, 1);
trainRatio = 0.9;
trainNum = sampleSize * trainRatio;
trainInd = randperm(sampleSize, trainNum);
testInd = 1:sampleSize; testInd(trainInd)=[];
trainTriplet = faceTriplet(trainInd, :);

X = tste(trainTriplet, no_dims);
save('data/mappedFaceEmbedding.mat','X');

