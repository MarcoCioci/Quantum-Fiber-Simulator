function plot_two_arm_pmd_compensation_sections(results_experiment_7, do_save)
% PLOT_TWO_ARM_PMD_COMPENSATION_SECTIONS
% Plot fixed-arm-A sections of the two-arm PMD compensation map.
%
% Objective:
%   Show how sweeping the PMD delay in arm B can recover the polarization
%   coherence lost by a fixed PMD delay in arm A.
%
% Input:
%   results_experiment_7 - structure produced by
%                          run_experiment_7_two_arm_pmd_compensation.
%   do_save              - optional logical scalar. If true, export the
%                          figure to the experiment_7 image folder.
%
% Output:
%   None.
%
% Notes:
%   Analytical predictions are drawn as continuous lines, while numerical
%   simulation data are drawn as markers.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_two_arm_pmd_compensation_sections:InvalidNumInputs', ...
            'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~isstruct(results_experiment_7)
        error('plot_two_arm_pmd_compensation_sections:InvalidResults', ...
            'results_experiment_7 must be a structure.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_two_arm_pmd_compensation_sections:InvalidDoSave', ...
            'do_save must be a logical scalar.');
    end

    required_fields = { ...
        'dgd_values_A', 'dgd_values_B', ...
        'sigma_A', 'sigma_B', ...
        'analytical', 'concurrence', ...
        'fidelity_psi_plus', 'S_max', 'errors' ...
    };

    check_required_fields(results_experiment_7, required_fields, ...
        'plot_two_arm_pmd_compensation_sections:MissingField');

    check_required_fields(results_experiment_7.analytical, ...
        {'kappa', 'concurrence', 'fidelity_psi_plus', 'S_max'}, ...
        'plot_two_arm_pmd_compensation_sections:MissingAnalyticalField');

    check_required_fields(results_experiment_7.errors, ...
        {'concurrence', 'fidelity_psi_plus', 'S_max'}, ...
        'plot_two_arm_pmd_compensation_sections:MissingErrorField');


    % =========================
    % Extract data
    % =========================

    normalized_dgd_A = real(results_experiment_7.sigma_A) * ...
        results_experiment_7.dgd_values_A(:).';

    normalized_dgd_B = real(results_experiment_7.sigma_B) * ...
        results_experiment_7.dgd_values_B(:).';

    num_dgd_values_A = numel(normalized_dgd_A);

    if num_dgd_values_A < 3
        section_indices = 1:num_dgd_values_A;
    else
        section_indices = unique(round(linspace(1, num_dgd_values_A, 3)));
    end

    palette = get_plot_palette();
    style = get_plot_style();


    % =========================
    % Figure and tab
    % =========================

    figure_id = get_experiment_7_figure_id(style);

    [fig, tab] = get_experiment_figure_tab( ...
        figure_id, ...
        'Two-arm PMD compensation sections', ...
        'Experiment 7 - Two-Arm PMD Compensation', ...
        style);

    build_plot(tab);

    set(fig, 'Visible', style.figure.visible_after_build);


    % =========================
    % Save (conditional)
    % =========================

    if do_save

        output_folder = [ ...
            '/home/marcocioci/HPC/THESIS-Quantum-Communications/', ...
            'Quantum-Fiber-Simulator/images/experiment_7' ...
        ];

        output_path = fullfile(output_folder, ...
            'experiment_7_two_arm_pmd_compensation_sections.png');

        export_plot(output_path, @build_plot, style);

    end


    % =========================
    % Local plot builder
    % =========================

    function layout = build_plot(parent_container)

        layout = tiledlayout(parent_container, 2, 1, ...
            'TileSpacing', 'compact', ...
            'Padding', 'compact');

        ax = nexttile(layout, 1);
        plot_metric_sections(ax);

        ax = nexttile(layout, 2);
        plot_validation_sections(ax);

        title(layout, ...
            ['Experiment 7: fixed-arm-A sections of the PMD ', ...
             'compensation map'], ...
            'Interpreter', 'none');

    end


    function plot_metric_sections(ax)

        hold(ax, 'on');

        section_colors = section_color_map(numel(section_indices));

        for local_idx = 1:numel(section_indices)

            idx_A = section_indices(local_idx);
            line_color = section_colors(local_idx, :);

            plot(ax, normalized_dgd_B, ...
                results_experiment_7.analytical.concurrence(idx_A, :), ...
                '-', ...
                'Color', line_color, ...
                'LineWidth', 1.7, ...
                'DisplayName', sprintf( ...
                '$C$, analytical, $\\sigma_A\\tau_A=%.2f$', ...
                normalized_dgd_A(idx_A)));

            plot(ax, normalized_dgd_B, ...
                results_experiment_7.concurrence(idx_A, :), ...
                'o', ...
                'Color', line_color, ...
                'MarkerFaceColor', 'w', ...
                'MarkerSize', 5, ...
                'LineWidth', 1.0, ...
                'HandleVisibility', 'off');

        end

        plot(ax, normalized_dgd_B, ...
            results_experiment_7.fidelity_psi_plus( ...
            section_indices(end), :), ...
            '--', ...
            'Color', palette.metric_F, ...
            'LineWidth', 1.4, ...
            'DisplayName', '$F_{\Psi^+}$, largest section');

        plot(ax, normalized_dgd_B, ...
            results_experiment_7.S_max(section_indices(end), :) / ...
            (2 * sqrt(2)), ...
            ':', ...
            'Color', palette.metric_global, ...
            'LineWidth', 1.8, ...
            'DisplayName', '$S_{\max}/(2\sqrt{2})$, largest section');

        hold(ax, 'off');

        xlabel(ax, '$\sigma_B\tau_B$', 'Interpreter', 'latex');
        ylabel(ax, 'Metric value', 'Interpreter', 'latex');
        title(ax, 'Recovery sections versus arm-B DGD', ...
            'Interpreter', 'latex');

        ylim(ax, [0, 1.05]);
        grid(ax, 'on');
        box(ax, 'on');

        legend(ax, ...
            'Interpreter', 'latex', ...
            'Location', 'southoutside', ...
            'NumColumns', 2);

    end


    function plot_validation_sections(ax)

        hold(ax, 'on');

        section_colors = section_color_map(numel(section_indices));

        for local_idx = 1:numel(section_indices)

            idx_A = section_indices(local_idx);
            line_color = section_colors(local_idx, :);

            plot(ax, normalized_dgd_B, ...
                max(abs(results_experiment_7.errors.concurrence( ...
                idx_A, :)), eps), ...
                '-', ...
                'Color', line_color, ...
                'LineWidth', 1.5, ...
                'DisplayName', sprintf( ...
                '$|\\Delta C|$, $\\sigma_A\\tau_A=%.2f$', ...
                normalized_dgd_A(idx_A)));

        end

        plot(ax, normalized_dgd_B, ...
            max(abs(results_experiment_7.errors.fidelity_psi_plus( ...
            section_indices(end), :)), eps), ...
            '--', ...
            'Color', palette.metric_F, ...
            'LineWidth', 1.4, ...
            'DisplayName', '$|\Delta F_{\Psi^+}|$, largest section');

        plot(ax, normalized_dgd_B, ...
            max(abs(results_experiment_7.errors.S_max( ...
            section_indices(end), :)), eps), ...
            ':', ...
            'Color', palette.metric_global, ...
            'LineWidth', 1.8, ...
            'DisplayName', '$|\Delta S_{\max}|$, largest section');

        hold(ax, 'off');

        xlabel(ax, '$\sigma_B\tau_B$', 'Interpreter', 'latex');
        ylabel(ax, 'Absolute validation error', 'Interpreter', 'latex');
        title(ax, 'Numerical versus analytical validation', ...
            'Interpreter', 'latex');

        set(ax, 'YScale', 'log');
        grid(ax, 'on');
        box(ax, 'on');

        legend(ax, ...
            'Interpreter', 'latex', ...
            'Location', 'southoutside', ...
            'NumColumns', 2);

    end

end


function figure_id = get_experiment_7_figure_id(style)
% GET_EXPERIMENT_7_FIGURE_ID  Return style ID with a local fallback.

    if isfield(style, 'figure') && ...
            isfield(style.figure, 'experiment_7_id')
        figure_id = style.figure.experiment_7_id;
    else
        figure_id = 7;
    end

end


function colors = section_color_map(num_sections)
% SECTION_COLOR_MAP  Distinct colors for fixed-arm-A sections.

    anchor_colors = [ ...
        0.22, 0.45, 0.70; ...
        0.85, 0.30, 0.30; ...
        0.30, 0.70, 0.40 ...
    ];

    if num_sections <= size(anchor_colors, 1)
        colors = anchor_colors(1:num_sections, :);
        return;
    end

    anchor_positions = linspace(0, 1, size(anchor_colors, 1));
    color_positions = linspace(0, 1, num_sections);

    colors = interp1(anchor_positions, anchor_colors, ...
        color_positions, 'linear');

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
