%FACE_EXPERIMENT Performs experiments on face triplet data with triplet embedding
%
%   face_experiment
%
% The function performs experiments with various triplet embedding
% techniques on the faceTriplet data set, measuring triplet generalization
% errors.


%% Load raw data
disp('Loading raw data...');
load('data/faceTriplet.mat');

%% Split training and test data
sampleSize = size(faceTriplet, 1);
trainRatio = 0.9; 
trainNum = sampleSize * trainRatio; 
trainInd = randperm(sampleSize, trainNum);
testInd = 1:sampleSize; testInd(trainInd)=[];

%% Initialize some variables for experiments
no_folds = 10;
no_dims = 2:2:30;
no_triplets = size(triplets, 1);
techniques = {'gnmds_k', 'gnmds_x', 'ckl_k', 'ckl_x', 'ste_k', 'ste_x', 'tste'};
technique_names = {'GNMDS - K', 'GNMDS - X', 'CKL - K', 'CKL - X', 'STE - K', 'STE - X', 't-STE - X'};
params = nan(length(techniques), 1);
assert(length(techniques) == length(technique_names));
err = nan(length(techniques), length(no_dims), no_folds);
fold_ind = 1;
fold_size = round(no_triplets ./ no_folds);
perm = randperm(no_triplets);

% Perform cross-validation for kernel learners
for i=1:length(techniques)
    if any(strcmpi(techniques{i}, {'gnmds_k', 'ckl_k', 'ckl_x', 'ste_k'}))
        
        % Prepare for cross-validation over parameters of kernel learners
        if any(strcmpi(techniques{i}, {'gnmds_k', 'ste_k'}))
            mu = [.02:.02:.1 .2:.1:.9 .9:.02:.98];
        else
            mu = 0:.01:.1;
        end
        tmp_err = nan(length(mu), 1);
        train_triplets = triplets(1:fold_size,:);
        test_triplets = triplets(1+fold_size:end,:);
        
        % Perform cross-validation
        for j=1:length(mu)
            switch techniques{i}
                case 'gnmds_k'
                    K = gnmds_k(train_triplets, mu(j));
                case 'ckl_k'
                    K = ckl_k(train_triplets, mu(j));
                case 'ckl_x'
                    mappedX = ckl_x(train_triplets, max(no_dims), mu(j));
                    K = mappedX * mappedX';
                case 'ste_k'
                    K = ste_k(train_triplets, mu(j));
            end
            
            % Compute errors
            D = bsxfun(@plus, bsxfun(@plus, -2 .* K, diag(K)), diag(K)');
            tmp_err(j) = sum(D(sub2ind([N N], test_triplets(:,1), test_triplets(:,2))) > ...
                D(sub2ind([N N], test_triplets(:,1), test_triplets(:,3))));
        end
        
        % Select optimal value of parameter (based on full kernel)
        [~, ind] = min(tmp_err);
        params(i) = mu(ind);
    end
end

% Loop over folds
for fold=1:no_folds
    
    % Split triplets into training and test data
    train_ind = perm([1:fold_ind - 1 fold_ind + fold_size:end]);
    test_ind  = perm(fold_ind:min(fold_ind + fold_size - 1, length(perm)));
    train_triplets = triplets(train_ind,:);
    test_triplets = triplets( test_ind,:);
    fold_ind = fold_ind + fold_size;
    
    % Loop over techniques
    for i=1:length(techniques)
        
        % Perform kernel learning only once
        switch techniques{i}
            case 'gnmds_k'
                K = gnmds_k(train_triplets, params(i));
            case 'ckl_k'
                K = ckl_k(train_triplets, params(i));
            case 'ste_k'
                K = ste_k(train_triplets, params(i));
        end
        
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
