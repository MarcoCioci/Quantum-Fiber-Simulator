function plot_phase_baseline_comparison(results_phase_baseline)
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
% Output:
%   None
%
% Notes:
%   - Theory: continuous colored line
%   - Numerics: black markers
%   - Three stacked panels with shared axis limits

    % =========================
    % Robustness checks
    % =========================

    required_fields = {'theta_values', 'c_xx', 'c_yy', 'c_zz', 'analytical'};

    for k = 1:length(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_comparison:MissingField', ...
                'Field "%s" not found.', required_fields{k});
        end
    end

    if ~isfield(results_phase_baseline.analytical, 'c_xx') || ...
       ~isfield(results_phase_baseline.analytical, 'c_yy') || ...
       ~isfield(results_phase_baseline.analytical, 'c_zz')
        error('plot_phase_baseline_comparison:MissingAnalyticalField', ...
            'Analytical correlation fields c_xx, c_yy, c_zz must be present.');
    end


    % =========================
    % Extract data
    % =========================

    theta = results_phase_baseline.theta_values(:).';

    c_xx = real(results_phase_baseline.c_xx(:).');
    c_yy = real(results_phase_baseline.c_yy(:).');
    c_zz = real(results_phase_baseline.c_zz(:).');

    c_xx_th = real(results_phase_baseline.analytical.c_xx(:).');
    c_yy_th = real(results_phase_baseline.analytical.c_yy(:).');
    c_zz_th = real(results_phase_baseline.analytical.c_zz(:).');

    if numel(theta) ~= numel(c_xx) || ...
       numel(theta) ~= numel(c_yy) || ...
       numel(theta) ~= numel(c_zz) || ...
       numel(theta) ~= numel(c_xx_th) || ...
       numel(theta) ~= numel(c_yy_th) || ...
       numel(theta) ~= numel(c_zz_th)
        error('plot_phase_baseline_comparison:InconsistentLengths', ...
            ['theta_values, numerical correlations, and analytical ', ...
             'correlations must have the same length.']);
    end

    if any(~isfinite(theta)) || ...
       any(~isfinite(c_xx)) || ...
       any(~isfinite(c_yy)) || ...
       any(~isfinite(c_zz)) || ...
       any(~isfinite(c_xx_th)) || ...
       any(~isfinite(c_yy_th)) || ...
       any(~isfinite(c_zz_th))
        error('plot_phase_baseline_comparison:InvalidValues', ...
            'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Common axis limits
    % =========================

    y_min = -1.1;
    y_max =  1.1;


    % =========================
    % Figure metadata
    % =========================

    figure_filename = 'experiment_1_correlations_validation.png';


    % =========================
    % Figure
    % =========================

    fig = figure('Name', 'Experiment 1: deterministic phase model validation', ...
                 'NumberTitle', 'off');

    tiledlayout(3,1, 'TileSpacing','compact', 'Padding','compact');


    % =========================
    % c_xx
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, c_xx_th, 'b', 'LineWidth', 1.8);
    plot(theta, c_xx, 'ko', 'MarkerSize', 4);

    ylabel('$c_{xx}$', 'Interpreter','latex');
    ylim([y_min y_max]);

    legend({'theory', 'numerical'}, ...
           'Location','southoutside', ...
           'Orientation','horizontal');


    % =========================
    % c_yy
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, c_yy_th, 'r', 'LineWidth', 1.8);
    plot(theta, c_yy, 'ko', 'MarkerSize', 4);

    ylabel('$c_{yy}$', 'Interpreter','latex');
    ylim([y_min y_max]);


    % =========================
    % c_zz
    % =========================

    nexttile;
    hold on; grid on; box on;

    plot(theta, c_zz_th, 'g', 'LineWidth', 1.8);
    plot(theta, c_zz, 'ko', 'MarkerSize', 4);

    xlabel('$\theta$', 'Interpreter','latex');
    ylabel('$c_{zz}$', 'Interpreter','latex');
    ylim([y_min y_max]);


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 1: deterministic phase model validation', ...
            'FontWeight','bold');


    % =========================
    % Figure-level annotations
    % =========================

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