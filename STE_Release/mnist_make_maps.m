%MNIST_MAKE_MAPS Makes 2D maps of MNIST data set using triplet embedding
%
%   mnist_make_maps
%
% The function makes 2D maps of the MNIST data set using various triplet 
% embedding techniques.


    addpath(genpath('drtoolbox'));
    
    % Load training data
    disp('Loading training data...');
    load 'data/mnist_train.mat'
    [~, ~, labels] = unique(train_labels);
    clear train_labels
    
    % Perform PCA
    no_dims = 50;
    X = compute_mapping(train_X, 'PCA', no_dims);
    
    % Select small subset of the data
    N = 5000;
    perm = randperm(size(X, 1));
    X = X(perm(1:N),:);
    train_X = train_X(perm(1:N),:);
    labels = labels(perm(1:N));
    [labels, sort_ind] = sort(labels);
    X = X(sort_ind,:);
    train_X = train_X(sort_ind,:);
    K = length(unique(labels));    
    no_triplets = 1000000;
    
    % Compute pairwise distance matrix
    disp('Computing pairwise distances...');
    sum_X2 = sum(X .^ 2, 2);
    DD = bsxfun(@plus, sum_X2, bsxfun(@plus, sum_X2', -2 * (X * X')));
    [~, sort_ind] = sort(DD, 2, 'ascend');

    % Generate unsupervised triplets
    disp('Generating unsupervised triplets...');        
    max_away = round(N / 20);
    triplets = zeros(max(no_triplets), 3);
    for i=1:max(no_triplets)
        ind1 = randi(N);
        ind2 = randi(max_away);
        ind3 = min(N, ind2 + randi(max_away));
        ind2 = sort_ind(ind1, ind2);
        ind3 = sort_ind(ind1, ind3);
        triplets(i,:) = [ind1 ind2 ind3];
    end    

    % Run all techniques on full training data to construct maps
    tech = {'gnmds_x', 'ckl_x', 'ste', 'tste'};
    for tech_no=1:length(tech)
        
        % Construct embedding
        if strcmpi(tech{tech_no}, 'ckl_x')
            mappedX = ckl_x(triplets, 2, .05);
        else
            eval(['mappedX = ' tech{tech_no} '(triplets, 2);']);
        end
        mappedX = bsxfun(@minus,   mappedX, min(mappedX, [], 1));
        mappedX = bsxfun(@rdivide, mappedX, max(mappedX, [], 1));
    
        % Make map of digits
        figure(2);
        h = gscatter(mappedX(:,1), mappedX(:,2), labels, [], [], 9);
        set(gcf, 'Position', [232 -17 1031 801]);
        axis off
        legend(h, {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'});
        drawnow, pause(.2)
        exportfig(gcf, ['plots/mnist_' tech{tech_no} '_map.eps'], 'Format', 'eps', 'Color', 'rgb');    
    
        % Compute nearest neighbor error in map
        sum_X = sum(mappedX .^ 2, 2);
        D = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 .* (mappedX * mappedX')));
        [~, sort_ind] = sort(D, 2, 'ascend');
        err = sum(labels(sort_ind(:,2)) ~= labels) ./ N;
        disp(['Nearest neighbor error in map: ' num2str(err)]);
    
        % Make nice digit map
        s = 4000;
        bitmap = repmat(uint8(255), [s + 50 s + 50]);
        for i=1:size(mappedX, 1)
            imag = uint8(round(reshape(~train_X(i,:), [28 28])' * 255));
            [h, w, c] = size(imag);
                bitmap(floor(mappedX(i, 1) * s) + 1:floor(mappedX(i, 1) * s) + h, floor(mappedX(i, 2) * s) + 1:floor(mappedX(i, 2) * s) + w) = ...
            min(bitmap(floor(mappedX(i, 1) * s) + 1:floor(mappedX(i, 1) * s) + h, floor(mappedX(i, 2) * s) + 1:floor(mappedX(i, 2) * s) + w), imag);
        end 
        figure
        imshow(bitmap);
        drawnow
        imwrite(bitmap, ['plots/mnist_' tech{tech_no} '_map_large.png']);
    end
    