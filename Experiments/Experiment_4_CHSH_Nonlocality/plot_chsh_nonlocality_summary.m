function plot_chsh_nonlocality_summary(results_experiment_4)
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
%       |S_fixed| - fixed laboratory-axis CHSH value (magnitude)
%       S_max     - maximal CHSH value from the correlation tensor
%
% Input:
%   results_experiment_4 - structure produced by
%                          run_experiment_4_chsh_nonlocality.
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('plot_chsh_nonlocality_summary:InvalidNumInputs', ...
              'Expected 1 input argument.');
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

    % =========================
    % Plot style
    % =========================

    palette = get_plot_palette();

    % =========================
    % Figure
    % =========================

    figure('Name', 'Experiment 4 — CHSH Nonlocality');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');


    % =====================================================
    % Panel 1: deterministic phase sweep
    % =====================================================

    nexttile;
    hold on;
    grid on;
    box on;

    % |S_fixed|
    plot(theta_values, abs_S_fixed_phase, ...
        'LineWidth', 2.0, ...
        'Color', palette.numerical);

    % S_max (constant)
    plot(theta_values, S_max_phase, ...
        'LineWidth', 1.6, ...
        'Color', palette.analytical);

    % Bounds
    yline(S_classical_bound, ':', ...
        'LineWidth', 1.2, ...
        'Color', palette.red);

    yline(S_tsirelson_bound, ':', ...
        'LineWidth', 1.2, ...
        'Color', palette.purple);

    % Zero reference
    yline(0, '-', ...
        'LineWidth', 0.8, ...
        'Color', palette.gray_mid);

    xlabel('\theta');
    ylabel('|S|');
    title('Deterministic phase sweep');

    xlim([min(theta_values), max(theta_values)]);
    ylim([0, S_tsirelson_bound + 0.15]);

    legend({ ...
        '|S_{fixed}|', ...
        'S_{max}', ...
        'classical bound', ...
        'Tsirelson bound' ...
        }, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');


    % =====================================================
    % Panel 2: depolarizing channel
    % =====================================================

    nexttile;
    hold on;
    grid on;
    box on;

    % |S_fixed|
    plot(p_values, abs_S_fixed_depol, ...
        'LineWidth', 2.0, ...
        'Color', palette.numerical);

    % S_max numerical
    plot(p_values, S_max_depol, ...
        'LineWidth', 1.6, ...
        'Color', palette.analytical);

    % S_max analytical (overlap check)
    plot(p_values, S_max_depol_analytical, '--', ...
        'LineWidth', 1.2, ...
        'Color', palette.gray_dark);

    % Bounds
    yline(S_classical_bound, ':', ...
        'LineWidth', 1.2, ...
        'Color', palette.red);

    yline(S_tsirelson_bound, ':', ...
        'LineWidth', 1.2, ...
        'Color', palette.purple);

    % Threshold
    xline(p_chsh_threshold, '--', ...
        'LineWidth', 1.2, ...
        'Color', palette.green);

    xlabel('p');
    ylabel('|S|');
    title('Depolarizing channel');

    xlim([min(p_values), max(p_values)]);
    ylim([0, S_tsirelson_bound + 0.15]);

    % Threshold label (better positioned)
    text(p_chsh_threshold, 0.3 * S_tsirelson_bound, ...
        sprintf('p_{CHSH} = %.4f', p_chsh_threshold), ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'EdgeColor', palette.gray_dark);

    legend({ ...
        '|S_{fixed}|', ...
        'S_{max}', ...
        'S_{max} analytical', ...
        'classical bound', ...
        'Tsirelson bound', ...
        'CHSH threshold' ...
        }, ...
        'Location', 'southoutside', ...
        'Orientation', 'horizontal');


    % =========================
    % Global title
    % =========================

    sgtitle('Experiment 4 — CHSH Nonlocality', ...
        'FontWeight', 'bold');

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