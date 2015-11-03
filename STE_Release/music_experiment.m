%MUSIC_EXPERIMENT Performs experiments on music data with triplet embedding
%
%   music_experiment
%
% The function performs experiments with various triplet embedding
% techniques on the music aset400 data set, measuring triplet generalization
% errors.


    
    % Load all data
    load 'data/music_kernels.mat'
    load 'data/music_triplets.mat'
    load 'data/music_labels.mat'
    addpath(genpath('drtoolbox'));
   
    % Relabel triplets in [1...N]
    no_triplets = size(triplets, 1);
    [included, ~, triplets] = unique(triplets(:));
    triplets = reshape(triplets, [no_triplets 3]);
    names = names(included);                                                % remove artists without triplets
    label_matrix = label_matrix(included,:);
     
    % Label artists according to superclasses
    super_classes = {'rock', 'metal', 'pop', 'dance', 'hiphop', 'jazz', 'country', 'reggae'};
    super_class_list = [5 1 1 1 1 1 1 1 5 3 3 3 3 2 1 1 4 4 4 1 4 7 7 4 1 2 2 1 5 6 6 6 8 1 3 4 4 1 3 1 2 2 1 7 7 1 1 1 1 1 4 5 2 3 6 2 2 5];
    new_label_matrix = zeros(size(label_matrix, 1), length(super_classes));
    for k=1:length(super_classes)
        new_label_matrix(:,k) = any(label_matrix(:,super_class_list == k) == 1, 2);
    end
    label_matrix = new_label_matrix;
    labels = (length(super_classes) + 1) .* ones(size(label_matrix, 1), 1);
    for i=1:size(label_matrix, 1)
        if any(label_matrix(i,:) == 1)
            labels(i) = find(label_matrix(i,:) == 1, 1, 'first');
        end
    end
    super_classes{end + 1} = 'other';
    
    % Initialize some variables for experiments
    no_folds = 10;
    no_dims = 2:2:30;
    N = length(included);
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
                mu = [0:.01:.05 .075:.025:.2 .3:.1:.8 .825:.025:.95 .96:.01:1];
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
            
            % Select optimal value of parameter (based on full kernel!)
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
    save 'results/music_results.mat' err technique_names no_dims params
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
    exportfig(gcf, 'plots/music_results.eps', 'Format', 'eps', 'Color', 'rgb');
