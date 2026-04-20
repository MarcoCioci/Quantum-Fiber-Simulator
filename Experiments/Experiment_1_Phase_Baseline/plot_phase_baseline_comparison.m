function plot_phase_baseline_comparison(results_phase_baseline)
% PLOT_PHASE_BASELINE_COMPARISON  Experiment 1 validation vs analytical model.
%
% Objective:
%   Compare numerical correlations with analytical predictions:
%
%       c_xx = cos(theta)
%       c_yy = cos(theta)
%       c_zz = -1
%
% Input:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .c_xx
%       .c_yy
%       .c_zz
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

    required_fields = {'theta_values', 'c_xx', 'c_yy', 'c_zz'};

    for k = 1:length(required_fields)
        if ~isfield(results_phase_baseline, required_fields{k})
            error('plot_phase_baseline_comparison:MissingField', ...
                'Field "%s" not found.', required_fields{k});
        end
    end


    % =========================
    % Extract data
    % =========================

    theta = results_phase_baseline.theta_values(:).';

    c_xx = real(results_phase_baseline.c_xx(:).');
    c_yy = real(results_phase_baseline.c_yy(:).');
    c_zz = real(results_phase_baseline.c_zz(:).');

    if numel(theta) ~= numel(c_xx) || ...
       numel(theta) ~= numel(c_yy) || ...
       numel(theta) ~= numel(c_zz)
        error('plot_phase_baseline_comparison:InconsistentLengths', ...
            'theta_values, c_xx, c_yy, and c_zz must have the same length.');
    end

    if any(~isfinite(theta)) || ...
       any(~isfinite(c_xx)) || ...
       any(~isfinite(c_yy)) || ...
       any(~isfinite(c_zz))
        error('plot_phase_baseline_comparison:InvalidValues', ...
            'Input data must not contain NaN or Inf values.');
    end


    % =========================
    % Theory
    % =========================

    c_xx_th = cos(theta);
    c_yy_th = cos(theta);
    c_zz_th = -ones(size(theta));


    % =========================
    % Common axis limits
    % =========================

    y_min = -1.1;
    y_max =  1.1;


    % =========================
    % Figure metadata
    % =========================

    figure_filename = 'experiment_1_theory_vs_experiment.png';
    % figure_description = [ ...
    %     'Experiment 1 correlation analysis. ' ...
    %     'The figure compares the numerical and analytical behavior of the aligned ' ...
    %     'two-qubit correlations c_xx, c_yy, and c_zz in the deterministic phase model.' ...
    % ];


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

    % annotation(fig, 'textbox', ...
    %     [0.12, 0.935, 0.76, 0.05], ...
    %     'String', figure_description,
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