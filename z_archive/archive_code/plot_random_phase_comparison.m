function plot_random_phase_comparison(results_experiment_2)
% PLOT_RANDOM_PHASE_COMPARISON  Experiment 2 correlation validation with separated views.
%
% Objective:
%   Provide a clear visualization of the correlation sector of Experiment 2
%   by separating:
%
%       1) the sampled phase distribution
%       2) the pure-state correlation trend associated with each sample
%       3) the final ensemble-level comparison between theory and numerics
%
%   For the present random-phase model, the ensemble analytical predictions are:
%
%       c_xx = mean(cos(theta_samples))
%       c_yy = mean(cos(theta_samples))
%       c_zz = -1
%
% Input:
%   results_experiment_2 - structure containing:
%       .theta_samples
%       .c_xx
%       .c_yy
%       .c_zz
%
% Output:
%   None
%
% Notes:
%   - Top panel: histogram of theta_samples
%   - Middle panel: pure-state trend cos(theta) with sample projections
%   - Bottom panel: grouped comparison of theory vs numerical ensemble values
%
%   This visualization is intentionally limited to the correlation sector.
%   Purity and fidelity are handled separately, since they play a different
%   role in the state characterization of the ensemble.

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_samples', 'c_xx', 'c_yy', 'c_zz'};

    for k = 1:length(required_fields)
        if ~isfield(results_experiment_2, required_fields{k})
            error('plot_random_phase_comparison:MissingField', ...
                'Field "%s" not found.', required_fields{k});
        end
    end

    theta_samples = results_experiment_2.theta_samples;

    if ~isnumeric(theta_samples) || ~isvector(theta_samples)
        error('plot_random_phase_comparison:InvalidThetaSamples', ...
            'results_experiment_2.theta_samples must be a numeric vector.');
    end

    if isempty(theta_samples)
        error('plot_random_phase_comparison:EmptyThetaSamples', ...
            'results_experiment_2.theta_samples must not be empty.');
    end

    if ~isreal(theta_samples)
        error('plot_random_phase_comparison:ComplexThetaSamples', ...
            'results_experiment_2.theta_samples must be real-valued.');
    end

    if any(~isfinite(theta_samples))
        error('plot_random_phase_comparison:NonFiniteThetaSamples', ...
            'results_experiment_2.theta_samples must contain only finite values.');
    end

    % =========================
    % Extract data
    % =========================

    theta_samples = theta_samples(:).';

    c_xx_num = real(results_experiment_2.c_xx);
    c_yy_num = real(results_experiment_2.c_yy);
    c_zz_num = real(results_experiment_2.c_zz);

    if any(~isfinite([c_xx_num, c_yy_num, c_zz_num]))
        error('plot_random_phase_comparison:InvalidCorrelationValues', ...
            'Correlation values must be finite.');
    end

    % =========================
    % Ensemble theory
    % =========================

    c_xx_th = mean(cos(theta_samples));
    c_yy_th = mean(cos(theta_samples));
    c_zz_th = -1;

    % =========================
    % Sample-wise pure-state trend
    % =========================

    theta_min = min(theta_samples);
    theta_max = max(theta_samples);

    if theta_min == theta_max
        theta_min = theta_min - 0.5;
        theta_max = theta_max + 0.5;
    end

    theta_plot = linspace(theta_min, theta_max, 400);
    cos_plot   = cos(theta_plot);
    cos_samp   = cos(theta_samples);

    % =========================
    % Ensemble comparison arrays
    % =========================

    labels = {'c_{xx}', 'c_{yy}', 'c_{zz}'};
    theory_values    = [c_xx_th, c_yy_th, c_zz_th];
    numerical_values = [c_xx_num, c_yy_num, c_zz_num];
    abs_errors       = abs(numerical_values - theory_values);

    % =========================
    % Figure metadata
    % =========================

    figure_filename = 'experiment_2_random_phase_comparison.png';

    % figure_description = [ ...
    %     'Experiment 2 correlation analysis. ' ...
    %     'Top: sampled phase distribution. ' ...
    %     'Middle: pure-state cosine trend and sampled realizations. ' ...
    %     'Bottom: ensemble-level comparison between analytical predictions and numerical results.' ...
    % ];

    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 2: random-phase ensemble validation', ...
                 'NumberTitle', 'off');

    tiledlayout(3,1, 'TileSpacing','compact', 'Padding','compact');

    % ==========================================================
    % Panel 1: phase distribution
    % ==========================================================
    nexttile;
    hold on; grid on; box on;

    num_bins = max(10, round(sqrt(numel(theta_samples))));
    histogram(theta_samples, num_bins, ...
        'Normalization', 'pdf', ...
        'FaceColor', [0.75 0.75 0.75], ...
        'EdgeColor', [0.35 0.35 0.35]);

    xlim([theta_min, theta_max]);
    ylabel('pdf');
    title('Sampled phase distribution');

    mu_theta = mean(theta_samples);
    sigma_theta = std(theta_samples);

    text(0.02, 0.95, ...
        sprintf('N = %d   mean(\\theta) = %.4f   std(\\theta) = %.4f', ...
        numel(theta_samples), mu_theta, sigma_theta), ...
        'Units', 'normalized', ...
        'VerticalAlignment', 'top', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', [0.8 0.8 0.8]);

    % ==========================================================
    % Panel 2: pure-state map and sampled realizations
    % ==========================================================
    nexttile;
    hold on; grid on; box on;

    plot(theta_plot, cos_plot, 'b', 'LineWidth', 1.8);
    plot(theta_samples, cos_samp, 'ko', ...
        'MarkerSize', 3, ...
        'MarkerFaceColor', 'k');

    yline(c_xx_th, '--', 'Color', [0 0 0], 'LineWidth', 1.2);
    yline(c_xx_num, '-',  'Color', [0.4 0 0.4], 'LineWidth', 1.4);

    xlim([theta_min, theta_max]);
    ylim([-1.1, 1.1]);

    ylabel('$\cos(\theta)$', 'Interpreter','latex');
    title('Pure-state correlation trend and ensemble average');

    legend({'$\cos(\theta)$ trend', ...
            'sample realizations', ...
            '$\langle \cos(\theta)\rangle$ theory', ...
            '$c_{xx}$ numerical ensemble'}, ...
            'Interpreter','latex', ...
            'Location','southoutside', ...
            'Orientation','horizontal');

    % ==========================================================
    % Panel 3: ensemble theory vs numerics
    % ==========================================================
    nexttile;
    hold on; grid on; box on;

    x = 1:3;
    bar_width = 0.36;

    bar(x - bar_width/2, theory_values, bar_width, ...
        'FaceColor', [0.65 0.65 0.85], ...
        'EdgeColor', 'k');

    bar(x + bar_width/2, numerical_values, bar_width, ...
        'FaceColor', [0.85 0.85 0.85], ...
        'EdgeColor', 'k');

    ylim([-1.1, 1.1]);
    xlim([0.4, 3.6]);

    set(gca, 'XTick', x, 'XTickLabel', labels);
    ylabel('value');
    xlabel('ensemble observables');
    title('Ensemble-level comparison: theory vs numerics');

    legend({'theory', 'numerical'}, ...
        'Location','southoutside', ...
        'Orientation','horizontal');

    for k = 1:3
        text(x(k) - bar_width/2, theory_values(k) + 0.06*sign(theory_values(k) + eps), ...
            sprintf('%.4f', theory_values(k)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 9);

        text(x(k) + bar_width/2, numerical_values(k) + 0.06*sign(numerical_values(k) + eps), ...
            sprintf('%.4f', numerical_values(k)), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 9);
    end

    error_text = sprintf(['|theory - numerical|:\n' ...
                          'c_{xx}: %.3e\n' ...
                          'c_{yy}: %.3e\n' ...
                          'c_{zz}: %.3e'], ...
                          abs_errors(1), abs_errors(2), abs_errors(3));

    text(0.98, 0.05, error_text, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', [0.8 0.8 0.8]);

    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 2: random-phase ensemble validation', ...
        'FontWeight','bold');

    % =========================
    % Figure-level annotations
    % =========================

    annotation(fig, 'textbox', ...
        [0.12, 0.935, 0.76, 0.05], ...
        ... 'String', figure_description,
        'Interpreter', 'none', ...
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'EdgeColor', [0.8 0.8 0.8], ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

    annotation(fig, 'textbox', ...
        [0.78, 0.005, 0.20, 0.03], ...
        ... 'String', sprintf('File: %s', figure_filename), ...
        'Interpreter', 'none', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'EdgeColor', [0.8 0.8 0.8], ...
        'BackgroundColor', 'w', ...
        'FitBoxToText', 'off');

end