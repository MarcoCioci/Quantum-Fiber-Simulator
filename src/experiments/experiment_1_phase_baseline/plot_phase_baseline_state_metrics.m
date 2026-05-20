function plot_phase_baseline_state_metrics(results_phase_baseline, do_save)
% PLOT_PHASE_BASELINE_STATE_METRICS  Plot Experiment 1 state metrics vs analytical expectations.
%
% Objective:
%   Compare the numerical state-characterization quantities of Experiment 1
%   with the analytical predictions stored in the experiment results
%   structure.
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .purity_global
%       .purity_A
%       .purity_B
%       .fidelity_psi_plus
%       .concurrence
%       .analytical.purity_global
%       .analytical.purity_A
%       .analytical.purity_B
%       .analytical.fidelity_psi_plus
%       .analytical.concurrence
%
%   do_save (optional) - logical flag to enable figure saving (default: false)
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_phase_baseline_state_metrics:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_phase_baseline_state_metrics:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_phase_baseline)
        error('plot_phase_baseline_state_metrics:InvalidInputType', ...
              'results_phase_baseline must be a structure.');
    end

    required_fields = {'theta_values', ...
                       'purity_global', ...
                       'purity_A', ...
                       'purity_B', ...
                       'fidelity_psi_plus', ...
                       'concurrence', ...
                       'analytical'};

    for k = 1:numel(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_state_metrics:MissingField', ...
                  'Field "%s" not found.', required_fields{k});
        end
    end

    required_analytical_fields = {'purity_global', ...
                                  'purity_A', ...
                                  'purity_B', ...
                                  'fidelity_psi_plus', ...
                                  'concurrence'};

    for k = 1:numel(required_analytical_fields)
        if ~isfield(results_phase_baseline.analytical, required_analytical_fields{k})
            error('plot_phase_baseline_state_metrics:MissingAnalyticalField', ...
                  'Analytical field "%s" not found.', required_analytical_fields{k});
        end
    end


    % =========================
    % Extract data
    % =========================

    data.theta = results_phase_baseline.theta_values(:).';

    data.purity_global = real(results_phase_baseline.purity_global(:).');
    data.purity_A = real(results_phase_baseline.purity_A(:).');
    data.purity_B = real(results_phase_baseline.purity_B(:).');
    data.fidelity_psi_plus = real(results_phase_baseline.fidelity_psi_plus(:).');
    data.concurrence = real(results_phase_baseline.concurrence(:).');

    data.purity_global_th = real(results_phase_baseline.analytical.purity_global(:).');
    data.purity_A_th = real(results_phase_baseline.analytical.purity_A(:).');
    data.purity_B_th = real(results_phase_baseline.analytical.purity_B(:).');
    data.fidelity_psi_plus_th = real(results_phase_baseline.analytical.fidelity_psi_plus(:).');
    data.concurrence_th = real(results_phase_baseline.analytical.concurrence(:).');

    if isempty(data.theta)
        error('plot_phase_baseline_state_metrics:EmptyTheta', ...
              'theta_values must not be empty.');
    end

    if ~isnumeric(data.theta) || ...
       ~isnumeric(data.purity_global) || ~isnumeric(data.purity_A) || ...
       ~isnumeric(data.purity_B) || ~isnumeric(data.fidelity_psi_plus) || ...
       ~isnumeric(data.concurrence) || ...
       ~isnumeric(data.purity_global_th) || ~isnumeric(data.purity_A_th) || ...
       ~isnumeric(data.purity_B_th) || ~isnumeric(data.fidelity_psi_plus_th) || ...
       ~isnumeric(data.concurrence_th)
        error('plot_phase_baseline_state_metrics:InvalidDataType', ...
              'All plotted quantities must be numeric arrays.');
    end

    if numel(data.theta) ~= numel(data.purity_global) || ...
       numel(data.theta) ~= numel(data.purity_A) || ...
       numel(data.theta) ~= numel(data.purity_B) || ...
       numel(data.theta) ~= numel(data.fidelity_psi_plus) || ...
       numel(data.theta) ~= numel(data.concurrence) || ...
       numel(data.theta) ~= numel(data.purity_global_th) || ...
       numel(data.theta) ~= numel(data.purity_A_th) || ...
       numel(data.theta) ~= numel(data.purity_B_th) || ...
       numel(data.theta) ~= numel(data.fidelity_psi_plus_th) || ...
       numel(data.theta) ~= numel(data.concurrence_th)
        error('plot_phase_baseline_state_metrics:InconsistentLengths', ...
              ['theta_values, numerical metrics, and analytical metrics ', ...
               'must have the same length.']);
    end

    if any(~isfinite(data.theta)) || ...
       any(~isfinite(data.purity_global)) || ...
       any(~isfinite(data.purity_A)) || ...
       any(~isfinite(data.purity_B)) || ...
       any(~isfinite(data.fidelity_psi_plus)) || ...
       any(~isfinite(data.concurrence)) || ...
       any(~isfinite(data.purity_global_th)) || ...
       any(~isfinite(data.purity_A_th)) || ...
       any(~isfinite(data.purity_B_th)) || ...
       any(~isfinite(data.fidelity_psi_plus_th)) || ...
       any(~isfinite(data.concurrence_th))
        error('plot_phase_baseline_state_metrics:InvalidValues', ...
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
        'State metrics', ...
        'Experiment 1 — Deterministic Phase Sweep', ...
        style);

    build_phase_baseline_state_metrics_plot(tab, data, style, palette, false);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        output_path = '/home/marcocioci/HPC/THESIS-Quantum-Communications/Quantum-Fiber-Simulator/images/experiment_1/experiment_1_state_metrics.png';

        export_plot(output_path, ...
            @(parent) build_phase_baseline_state_metrics_plot(parent, data, style, palette, false), ...
            style);
    end


    % =========================
    % Show figure
    % =========================

    set(fig, 'Visible', style.figure.visible_after_build);

end


function tl = build_phase_baseline_state_metrics_plot(parent, data, style, palette, show_title)
% BUILD_PHASE_BASELINE_STATE_METRICS_PLOT  Build Experiment 1 state metrics plot.
%
% Objective:
%   Construct the tiledlayout containing γ, F, and C metric comparisons.
%
% Input:
%   parent     - parent container for the tiledlayout
%   data       - structure containing numerical and analytical state metrics
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
    % Common limits
    % =========================

    theta = data.theta;

    y_limits = style.axes.metric_limits;
    x_limits = [min(theta), max(theta)];


    % =========================
    % Layout
    % =========================

    tl = tiledlayout(parent, 3, 2, ...
        'TileSpacing', style.layout.tile_spacing, ...
        'Padding', style.layout.padding);


    % =========================
    % Global purity
    % =========================

    ax = nexttile(tl);
    plot_metric_panel(ax, ...
        theta, data.purity_global, data.purity_global_th, ...
        '$\gamma(\rho_{AB})$', palette.metric_global, ...
        x_limits, y_limits, style, palette, true);


    % =========================
    % Reduced purity A
    % =========================

    ax = nexttile(tl);
    plot_metric_panel(ax, ...
        theta, data.purity_A, data.purity_A_th, ...
        '$\gamma(\rho_A)$', palette.metric_A, ...
        x_limits, y_limits, style, palette, false);


    % =========================
    % Reduced purity B
    % =========================

    ax = nexttile(tl);
    plot_metric_panel(ax, ...
        theta, data.purity_B, data.purity_B_th, ...
        '$\gamma(\rho_B)$', palette.metric_B, ...
        x_limits, y_limits, style, palette, false);


    % ================================
    % Fidelity with respect to |Ψ⁺⟩
    % ================================

    ax = nexttile(tl);
    plot_metric_panel(ax, ...
        theta, data.fidelity_psi_plus, data.fidelity_psi_plus_th, ...
        '$F_{\Psi^+}$', palette.metric_F, ...
        x_limits, y_limits, style, palette, false);


    % =========================
    % Concurrence
    % =========================

    ax = nexttile(tl);
    plot_metric_panel(ax, ...
        theta, data.concurrence, data.concurrence_th, ...
        '$C$', palette.metric_C, ...
        x_limits, y_limits, style, palette, false);


    % =========================
    % Global title
    % =========================

    if show_title
        title(tl, ...
            'Experiment 1 — State Metrics | fixed-phase sweep', ...
            'FontSize', style.title.font_size, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);
    end

end


function plot_metric_panel(ax, theta, metric_num, metric_th, y_label, color, ...
                           x_limits, y_limits, style, palette, do_legend)
% PLOT_METRIC_PANEL  Plot one state-metric panel.
%
% Objective:
%   Plot analytical and numerical values of one state metric.
%
% Input:
%   ax         - axes handle
%   theta      - phase grid θ
%   metric_num - numerical metric values
%   metric_th  - analytical metric values
%   y_label    - y-axis label
%   color      - RGB color triplet
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

    plot(ax, theta, metric_th, ...
        'LineWidth', style.lines.width_main, ...
        'Color', color);

    plot(ax, theta, metric_num, 'o', ...
        'MarkerSize', style.markers.size, ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', palette.gray_dark, ...
        'LineWidth', style.markers.edge_width);


    % =========================
    % Labels and limits
    % =========================

    xlabel(ax, '$\theta$', ...
        'Interpreter', style.labels.interpreter, ...
        'FontSize', style.labels.font_size_axis);

    ylabel(ax, y_label, ...
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