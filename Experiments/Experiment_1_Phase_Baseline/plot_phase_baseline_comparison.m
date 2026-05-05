function plot_phase_baseline_comparison(results_phase_baseline, do_save)
% PLOT_PHASE_BASELINE_COMPARISON  Plot Experiment 1 correlations vs analytical expectations.
%
% Objective:
%   Compare the numerical correlation observables of Experiment 1 with the
%   analytical predictions stored in the experiment results structure.
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .c_xx
%       .c_yy
%       .c_zz
%       .analytical.c_xx
%       .analytical.c_yy
%       .analytical.c_zz
%
%   do_save (optional) - logical flag to enable figure saving (default: false)
%
% Output:
%   None
%
% Notes:
%   - Analytical: continuous palette line
%   - Numerical: palette markers
%   - Three stacked panels with shared axis limits

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_phase_baseline_comparison:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_phase_baseline_comparison:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_phase_baseline)
        error('plot_phase_baseline_comparison:InvalidInputType', ...
              'results_phase_baseline must be a structure.');
    end

    required_fields = {'theta_values', 'c_xx', 'c_yy', 'c_zz', 'analytical'};

    for k = 1:numel(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_comparison:MissingField', ...
                  'Field "%s" not found.', required_fields{k});
        end
    end

    analytical_fields = {'c_xx', 'c_yy', 'c_zz'};

    for k = 1:numel(analytical_fields)
        if ~isfield(results_phase_baseline.analytical, analytical_fields{k})
            error('plot_phase_baseline_comparison:MissingAnalyticalField', ...
                  'Analytical field "%s" not found.', analytical_fields{k});
        end
    end


    % =========================
    % Extract data
    % =========================

    data.theta = results_phase_baseline.theta_values(:).';

    data.c_xx = real(results_phase_baseline.c_xx(:).');
    data.c_yy = real(results_phase_baseline.c_yy(:).');
    data.c_zz = real(results_phase_baseline.c_zz(:).');

    data.c_xx_th = real(results_phase_baseline.analytical.c_xx(:).');
    data.c_yy_th = real(results_phase_baseline.analytical.c_yy(:).');
    data.c_zz_th = real(results_phase_baseline.analytical.c_zz(:).');

    if isempty(data.theta)
        error('plot_phase_baseline_comparison:EmptyTheta', ...
              'theta_values must not be empty.');
    end

    if ~isnumeric(data.theta) || ...
       ~isnumeric(data.c_xx) || ~isnumeric(data.c_yy) || ~isnumeric(data.c_zz) || ...
       ~isnumeric(data.c_xx_th) || ~isnumeric(data.c_yy_th) || ~isnumeric(data.c_zz_th)
        error('plot_phase_baseline_comparison:InvalidDataType', ...
              'All plotted quantities must be numeric arrays.');
    end

    if numel(data.theta) ~= numel(data.c_xx) || ...
       numel(data.theta) ~= numel(data.c_yy) || ...
       numel(data.theta) ~= numel(data.c_zz) || ...
       numel(data.theta) ~= numel(data.c_xx_th) || ...
       numel(data.theta) ~= numel(data.c_yy_th) || ...
       numel(data.theta) ~= numel(data.c_zz_th)
        error('plot_phase_baseline_comparison:InconsistentLengths', ...
              ['theta_values, numerical correlations, and analytical ', ...
               'correlations must have the same length.']);
    end

    if any(~isfinite(data.theta)) || ...
       any(~isfinite(data.c_xx)) || any(~isfinite(data.c_yy)) || any(~isfinite(data.c_zz)) || ...
       any(~isfinite(data.c_xx_th)) || any(~isfinite(data.c_yy_th)) || any(~isfinite(data.c_zz_th))
        error('plot_phase_baseline_comparison:InvalidValues', ...
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
        'Correlations', ...
        'Experiment 1 — Deterministic Phase Sweep', ...
        style);

    build_phase_baseline_comparison_plot(tab, data, style, palette);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        output_path = '/home/marcocioci/HPC/THESIS-Quantum-Communications/Quantum-Fiber-Simulator/Images/Experiment_1/experiment_1_correlations_validation.png';

        export_plot(output_path, ...
            @(parent) build_phase_baseline_comparison_plot(parent, data, style, palette), ...
            style);
    end


    % =========================
    % Show figure
    % =========================

    set(fig, 'Visible', style.figure.visible_after_build);

end


function tl = build_phase_baseline_comparison_plot(parent, data, style, palette)
% BUILD_PHASE_BASELINE_COMPARISON_PLOT  Build Experiment 1 correlation plot.
%
% Objective:
%   Construct the tiledlayout containing c_xx, c_yy, and c_zz comparisons.
%
% Input:
%   parent  - parent container for the tiledlayout
%   data    - structure containing numerical and analytical correlations
%   style   - plot style structure
%   palette - plot color palette
%
% Output:
%   tl - tiledlayout handle

    % =========================
    % Common limits
    % =========================

    theta = data.theta;

    y_limits = style.axes.correlation_limits;
    x_limits = [min(theta), max(theta)];


    % =========================
    % Layout
    % =========================

    tl = tiledlayout(parent, 3, 1, ...
        'TileSpacing', style.layout.tile_spacing, ...
        'Padding', style.layout.padding);


    % =========================
    % c_xx
    % =========================

    ax = nexttile(tl);
    plot_correlation_panel(ax, ...
        theta, data.c_xx, data.c_xx_th, ...
        '$c_{xx}$', palette.obs_x, ...
        x_limits, y_limits, style, palette, true);


    % =========================
    % c_yy
    % =========================

    ax = nexttile(tl);
    plot_correlation_panel(ax, ...
        theta, data.c_yy, data.c_yy_th, ...
        '$c_{yy}$', palette.obs_y, ...
        x_limits, y_limits, style, palette, false);


    % =========================
    % c_zz
    % =========================

    ax = nexttile(tl);
    plot_correlation_panel(ax, ...
        theta, data.c_zz, data.c_zz_th, ...
        '$c_{zz}$', palette.obs_z, ...
        x_limits, y_limits, style, palette, false);


    % =========================
    % Global title
    % =========================

    title(tl, ...
        'Experiment 1 — Correlation Validation | deterministic phase sweep', ...
        'FontSize', style.title.font_size, ...
        'FontWeight', style.title.font_weight, ...
        'Interpreter', style.title.interpreter);

end


function plot_correlation_panel(ax, theta, c_num, c_th, y_label, color, ...
                                x_limits, y_limits, style, palette, do_legend)
% PLOT_CORRELATION_PANEL  Plot one correlation observable panel.
%
% Objective:
%   Plot analytical and numerical values of one correlation observable.
%
% Input:
%   ax        - axes handle
%   theta     - phase grid θ
%   c_num     - numerical correlation values
%   c_th      - analytical correlation values
%   y_label   - y-axis label
%   color     - RGB color triplet
%   x_limits  - x-axis limits
%   y_limits  - y-axis limits
%   style     - plot style structure
%   palette   - plot color palette
%   do_legend - logical flag controlling legend creation
%
% Output:
%   None

    % =========================
    % Plot
    % =========================

    hold(ax, 'on');
    grid(ax, style.axes.grid);
    box(ax, style.axes.box);

    plot(ax, theta, c_th, ...
        'LineWidth', style.lines.width_main, ...
        'Color', color);

    plot(ax, theta, c_num, 'o', ...
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