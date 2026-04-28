function plot_correlation_tensor_snapshot(results_current)
% PLOT_CORRELATION_TENSOR_SNAPSHOT  Visualize the numerical Pauli correlation tensor for one experiment case.
%
% Objective:
%   Plot only the numerical 3x3 two-qubit Pauli correlation tensor.
%
%   Each tensor entry is the expectation value of a local Pauli-product
%   observable:
%
%       T(i,j) = expectation value of sigma_i on subsystem A
%                jointly with sigma_j on subsystem B
%
%   where i,j belong to {x,y,z}.
%
% Input:
%   results_current - structure containing:
%       .correlation_tensor  - numerical 3x3 correlation tensor
%       .case_label          - case label used in the title [optional]
%
% Output:
%   None
%
% Notes:
%   - Designed for correlation-tensor snapshots of one experiment case.
%   - Color scale is fixed to [-1, 1] because Pauli correlations are bounded.
%   - Only the real part is plotted, since expectation values of Hermitian
%     observables should be real up to numerical roundoff.
%   - The interface is unchanged: analytical data, if present, is ignored.

    % =========================
    % Robustness checks
    % =========================

    if ~isstruct(results_current)
        error('plot_correlation_tensor_snapshot:InvalidInputType', ...
              'results_current must be a structure.');
    end

    if ~isfield(results_current, 'correlation_tensor')
        error('plot_correlation_tensor_snapshot:MissingField', ...
              'Field "correlation_tensor" not found.');
    end

    T_num = real(results_current.correlation_tensor);

    if ~isnumeric(T_num) || ~isequal(size(T_num), [3, 3])
        error('plot_correlation_tensor_snapshot:InvalidTensorSize', ...
              'correlation_tensor must be a numeric 3x3 matrix.');
    end

    if any(~isfinite(T_num(:)))
        error('plot_correlation_tensor_snapshot:InvalidTensorValues', ...
              'correlation_tensor must contain only finite values.');
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();


    % =========================
    % Plot labels
    % =========================

    axis_labels = {'x', 'y', 'z'};

    if isfield(results_current, 'case_label')
        case_label = char(results_current.case_label);
        title_string = sprintf('Experiment 2 — Numerical Correlation Tensor | %s', case_label);
    else
        title_string = 'Experiment 2 — Numerical Correlation Tensor';
    end


    % =========================
    % Figure
    % =========================

    figure('Name', title_string);

    plot_single_tensor_heatmap(T_num, axis_labels, '', [-1, 1], palette);

    sgtitle(title_string, 'FontWeight', 'bold');

end


function plot_single_tensor_heatmap(T, axis_labels, plot_title, color_limits, palette)
% PLOT_SINGLE_TENSOR_HEATMAP  Plot one 3x3 correlation tensor heatmap.

    imagesc(T);
    axis square;
    colorbar;
    caxis(color_limits);

    colormap(parula);

    set(gca, ...
        'XTick', 1:3, ...
        'XTickLabel', axis_labels, ...
        'YTick', 1:3, ...
        'YTickLabel', axis_labels, ...
        'XColor', palette.gray_dark, ...
        'YColor', palette.gray_dark);

    xlabel('Measurement axis on subsystem B');
    ylabel('Measurement axis on subsystem A');

    % ---- Removed axes title to avoid redundancy ----
    % title(plot_title);

    for row_idx = 1:3
        for col_idx = 1:3

            value = T(row_idx, col_idx);

            if abs(value) > 0.5 * max(abs(color_limits))
                text_color = 'w';
            else
                text_color = palette.gray_dark;
            end

            text(col_idx, row_idx, sprintf('%+.3f', value), ...
                 'HorizontalAlignment', 'center', ...
                 'Color', text_color, ...
                 'FontWeight', 'bold');

        end
    end

end