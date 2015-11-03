function plot_gradients2
%PLOT_GRADIENTS2 Plots gradients of a range of triplet embedding techniques

    close all
    figure;

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
    cmin = min(min(min(grad1(:)), min(grad2(:))), min(grad3(:)));
    cmax = max(max(max(grad1(:)), max(grad2(:))), max(grad3(:)));
    imagesc(grad1, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'gnmds_x1.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad2, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'gnmds_x2.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad3, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'gnmds_x3.eps'], 'Format', 'eps', 'Color', 'rgb');    
    
    % Plot gradients for CKL
    for i=1:numel(x2)
        [~, dC] = ckl_x_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], .05);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    cmin = min(min(min(grad1(:)), min(grad2(:))), min(grad3(:)));
    cmax = max(max(max(grad1(:)), max(grad2(:))), max(grad3(:)));
    imagesc(grad1, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ckl_x1.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad2, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ckl_x2.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad3, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ckl_x3.eps'], 'Format', 'eps', 'Color', 'rgb');    
    
    % Plot gradients for STE
    for i=1:numel(x2)
        [~, dC] = ste_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], 0, false);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    cmin = min(min(min(grad1(:)), min(grad2(:))), min(grad3(:)));
    cmax = max(max(max(grad1(:)), max(grad2(:))), max(grad3(:)));
    imagesc(grad1, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ste_x1.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad2, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ste_x2.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad3, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'ste_x3.eps'], 'Format', 'eps', 'Color', 'rgb');    
    
    % Plot gradients for t-STE
    for i=1:numel(x2)
        [~, dC] = tste_grad([x1; x2(i); x3(i)], 3, 1, [1 2 3], 0, 1, false);
        grad1(i) = dC(1); grad2(i) = dC(2); grad3(i) = dC(3);
    end
    cmin = min(min(min(grad1(:)), min(grad2(:))), min(grad3(:)));
    cmax = max(max(max(grad1(:)), max(grad2(:))), max(grad3(:)));
    imagesc(grad1, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'tste_x1.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad2, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'tste_x2.eps'], 'Format', 'eps', 'Color', 'rgb');    
    imagesc(grad3, [cmin cmax]); xlabel('d(x1, x2) >'); ylabel('d(x1, x3) >'); set(gca, 'XTickLabel', [0 10], 'YTickLabel', [10 0], 'XTick', [1 size(x2, 2)], 'YTick', [1 size(x2, 1)]);
    drawnow; pause(2); exportfig(gcf, ['gradient_plots' filesep 'tste_x3.eps'], 'Format', 'eps', 'Color', 'rgb');    
    