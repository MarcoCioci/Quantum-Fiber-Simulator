function plot_phase_baseline_state_metrics(results_phase_baseline)
% PLOT_PHASE_BASELINE_STATE_METRICS  Plot Experiment 1 state metrics vs analytical expectations.
%
% Objective:
%   Compare the numerical state-characterization quantities of Experiment 1
%   with their analytical predictions:
%
%       purity_global(theta)    = 1
%       purity_A(theta)         = 1/2
%       purity_B(theta)         = 1/2
%       fidelity_PsiPlus(theta) = (1 + cos(theta)) / 2
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .purity_global
%       .purity_A
%       .purity_B
%       .fidelity_psi_plus
%
% Output:
%   None
%
% Notes:
%   - Theory: continuous colored line
%   - Numerics: black markers
%   - Four stacked panels with shared x-axis
%   - This function is intentionally separate from the correlation plot,
%     since purity and fidelity play a different interpretive role.

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_values', ...
                       'purity_global', ...
                       'purity_A', ...
                       'purity_B', ...
                       'fidelity_psi_plus'};

    for k = 1:length(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_state_metrics:MissingField', ...
                'Field "%s" not found.', required_fields{k});
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

    if numel(theta) ~= numel(purity_global) || ...
       numel(theta) ~= numel(purity_A) || ...
       numel(theta) ~= numel(purity_B) || ...
       numel(theta) ~= numel(fidelity_psi_plus)
        error('plot_phase_baseline_state_metrics:InconsistentLengths', ...
            ['theta_values, purity_global, purity_A, purity_B, and ', ...
             'fidelity_psi_plus must have the same length.']);
    end

    if any(~isfinite(theta)) || ...
       any(~isfinite(purity_global)) || ...
       any(~isfinite(purity_A)) || ...
       any(~isfinite(purity_B)) || ...
       any(~isfinite(fidelity_psi_plus))
        error('plot_phase_baseline_state_metrics:InvalidValues', ...
            'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Theory
    % =========================

    purity_global_th = ones(size(theta));
    purity_A_th = 0.5 * ones(size(theta));
    purity_B_th = 0.5 * ones(size(theta));
    fidelity_psi_plus_th = (1 + cos(theta)) / 2;


    % =========================
    % Common axis limits
    % =========================

    y_min = -0.05;
    y_max = 1.05;


    % =========================
    % Figure metadata
    % =========================

    figure_filename = 'experiment_1_state_metrics.png';
    % figure_description = [ ...
    %     'Experiment 1 state-metric analysis. ' ...
    %     'The figure compares numerical and analytical values of global purity, ' ...
    %     'reduced purities, and fidelity with respect to the Bell state |Psi+> ' ...
    %     'in the deterministic phase model.' ...
    % ];


    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 1: purity and fidelity validation', ...
                 'NumberTitle', 'off');

    tiledlayout(4,1, 'TileSpacing','compact', 'Padding','compact');


    % =========================
    % Global purity
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, purity_global_th, 'b', 'LineWidth', 1.8);
    plot(theta, purity_global, 'ko', 'MarkerSize', 4);

    ylabel('$\gamma(\rho_{AB})$', 'Interpreter','latex');
    ylim([y_min y_max]);

    legend({'theory', 'numerical'}, ...
           'Location','southoutside', ...
           'Orientation','horizontal');


    % =========================
    % Reduced purity A
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, purity_A_th, 'r', 'LineWidth', 1.8);
    plot(theta, purity_A, 'ko', 'MarkerSize', 4);

    ylabel('$\gamma(\rho_A)$', 'Interpreter','latex');
    ylim([y_min y_max]);


    % =========================
    % Reduced purity B
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, purity_B_th, 'g', 'LineWidth', 1.8);
    plot(theta, purity_B, 'ko', 'MarkerSize', 4);

    ylabel('$\gamma(\rho_B)$', 'Interpreter','latex');
    ylim([y_min y_max]);


    % ================================
    % Fidelity with respect to |Psi+>
    % ================================

    nexttile;
    hold on; grid on; box on;

    plot(theta, fidelity_psi_plus_th, 'm', 'LineWidth', 1.8);
    plot(theta, fidelity_psi_plus, 'ko', 'MarkerSize', 4);

    xlabel('$\theta$', 'Interpreter','latex');
    ylabel('$F_{\Psi^+}$', 'Interpreter','latex');
    ylim([y_min y_max]);


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 1: purity and fidelity validation', ...
            'FontWeight','bold');


    % =========================
    % Figure-level annotations
    % =========================

    % annotation(fig, 'textbox', ...
    %     [0.12, 0.935, 0.76, 0.05], ...
    %     'String', figure_description, ...
    %     'Interpreter', 'none', ...
    %     'HorizontalAlignment', 'center', ...
    %     'VerticalAlignment', 'middle', ...
    %     'EdgeColor', [0.8 0.8 0.8], ...
    %     'BackgroundColor', 'w', ...
    %     'FitBoxToText', 'off');

    annotation(fig, 'textbox', ...
        [0.74, 0.005, 0.24, 0.03], ...
        'String', sprintf('File: %s', figure_filename), ...
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'EdgeColor', [0.8 0.8 0.8], ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

end