function plot_random_phase_state_metrics(results_experiment_2)
% PLOT_RANDOM_PHASE_STATE_METRICS  Plot Experiment 2 purity and fidelity metrics.
%
% Objective:
%   Compare the numerical state-characterization quantities of Experiment 2
%   with their analytical predictions for the random-phase ensemble model.
%
%   For the present model, the analytical predictions are:
%
%       purity_global    = (1 + mean(cos(theta_samples))^2) / 2
%       purity_A         = 1/2
%       purity_B         = 1/2
%       fidelity_PsiPlus = (1 + mean(cos(theta_samples))) / 2
%
% Input:
%   results_experiment_2 - structure containing:
%       .theta_samples
%       .purity_global
%       .purity_A
%       .purity_B
%       .fidelity_psi_plus
%
% Output:
%   None
%
% Notes:
%   - Theory: colored bar
%   - Numerics: gray bar
%   - This function is intentionally separate from the correlation plot,
%     because purity and fidelity serve a different diagnostic purpose.

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_samples', ...
                       'purity_global', ...
                       'purity_A', ...
                       'purity_B', ...
                       'fidelity_psi_plus'};

    for k = 1:length(required_fields)
        if ~isfield(results_experiment_2, required_fields{k})
            error('plot_random_phase_state_metrics:MissingField', ...
                'Field "%s" not found.', required_fields{k});
        end
    end


    % =========================
    % Extract data
    % =========================

    theta_samples = results_experiment_2.theta_samples(:).';

    purity_global_num = real(results_experiment_2.purity_global);
    purity_A_num = real(results_experiment_2.purity_A);
    purity_B_num = real(results_experiment_2.purity_B);
    fidelity_num = real(results_experiment_2.fidelity_psi_plus);

    if any(~isfinite(theta_samples))
        error('plot_random_phase_state_metrics:InvalidThetaSamples', ...
            'theta_samples must contain only finite values.');
    end

    if any(~isfinite([purity_global_num, purity_A_num, purity_B_num, fidelity_num]))
        error('plot_random_phase_state_metrics:InvalidMetricValues', ...
            'Metric values must be finite.');
    end


    % =========================
    % Theory
    % =========================

    mean_cos_theta = mean(cos(theta_samples));

    purity_global_th = (1 + mean_cos_theta^2) / 2;
    purity_A_th = 0.5;
    purity_B_th = 0.5;
    fidelity_th = (1 + mean_cos_theta) / 2;


    % =========================
    % Data arrays
    % =========================

    labels = {'$\gamma(\rho_{AB})$', '$\gamma(\rho_A)$', '$\gamma(\rho_B)$', '$F_{\Psi^+}$'};
    theory_values = [purity_global_th, purity_A_th, purity_B_th, fidelity_th];
    numerical_values = [purity_global_num, purity_A_num, purity_B_num, fidelity_num];
    abs_errors = abs(numerical_values - theory_values);


    % =========================
    % Figure metadata
    % =========================

    figure_filename = 'experiment_2_random_phase_state_metrics.png';

    % figure_description = [ ...
    %     'Experiment 2 state-metric analysis. ' ...
    %     'The figure compares analytical and numerical values of global purity, ' ...
    %     'reduced purities, and fidelity with respect to |Psi+＞ for the random-phase ensemble model.' ...
    % ];


    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 2: purity and fidelity validation', ...
                 'NumberTitle', 'off');

    hold on; grid on; box on;

    x = 1:4;
    bar_width = 0.36;

    bar(x - bar_width/2, theory_values, bar_width, ...
        'FaceColor', [0.65 0.65 0.85], ...
        'EdgeColor', 'k');

    bar(x + bar_width/2, numerical_values, bar_width, ...
        'FaceColor', [0.85 0.85 0.85], ...
        'EdgeColor', 'k');

    ylim([0, 1.05]);
    xlim([0.4, 4.6]);

    set(gca, 'XTick', x, 'XTickLabel', labels, 'TickLabelInterpreter', 'latex');

    ylabel('value');
    xlabel('state metrics');
    title('Experiment 2: purity and fidelity validation');

    legend({'theory', 'numerical'}, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');

    for k = 1:4
        text(x(k) - bar_width/2, theory_values(k) + 0.04, ...
            sprintf('%.4f', theory_values(k)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 9);

        text(x(k) + bar_width/2, numerical_values(k) + 0.04, ...
            sprintf('%.4f', numerical_values(k)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 9);
    end

    error_text = sprintf(['|theory - numerical|:\n' ...
                          '\\gamma(\\rho_{AB}): %.3e\n' ...
                          '\\gamma(\\rho_A): %.3e\n' ...
                          '\\gamma(\\rho_B): %.3e\n' ...
                          'F_{\\Psi^+}: %.3e'], ...
                          abs_errors(1), abs_errors(2), abs_errors(3), abs_errors(4));

    text(0.98, 0.05, error_text, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', [0.8 0.8 0.8]);


    % =========================
    % Figure-level annotations
    % =========================

    annotation(fig, 'textbox', ...
        [0.12, 0.935, 0.76, 0.05], ...
        ... % 'String', figure_description,
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'EdgeColor', [0.8 0.8 0.8], ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

    annotation(fig, 'textbox', ...
        [0.72, 0.005, 0.26, 0.03], ...
        'String', sprintf('File: %s', figure_filename), ...
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'EdgeColor', [0.8 0.8 0.8], ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

end