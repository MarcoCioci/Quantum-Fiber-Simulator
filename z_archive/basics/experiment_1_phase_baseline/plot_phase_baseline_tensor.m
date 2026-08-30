function plot_phase_baseline_tensor(results_phase_baseline, do_save)
% PLOT_PHASE_BASELINE_TENSOR  Plot Experiment 1 full Pauli correlation tensor.
%
% Objective:
%   Plot all nine entries of the two-qubit Pauli correlation tensor
%
%       T_ij(θ) = ⟨σ_i ⊗ σ_j⟩
%
%   as functions of the reduced phase parameter θ.
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .correlation_tensor
%       .analytical.correlation_tensor
%
%   do_save (optional) - logical flag to enable figure saving (default: false)
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_phase_baseline_tensor:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_phase_baseline_tensor:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_phase_baseline)
        error('plot_phase_baseline_tensor:InvalidInputType', ...
              'results_phase_baseline must be a structure.');
    end

    required_fields = {'theta_values', ...
                       'correlation_tensor', ...
                       'analytical'};

    for k = 1:numel(required_fields)
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

    data.theta = results_phase_baseline.theta_values(:).';

    data.T_num = real(results_phase_baseline.correlation_tensor);
    data.T_th  = real(results_phase_baseline.analytical.correlation_tensor);

    N = numel(data.theta);

    if isempty(data.theta)
        error('plot_phase_baseline_tensor:EmptyTheta', ...
              'theta_values must not be empty.');
    end

    if ~isnumeric(data.theta) || ~isnumeric(data.T_num) || ~isnumeric(data.T_th)
        error('plot_phase_baseline_tensor:InvalidDataType', ...
              'theta_values and correlation tensors must be numeric arrays.');
    end

    if ~isequal(size(data.T_num), [3, 3, N])
        error('plot_phase_baseline_tensor:InvalidNumericalTensorSize', ...
              'correlation_tensor must have size 3x3xN.');
    end

    if ~isequal(size(data.T_th), [3, 3, N])
        error('plot_phase_baseline_tensor:InvalidAnalyticalTensorSize', ...
              'analytical.correlation_tensor must have size 3x3xN.');
    end

    if any(~isfinite(data.theta)) || ...
       any(~isfinite(data.T_num(:))) || ...
       any(~isfinite(data.T_th(:)))
        error('plot_phase_baseline_tensor:InvalidValues', ...
              'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();
    style   = get_plot_style();


    % =========================
    % Figure and tab
    % =========================

    [fig, tab] = get_experiment_figure_tab( ...
        style.figure.experiment_1_id, ...
        'Correlation tensor', ...
        'Experiment 1 — Deterministic Phase Sweep', ...
        style);

    build_phase_baseline_tensor_plot(tab, data, style, palette, false);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        output_path = '/home/marcocioci/HPC/THESIS-Quantum-Communications/Quantum-Fiber-Simulator/images/experiment_1/experiment_1_correlation_tensor.png';

        export_plot(output_path, ...
            @(parent) build_phase_baseline_tensor_plot(parent, data, style, palette, false), ...
            style);
    end


    % =========================
    % Show figure
    % =========================

    set(fig, 'Visible', style.figure.visible_after_build);

end


function tl = build_phase_baseline_tensor_plot(parent, data, style, palette, show_title)
% BUILD_PHASE_BASELINE_TENSOR_PLOT  Build Experiment 1 correlation tensor plot.
%
% Objective:
%   Construct the 3x3 tiledlayout containing all entries T_ij(θ).
%
% Input:
%   parent     - parent container for the tiledlayout
%   data       - structure containing numerical and analytical tensor entries
%   style      - plot style structure
%   palette    - plot color palette
%   show_title - logical flag controlling global tiledlayout title
%
% Output:
%   tl - tiledlayout handle

    % =========================
    % Robustness checks
    % =========================

    if nargin < 5
        show_title = false;
    end


    % =========================
    % Common settings
    % =========================

    labels = {'x', 'y', 'z'};

    theta = data.theta;
    T_num = data.T_num;
    T_th  = data.T_th;

    x_limits = [min(theta), max(theta)];
    y_limits = style.axes.correlation_limits;


    % =========================
    % Layout
    % =========================

    tl = tiledlayout(parent, 3, 3, ...
        'TileSpacing', style.layout.tile_spacing, ...
        'Padding', style.layout.padding);


    % =========================
    % Tensor entries
    % =========================

    for i = 1:3
        for j = 1:3

            ax = nexttile(tl);

            values_num = squeeze(T_num(i, j, :)).';
            values_th  = squeeze(T_th(i, j, :)).';

            do_legend = (i == 1 && j == 1);

            plot_tensor_entry_panel(ax, ...
                theta, values_num, values_th, ...
                labels{i}, labels{j}, ...
                x_limits, y_limits, ...
                style, palette, ...
                do_legend);

        end
    end

    % =========================
    % Global title
    % =========================

    if show_title
        title(tl, ...
            'Experiment 1 — Correlation Tensor | fixed-phase sweep', ...
            'FontSize', style.title.font_size, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);
    end

end


function plot_tensor_entry_panel(ax, theta, values_num, values_th, ...
                                 row_label, col_label, ...
                                 x_limits, y_limits, ...
                                 style, palette, ...
                                 do_legend)
% PLOT_TENSOR_ENTRY_PANEL  Plot one correlation tensor entry.
%
% Objective:
%   Plot analytical and numerical values of one Pauli tensor entry T_ij(θ).
%
% Input:
%   ax         - axes handle
%   theta      - phase grid θ
%   values_num - numerical tensor entry values
%   values_th  - analytical tensor entry values
%   row_label  - first Pauli index label
%   col_label  - second Pauli index label
%   x_limits   - x-axis limits
%   y_limits   - y-axis limits
%   style      - plot style structure
%   palette    - plot color palette
%   do_legend  - logical flag controlling legend creation
%
% Output:
%   None

    % =========================
    % Plot
    % =========================

    hold(ax, 'on');
    grid(ax, style.axes.grid);
    box(ax, style.axes.box);

    plot(ax, theta, values_th, ...
        'LineWidth', style.lines.width_main, ...
        'Color', palette.analytical);

    plot(ax, theta, values_num, 'o', ...
        'MarkerSize', style.markers.size, ...
        'MarkerFaceColor', palette.analytical, ...
        'MarkerEdgeColor', palette.gray_dark, ...
        'LineWidth', style.markers.edge_width);


    % =========================
    % Labels and limits
    % =========================

    ylabel(ax, sprintf('$T_{%s%s}$', row_label, col_label), ...
        'Interpreter', style.labels.interpreter, ...
        'FontSize', style.labels.font_size_axis);

    xlabel(ax, '$\theta$', ...
        'Interpreter', style.labels.interpreter, ...
        'FontSize', style.labels.font_size_axis);

    ylim(ax, y_limits);
    xlim(ax, x_limits);


    % =========================
    % Axes style
    % =========================

    set(ax, ...
        'FontSize', style.axes.font_size, ...
        'LineWidth', style.axes.line_width, ...
        'TickLabelInterpreter', style.axes.tick_label_interpreter, ...
        'Layer', style.axes.layer);


    % =========================
    % Legend
    % =========================

    if do_legend
        legend(ax, {'analytical', 'numerical'}, ...
            'Location', style.legend.location_south, ...
            'Orientation', 'horizontal', ...
            'Interpreter', style.legend.interpreter, ...
            'FontSize', style.legend.font_size);
    end

end