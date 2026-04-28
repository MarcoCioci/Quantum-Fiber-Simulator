function plot_phase_baseline_tensor(results_phase_baseline)
% PLOT_PHASE_BASELINE_TENSOR  Plot Experiment 1 full Pauli correlation tensor.
%
% Objective:
%   Plot all nine entries of the two-qubit Pauli correlation tensor
%
%       T_ij(theta) = <sigma_i tensor sigma_j>
%
%   as functions of the reduced phase parameter theta.
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .correlation_tensor
%       .analytical.correlation_tensor
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_values', ...
                       'correlation_tensor', ...
                       'analytical'};

    for k = 1:length(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_tensor:MissingField', ...
                'Field "%s" not found.', required_fields{k});
        end
    end

    if ~isfield(results_phase_baseline.analytical, 'correlation_tensor')
        error('plot_phase_baseline_tensor:MissingAnalyticalField', ...
            'Analytical field "correlation_tensor" not found.');
    end


    % =========================
    % Extract data
    % =========================

    theta = results_phase_baseline.theta_values(:).';

    T_num = real(results_phase_baseline.correlation_tensor);
    T_th = real(results_phase_baseline.analytical.correlation_tensor);

    N = numel(theta);

    if ~isequal(size(T_num), [3, 3, N])
        error('plot_phase_baseline_tensor:InvalidNumericalTensorSize', ...
            'correlation_tensor must have size 3x3xN.');
    end

    if ~isequal(size(T_th), [3, 3, N])
        error('plot_phase_baseline_tensor:InvalidAnalyticalTensorSize', ...
            'analytical.correlation_tensor must have size 3x3xN.');
    end

    if any(~isfinite(theta)) || ...
       any(~isfinite(T_num(:))) || ...
       any(~isfinite(T_th(:)))
        error('plot_phase_baseline_tensor:InvalidValues', ...
            'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();

    y_min = -1.05;
    y_max = 1.05;

    analytical_line_width = 1.8;
    numerical_marker_size = 4;


    % =========================
    % Figure metadata
    % =========================

    % figure_filename = 'experiment_1_correlation_tensor.png';


    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 1 — Correlation Tensor | deterministic phase sweep');

    tiledlayout(3, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    labels = {'x', 'y', 'z'};


    % =========================
    % Tensor entries
    % =========================

    for i = 1:3
        for j = 1:3

            nexttile;
            hold on;
            grid on;
            box on;

            values_num = squeeze(T_num(i, j, :)).';
            values_th = squeeze(T_th(i, j, :)).';
            
            color_analytical = palette.blue;
            color_numerical = palette.orange;

            plot(theta, values_th, ...
            'LineWidth', analytical_line_width, ...
            'Color', color_analytical);

            plot(theta, values_num, 'o', ...
            'MarkerSize', numerical_marker_size, ...
            'MarkerFaceColor', color_numerical, ...
            'MarkerEdgeColor', palette.black);

            set(gca, 'Layer', 'top');  % grid behind data

            title(sprintf('$T_{%s%s}$', labels{i}, labels{j}), ...
                  'Interpreter', 'latex');

            ylabel(sprintf('$T_{%s%s}$', labels{i}, labels{j}), ...
                   'Interpreter', 'latex');

            ylim([y_min, y_max]);

            if i == 3
                xlabel('$\theta$', 'Interpreter', 'latex');
            end

            if i == 1 && j == 1
                legend({'analytical', 'numerical'}, ...
                       'Location', 'southoutside', ...
                       'Orientation', 'horizontal');
            end

        end
    end


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 1 — Correlation Tensor | deterministic phase sweep', ...
            'FontWeight', 'bold');


    % =========================
    % Figure-level annotations
    % =========================

    annotation(fig, 'textbox', ...
        [0.74, 0.005, 0.24, 0.03], ...
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'EdgeColor', palette.gray_light, ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

end