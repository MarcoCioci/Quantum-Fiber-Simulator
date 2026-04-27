function plot_correlation_tensor_snapshot(results_current)
% PLOT_CORRELATION_TENSOR_SNAPSHOT  Visualize the Pauli correlation tensor for one experiment case.
%
% Objective:
%   Plot the 3x3 two-qubit Pauli correlation tensor.
%
%   Each tensor entry is the expectation value of a local Pauli-product
%   observable:
%
%       T(i,j) = expectation value of sigma_i on subsystem A
%                jointly with sigma_j on subsystem B
%
%   where i,j belong to {x,y,z}.
%
%   If an analytical tensor is available, the function displays a
%   numerical/analytical comparison together with the absolute error.
%
% Input:
%   results_current - structure containing:
%       .correlation_tensor                 - numerical 3x3 correlation tensor
%       .analytical.correlation_tensor      - analytical 3x3 tensor [optional]
%       .case_label                         - case label used in the title [optional]
%
% Output:
%   None
%
% Notes:
%   - Designed for Experiment 2 snapshots, where one result corresponds to
%     one ensemble distribution or one sampled phase-noise configuration.
%   - Color scale is fixed to [-1, 1] because Pauli correlations are bounded.
%   - Only the real part is plotted, since expectation values of Hermitian
%     observables should be real up to numerical roundoff.

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

    has_analytical = isfield(results_current, 'analytical') && ...
                     isstruct(results_current.analytical) && ...
                     isfield(results_current.analytical, 'correlation_tensor');

    if has_analytical
        T_theory = real(results_current.analytical.correlation_tensor);

        if ~isnumeric(T_theory) || ~isequal(size(T_theory), [3, 3])
            error('plot_correlation_tensor_snapshot:InvalidAnalyticalTensorSize', ...
                  'analytical.correlation_tensor must be a numeric 3x3 matrix.');
        end

        if any(~isfinite(T_theory(:)))
            error('plot_correlation_tensor_snapshot:InvalidAnalyticalTensorValues', ...
                  'analytical.correlation_tensor must contain only finite values.');
        end

        T_error = abs(T_num - T_theory);
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
        title_string = sprintf('Experiment 2 — Correlation Tensor | %s', case_label);
    else
        title_string = 'Experiment 2 — Correlation Tensor';
    end


    % =========================
    % Figure
    % =========================

    figure('Name', title_string);

    if has_analytical

        tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

        nexttile;
        plot_single_tensor_heatmap(T_num, axis_labels, 'Numerical tensor', [-1, 1], palette);

        nexttile;
        plot_single_tensor_heatmap(T_theory, axis_labels, 'Analytical tensor', [-1, 1], palette);

        nexttile;
        error_upper_limit = max(1e-12, max(T_error(:)));
        plot_single_tensor_heatmap(T_error, axis_labels, 'Absolute error', [0, error_upper_limit], palette);

    else

        plot_single_tensor_heatmap(T_num, axis_labels, 'Numerical tensor', [-1, 1], palette);

    end

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
    title(plot_title);

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