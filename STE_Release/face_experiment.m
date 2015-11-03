%FACE_EXPERIMENT Performs experiments on face triplet data with triplet embedding
%
% face_experiment
%
% The function performs experiments with various triplet embedding
% techniques on the faceTriplet data set, measuring triplet generalization
% errors.

%% Load raw data
disp('Loading raw data...');
load('data/faceTriplet.mat');

%% Initialize some variables for experiments
no_folds = 10;
no_dims = 2:2:30;
no_triplets = size(faceTriplets, 1);

err = zeros(length(no_dims), no_folds);
fold_ind = 1;
fold_size = round(no_triplets ./ no_folds);
perm = randperm(no_triplets);

% Loop over folds
for fold=1:no_folds
    %% Split training and test data
    sampleSize = size(faceTriplet, 1);
    trainRatio = 0.9;
    trainNum = sampleSize * trainRatio;
    trainInd = randperm(sampleSize, trainNum);
    testInd = 1:sampleSize; testInd(trainInd)=[];
    trainTriplet = faceTriplet(trainInd, :);
    % Split triplets into training and test data
    train_ind = perm([1:fold_ind - 1 fold_ind + fold_size:end]);
    test_ind  = perm(fold_ind:min(fold_ind + fold_size - 1, length(perm)));
    train_triplets = triplets(train_ind,:);
    test_triplets = triplets(test_ind,:);
    fold_ind = fold_ind + fold_size;
    
    
    
    % Loop over dimensionalities
    for j=1:length(no_dims)
        
        % Compute embedding
        switch techniques{i}
            case {'gnmds_k', 'ckl_k', 'ste_k'}
                [mappedX, L, ~] = svd(K);
                mappedX = bsxfun(@times, sqrt(diag(L(1:no_dims(j), 1:no_dims(j))))', mappedX(:,1:no_dims(j)));
            case 'gnmds_x'
                mappedX = gnmds_x(train_triplets, no_dims(j));
            case 'ckl_x'
                mappedX = ckl_x(train_triplets, no_dims(j), params(i));
            case 'ste_x'
                mappedX = ste_x(train_triplets, no_dims(j));
            case 'tste'
                mappedX = tste(train_triplets, no_dims(j));
        end
        
        % Measure test error in embedding
        sum_X = sum(mappedX .^ 2, 2);
        D = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (mappedX * mappedX')));
        no_viol = sum(D(sub2ind([N N], test_triplets(:,1), test_triplets(:,2))) > ...
            D(sub2ind([N N], test_triplets(:,1), test_triplets(:,3))));
        disp(['Test error: ' num2str(no_viol ./ size(test_triplets, 1))]);
        err(i, j, fold) = no_viol ./ size(test_triplets, 1);
    end
end

% Plot performance graph
save 'results/mnist_results.mat' err technique_names no_dims params
line_style = {'b--', 'b-', 'g--', 'g-', 'r--', 'r-', 'c-'};
figure(1);
for i=1:size(err, 1)
    plot(no_dims, mean(err(i,:,:), 3), line_style{i}); hold on
end
hold off
legend(technique_names);
xlabel('Dimensionality');
ylabel('Generalization error');
drawnow, pause(.2)
exportfig(gcf, 'plots/mnist_results.eps', 'Format', 'eps', 'Color', 'rgb');
