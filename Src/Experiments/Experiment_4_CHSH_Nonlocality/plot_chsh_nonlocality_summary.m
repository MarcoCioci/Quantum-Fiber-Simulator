function fig = plot_chsh_nonlocality_summary(results_experiment_4, do_save)
% PLOT_CHSH_NONLOCALITY_SUMMARY  Plot CHSH results for Experiment 4.
%
% Objective:
%   Provide a compact summary of CHSH nonlocality under:
%
%       1) deterministic phase evolution
%       2) two-qubit depolarization
%
%   The figure compares:
%
%       |S_fixed| - fixed laboratory-axis CHSH value magnitude
%       S_max     - maximal CHSH value from the correlation tensor
%
% Input:
%   results_experiment_4 - structure produced by
%                          run_experiment_4_chsh_nonlocality.
%
%   do_save (optional)  - logical flag to enable figure saving
%                         (default: false)
%
% Output:
%   fig - handle to the experiment figure window

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_chsh_nonlocality_summary:InvalidNumInputs', ...
              'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_chsh_nonlocality_summary:InvalidDoSave', ...
              'do_save must be a logical scalar.');
    end

    if ~isstruct(results_experiment_4)
        error('plot_chsh_nonlocality_summary:InvalidInputType', ...
              'results_experiment_4 must be a structure.');
    end

    required_main_fields = {'phase', 'depolarization'};
    check_required_fields(results_experiment_4, required_main_fields, ...
        'plot_chsh_nonlocality_summary:MissingMainField');


    % =========================
    % Extract data
    % =========================

    theta_values = results_experiment_4.phase.theta_values(:);
    S_fixed_phase = results_experiment_4.phase.S_fixed(:);
    S_max_phase = results_experiment_4.phase.S_max(:);

    p_values = results_experiment_4.depolarization.p_values(:);
    S_fixed_depol = results_experiment_4.depolarization.S_fixed(:);
    S_max_depol = results_experiment_4.depolarization.S_max(:);
    S_max_depol_analytical = results_experiment_4.depolarization.analytical.S_max(:);

    S_classical_bound = results_experiment_4.phase.S_classical_bound;
    S_tsirelson_bound = results_experiment_4.phase.S_tsirelson_bound;
    p_chsh_threshold = results_experiment_4.depolarization.p_chsh_threshold;


    % =========================
    % Derived quantities
    % =========================

    abs_S_fixed_phase = abs(S_fixed_phase);
    abs_S_fixed_depol = abs(S_fixed_depol);

    theta_limits = [min(theta_values), max(theta_values)];
    p_limits = [min(p_values), max(p_values)];

    if theta_limits(1) == theta_limits(2)
        theta_limits = theta_limits + [-0.05, 0.05];
    end

    if p_limits(1) == p_limits(2)
        p_limits = p_limits + [-0.05, 0.05];
    end

    S_limits = [0, S_tsirelson_bound + 0.15];


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();
    style   = get_plot_style();


    % =========================
    % Figure and tab
    % =========================

    [fig, tab] = get_experiment_figure_tab( ...
        style.figure.experiment_4_id, ...
        'Summary', ...
        'Experiment 4 — CHSH Nonlocality', ...
        style);

    build_plot(tab);

    set(fig, 'Visible', style.figure.visible_after_build);


    % =========================
    % Save (conditional)
    % =========================

    if do_save
        output_folder = [ ...
            '/home/marcocioci/HPC/THESIS-Quantum-Communications/', ...
            'Quantum-Fiber-Simulator/Images/Experiment_4'];

        if ~exist(output_folder, 'dir')
            mkdir(output_folder);
        end

        output_path = fullfile(output_folder, ...
            'experiment_4_chsh_nonlocality_summary.png');

        export_plot(output_path, @build_plot, style);
    end


    % =========================
    % Local plot builder
    % =========================

    function build_plot(parent_container)

        tl = tiledlayout(parent_container, 1, 2, ...
            'TileSpacing', style.layout.tile_spacing, ...
            'Padding', style.layout.padding);


        % =====================================================
        % Panel 1: deterministic phase sweep
        % =====================================================

        ax = nexttile(tl);
        hold(ax, 'on');
        grid(ax, style.axes.grid);
        box(ax, style.axes.box);

        plot(ax, theta_values, abs_S_fixed_phase, ...
            'LineWidth', style.lines.width_main, ...
            'Color', palette.numerical, ...
            'DisplayName', '$|S_{\mathrm{fixed}}|$');

        plot(ax, theta_values, S_max_phase, ...
            'LineWidth', style.lines.width_secondary, ...
            'Color', palette.analytical, ...
            'DisplayName', '$S_{\max}$');

        yline(ax, S_classical_bound, ':', ...
            'LineWidth', 1.2, ...
            'Color', palette.red, ...
            'DisplayName', 'classical bound');

        yline(ax, S_tsirelson_bound, ':', ...
            'LineWidth', 1.2, ...
            'Color', palette.purple, ...
            'DisplayName', 'Tsirelson bound');

        yline(ax, 0, '-', ...
            'LineWidth', 0.8, ...
            'Color', palette.gray_mid, ...
            'HandleVisibility', 'off');

        xlabel(ax, '$\theta$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        ylabel(ax, '$|S|$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        title(ax, 'Deterministic phase sweep', ...
            'FontSize', style.title.font_size_small, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);

        xlim(ax, theta_limits);
        ylim(ax, S_limits);

        set(ax, ...
            'FontSize', style.axes.font_size, ...
            'LineWidth', style.axes.line_width, ...
            'TickLabelInterpreter', style.axes.tick_label_interpreter, ...
            'Layer', style.axes.layer);

        legend(ax, ...
            'Location', 'southoutside', ...
            'Orientation', 'horizontal', ...
            'Interpreter', style.legend.interpreter, ...
            'FontSize', style.legend.font_size);


        % =====================================================
        % Panel 2: depolarizing channel
        % =====================================================

        ax = nexttile(tl);
        hold(ax, 'on');
        grid(ax, style.axes.grid);
        box(ax, style.axes.box);

        plot(ax, p_values, abs_S_fixed_depol, ...
            'LineWidth', style.lines.width_main, ...
            'Color', palette.numerical, ...
            'DisplayName', '$|S_{\mathrm{fixed}}|$');

        plot(ax, p_values, S_max_depol, ...
            'LineWidth', style.lines.width_secondary, ...
            'Color', palette.analytical, ...
            'DisplayName', '$S_{\max}$ numerical');

        plot(ax, p_values, S_max_depol_analytical, '--', ...
            'LineWidth', 1.2, ...
            'Color', palette.gray_dark, ...
            'DisplayName', '$S_{\max}$ analytical');

        yline(ax, S_classical_bound, ':', ...
            'LineWidth', 1.2, ...
            'Color', palette.red, ...
            'DisplayName', 'classical bound');

        yline(ax, S_tsirelson_bound, ':', ...
            'LineWidth', 1.2, ...
            'Color', palette.purple, ...
            'DisplayName', 'Tsirelson bound');

        xline(ax, p_chsh_threshold, '--', ...
            'LineWidth', 1.2, ...
            'Color', palette.green, ...
            'DisplayName', 'CHSH threshold');

        xlabel(ax, '$p$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        ylabel(ax, '$|S|$', ...
            'Interpreter', style.labels.interpreter, ...
            'FontSize', style.labels.font_size_axis);

        title(ax, 'Depolarizing channel', ...
            'FontSize', style.title.font_size_small, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);

        xlim(ax, p_limits);
        ylim(ax, S_limits);

        text(ax, p_chsh_threshold, 0.3 * S_tsirelson_bound, ...
            sprintf('$p_{\\mathrm{CHSH}} = %.4f$', p_chsh_threshold), ...
            'Interpreter', style.labels.interpreter, ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'bottom', ...
            'BackgroundColor', 'w', ...
            'EdgeColor', palette.gray_dark, ...
            'FontSize', style.legend.font_size);

        set(ax, ...
            'FontSize', style.axes.font_size, ...
            'LineWidth', style.axes.line_width, ...
            'TickLabelInterpreter', style.axes.tick_label_interpreter, ...
            'Layer', style.axes.layer);

        legend(ax, ...
            'Location', 'southoutside', ...
            'Orientation', 'horizontal', ...
            'Interpreter', style.legend.interpreter, ...
            'FontSize', style.legend.font_size);


        % =========================
        % Global title
        % =========================

        title(tl, ...
            'Experiment 4 — CHSH Nonlocality', ...
            'FontSize', style.title.font_size, ...
            'FontWeight', style.title.font_weight, ...
            'Interpreter', style.title.interpreter);

    end

end


function check_required_fields(input_struct, required_fields, error_id)
% CHECK_REQUIRED_FIELDS  Verify that all required fields are present.

    for field_idx = 1:numel(required_fields)
        field_name = required_fields{field_idx};

        if ~isfield(input_struct, field_name)
            error(error_id, 'Field "%s" not found.', field_name);
        end
    end

end