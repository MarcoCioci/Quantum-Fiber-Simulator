function plot_phase_baseline_state_metrics(results_phase_baseline)
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
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_values', ...
                       'purity_global', ...
                       'purity_A', ...
                       'purity_B', ...
                       'fidelity_psi_plus', ...
                       'concurrence', ...
                       'analytical'};

    for k = 1:length(required_fields)
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

    for k = 1:length(required_analytical_fields)
        if ~isfield(results_phase_baseline.analytical, required_analytical_fields{k})
            error('plot_phase_baseline_state_metrics:MissingAnalyticalField', ...
                'Analytical field "%s" not found.', required_analytical_fields{k});
        end
    end


    % =========================
    % Extract data
    % =========================

    theta = results_phase_baseline.theta_values(:).';

    purity_global = real(results_phase_baseline.purity_global(:).');
    purity_A = real(results_phase_baseline.purity_A(:).');
    purity_B = real(results_phase_baseline.purity_B(:).');
    fidelity_psi_plus = real(results_phase_baseline.fidelity_psi_plus(:).');
    concurrence = real(results_phase_baseline.concurrence(:).');

    purity_global_th = real(results_phase_baseline.analytical.purity_global(:).');
    purity_A_th = real(results_phase_baseline.analytical.purity_A(:).');
    purity_B_th = real(results_phase_baseline.analytical.purity_B(:).');
    fidelity_psi_plus_th = real(results_phase_baseline.analytical.fidelity_psi_plus(:).');
    concurrence_th = real(results_phase_baseline.analytical.concurrence(:).');

    if numel(theta) ~= numel(purity_global) || ...
       numel(theta) ~= numel(purity_A) || ...
       numel(theta) ~= numel(purity_B) || ...
       numel(theta) ~= numel(fidelity_psi_plus) || ...
       numel(theta) ~= numel(concurrence) || ...
       numel(theta) ~= numel(purity_global_th) || ...
       numel(theta) ~= numel(purity_A_th) || ...
       numel(theta) ~= numel(purity_B_th) || ...
       numel(theta) ~= numel(fidelity_psi_plus_th) || ...
       numel(theta) ~= numel(concurrence_th)
        error('plot_phase_baseline_state_metrics:InconsistentLengths', ...
            ['theta_values, numerical metrics, and analytical metrics ', ...
             'must have the same length.']);
    end

    if any(~isfinite(theta)) || ...
       any(~isfinite(purity_global)) || ...
       any(~isfinite(purity_A)) || ...
       any(~isfinite(purity_B)) || ...
       any(~isfinite(fidelity_psi_plus)) || ...
       any(~isfinite(concurrence)) || ...
       any(~isfinite(purity_global_th)) || ...
       any(~isfinite(purity_A_th)) || ...
       any(~isfinite(purity_B_th)) || ...
       any(~isfinite(fidelity_psi_plus_th)) || ...
       any(~isfinite(concurrence_th))
        error('plot_phase_baseline_state_metrics:InvalidValues', ...
            'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();

    y_min = -0.05;
    y_max = 1.05;

    theory_line_width = 1.8;
    numerical_marker_size = 4;


    % =========================
    % Figure metadata
    % =========================

    % figure_filename = 'experiment_1_state_metrics.png';


    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 1 — State Metrics | deterministic phase sweep');

    tiledlayout(5, 1, 'TileSpacing', 'compact', 'Padding', 'compact');


    % =========================
    % Global purity
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    plot(theta, purity_global_th, ...
    'LineWidth', theory_line_width, ...
    'Color', palette.metric_global);

    plot(theta, purity_global, 'o', ...
    'MarkerSize', numerical_marker_size, ...
    'MarkerFaceColor', palette.metric_global, ...
    'MarkerEdgeColor', palette.gray_dark);

    ylabel('$\gamma(\rho_{AB})$', 'Interpreter', 'latex');
    ylim([y_min, y_max]);

    legend({'analytical', 'numerical'}, ...
           'Location', 'southoutside', ...
           'Orientation', 'horizontal');


    % =========================
    % Reduced purity A
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    plot(theta, purity_A_th, ...
        'LineWidth', theory_line_width, ...
        'Color', palette.metric_A);

    plot(theta, purity_A, 'o', ...
        'MarkerSize', numerical_marker_size, ...
        'MarkerFaceColor', palette.metric_A, ...
        'MarkerEdgeColor', palette.gray_dark);

    ylabel('$\gamma(\rho_A)$', 'Interpreter', 'latex');
    ylim([y_min, y_max]);


    % =========================
    % Reduced purity B
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    plot(theta, purity_B_th, ...
        'LineWidth', theory_line_width, ...
        'Color', palette.metric_B);

    plot(theta, purity_B, 'o', ...
        'MarkerSize', numerical_marker_size, ...
        'MarkerFaceColor', palette.metric_B, ...
        'MarkerEdgeColor', palette.gray_dark);

    ylabel('$\gamma(\rho_B)$', 'Interpreter', 'latex');
    ylim([y_min, y_max]);


    % ================================
    % Fidelity with respect to |Psi+>
    % ================================

    nexttile;
    hold on;
    grid on;
    box on;

    plot(theta, fidelity_psi_plus_th, ...
    'LineWidth', theory_line_width, ...
    'Color', palette.metric_F);

    plot(theta, fidelity_psi_plus, 'o', ...
    'MarkerSize', numerical_marker_size, ...
    'MarkerFaceColor', palette.metric_F, ...
    'MarkerEdgeColor', palette.gray_dark);

    ylabel('$F_{\Psi^+}$', 'Interpreter', 'latex');
    ylim([y_min, y_max]);


    % =========================
    % Concurrence
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    plot(theta, concurrence_th, ...
    'LineWidth', theory_line_width, ...
    'Color', palette.metric_C);

    plot(theta, concurrence, 'o', ...
    'MarkerSize', numerical_marker_size, ...
    'MarkerFaceColor', palette.metric_C, ...
    'MarkerEdgeColor', palette.gray_dark);

    xlabel('$\theta$', 'Interpreter', 'latex');
    ylabel('$C$', 'Interpreter', 'latex');
    ylim([y_min, y_max]);


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 1 — State Metrics | deterministic phase sweep', ...
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