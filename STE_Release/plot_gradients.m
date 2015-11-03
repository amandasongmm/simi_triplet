function plot_gradients
%PLOT_GRADIENTS Plots gradients of a range of triplet embedding techniques


    % Generate all triplets
    x1 = 0;
    [x2, x3] = meshgrid(0:.05:10, 10:-.05:0);
    grad1 = zeros(size(x2));
    grad2 = zeros(size(x2));
    grad3 = zeros(size(x2));

    % Plot gradients for GNMDS
    for i=1:numel(x2)
        [~, dC] = gnmds_x_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], 'hinge', 0);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    figure(1);
    subplot(1, 3, 1); imagesc(grad1); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 2); imagesc(grad2); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 3); imagesc(grad3); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow 
    set(gcf, 'Position', [2 549 1439 235]); pause(.05);
    
    % Plot gradients for CKL
    for i=1:numel(x2)
        [~, dC] = ckl_x_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], .05);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    figure(2);
    subplot(1, 3, 1); imagesc(grad1); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 2); imagesc(grad2); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 3); imagesc(grad3); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow
    set(gcf, 'Position', [2 549 1439 235]); pause(.05);
    
    % Plot gradients for STE
    for i=1:numel(x2)
        [~, dC] = ste_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], 0, false);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    figure(3);
    subplot(1, 3, 1); imagesc(grad1); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 2); imagesc(grad2); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 3); imagesc(grad3); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow
    set(gcf, 'Position', [2 549 1439 235]); pause(.05);
    
    % Plot gradients for t-STE
    for i=1:numel(x2)
        [~, dC] = tste_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], 0, 1, false);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    figure(4);
    subplot(1, 3, 1); imagesc(grad1); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 2); imagesc(grad2); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    subplot(1, 3, 3); imagesc(grad3); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); colorbar; set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow
    set(gcf, 'Position', [2 549 1439 235]); pause(.05);
    