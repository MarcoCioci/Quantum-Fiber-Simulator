function plot_phase_baseline_comparison(results_phase_baseline)
% PLOT_PHASE_BASELINE_COMPARISON  Experiment 1 validation vs analytical model.
%
% Objective:
%   Compare numerical correlations with analytical predictions:
%       c_xx = cos(theta)
%       c_yy = cos(theta)
%       c_zz = -1
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
    % Figure
    % =========================
    figure;
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

    legend({'theory', 'numerical'}, 'Location','southoutside', ...
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

end