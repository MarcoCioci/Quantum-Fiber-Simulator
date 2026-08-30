function plot_two_arm_pmd_compensation_summary(results_experiment_7, do_save)
% PLOT_TWO_ARM_PMD_COMPENSATION_SUMMARY
% Plot two-arm PMD compensation heatmaps.
%
% Objective:
%   Visualize the main Experiment 7 metrics on the two-dimensional DGD
%   plane. The plot highlights the nonlocal PMD compensation ridge where
%   PMD in arm B restores the coherence reduced by PMD in arm A.
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
%   Axes are normalized as sigma_A tau_A and sigma_B tau_B, so the heatmaps
%   are dimensionless and directly comparable with the analytical model.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1 || nargin > 2
        error('plot_two_arm_pmd_compensation_summary:InvalidNumInputs', ...
            'Expected 1 or 2 input arguments.');
    end

    if nargin < 2 || isempty(do_save)
        do_save = false;
    end

    if ~isstruct(results_experiment_7)
        error('plot_two_arm_pmd_compensation_summary:InvalidResults', ...
            'results_experiment_7 must be a structure.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('plot_two_arm_pmd_compensation_summary:InvalidDoSave', ...
            'do_save must be a logical scalar.');
    end

    required_fields = { ...
        'dgd_values_A', 'dgd_values_B', ...
        'sigma_A', 'sigma_B', ...
        'analytical', 'concurrence', ...
        'fidelity_psi_plus', 'S_max' ...
    };

    check_required_fields(results_experiment_7, required_fields, ...
        'plot_two_arm_pmd_compensation_summary:MissingField');

    check_required_fields(results_experiment_7.analytical, ...
        {'kappa'}, ...
        'plot_two_arm_pmd_compensation_summary:MissingAnalyticalField');


    % =========================
    % Extract data
    % =========================

    normalized_dgd_A = real(results_experiment_7.sigma_A) * ...
        results_experiment_7.dgd_values_A(:).';

    normalized_dgd_B = real(results_experiment_7.sigma_B) * ...
        results_experiment_7.dgd_values_B(:).';

    kappa = real(results_experiment_7.analytical.kappa);
    concurrence = real(results_experiment_7.concurrence);
    fidelity_psi_plus = real(results_experiment_7.fidelity_psi_plus);
    S_max = real(results_experiment_7.S_max);

    assert_metric_size(kappa, normalized_dgd_A, normalized_dgd_B, ...
        'analytical.kappa');
    assert_metric_size(concurrence, normalized_dgd_A, normalized_dgd_B, ...
        'concurrence');
    assert_metric_size(fidelity_psi_plus, normalized_dgd_A, ...
        normalized_dgd_B, 'fidelity_psi_plus');
    assert_metric_size(S_max, normalized_dgd_A, normalized_dgd_B, ...
        'S_max');

    style = get_plot_style();


    % =========================
    % Figure and tab
    % =========================

    figure_id = get_experiment_7_figure_id(style);

    [fig, tab] = get_experiment_figure_tab( ...
        figure_id, ...
        'Two-arm PMD compensation summary', ...
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
            'experiment_7_two_arm_pmd_compensation_summary.png');

        export_plot(output_path, @build_plot, style);

    end


    % =========================
    % Local plot builder
    % =========================

    function layout = build_plot(parent_container)

        layout = tiledlayout(parent_container, 2, 2, ...
            'TileSpacing', 'compact', ...
            'Padding', 'compact');

        ax = nexttile(layout, 1);
        plot_metric_heatmap(ax, kappa, ...
            '$\kappa(\tau_A,\tau_B)$', [0, 1]);

        ax = nexttile(layout, 2);
        plot_metric_heatmap(ax, concurrence, ...
            'Concurrence $C$', [0, 1]);

        ax = nexttile(layout, 3);
        plot_metric_heatmap(ax, fidelity_psi_plus, ...
            'Fidelity $F_{\Psi^+}$', [0.5, 1]);

        ax = nexttile(layout, 4);
        plot_metric_heatmap(ax, S_max, ...
            'Maximal CHSH value $S_{\max}$', [2, 2 * sqrt(2)]);

        title(layout, ...
            ['Experiment 7: two-arm PMD compensation with ', ...
             'spectrally anticorrelated photons'], ...
            'Interpreter', 'none');

    end


    function plot_metric_heatmap(ax, metric_values, plot_title, color_limits)

        imagesc(ax, normalized_dgd_A, normalized_dgd_B, metric_values.');
        axis(ax, 'xy');
        axis(ax, 'tight');

        colormap(ax, compensation_colormap());
        clim(ax, color_limits);
        colorbar(ax);

        hold(ax, 'on');
        plot_compensation_ridge(ax);
        hold(ax, 'off');

        xlabel(ax, '$\sigma_A\tau_A$', 'Interpreter', 'latex');
        ylabel(ax, '$\sigma_B\tau_B$', 'Interpreter', 'latex');
        title(ax, plot_title, 'Interpreter', 'latex');

        grid(ax, 'on');
        box(ax, 'on');

    end


    function plot_compensation_ridge(ax)

        ridge_min = max(min(normalized_dgd_A), min(normalized_dgd_B));
        ridge_max = min(max(normalized_dgd_A), max(normalized_dgd_B));

        if ridge_max > ridge_min
            plot(ax, [ridge_min, ridge_max], [ridge_min, ridge_max], ...
                '--', ...
                'Color', [0.05, 0.05, 0.05], ...
                'LineWidth', 1.3);
        end

    end

end


function color_map = compensation_colormap()
% COMPENSATION_COLORMAP  Clean sequential palette for PMD recovery maps.

    anchor_colors = [ ...
        0.94, 0.97, 1.00; ...
        0.70, 0.86, 0.93; ...
        0.30, 0.64, 0.76; ...
        0.16, 0.43, 0.58; ...
        0.08, 0.22, 0.36 ...
    ];

    anchor_positions = linspace(0, 1, size(anchor_colors, 1));
    color_positions = linspace(0, 1, 256);

    color_map = interp1(anchor_positions, anchor_colors, ...
        color_positions, 'linear');

end


function assert_metric_size(metric_values, dgd_values_A, dgd_values_B, ...
        metric_name)
% ASSERT_METRIC_SIZE  Validate Experiment 7 metric dimensions.

    expected_size = [numel(dgd_values_A), numel(dgd_values_B)];

    if ~isequal(size(metric_values), expected_size)
        error('plot_two_arm_pmd_compensation_summary:InvalidMetricSize', ...
            ['Metric "%s" must have size %d-by-%d, matching ', ...
             'the tau_A-by-tau_B grid.'], ...
            metric_name, expected_size(1), expected_size(2));
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


function check_required_fields(input_struct, required_fields, error_id)
% CHECK_REQUIRED_FIELDS  Verify that all required fields are present.

    for field_idx = 1:numel(required_fields)

        field_name = required_fields{field_idx};

        if ~isfield(input_struct, field_name)
            error(error_id, 'Field "%s" not found.', field_name);
        end

    end

end
