function fig = plot_depolarization_summary(results_experiment_3)
% PLOT_DEPOLARIZATION_SUMMARY  Plot numerical and analytical results for Experiment 3.
%
% Objective:
%   Visualize the effect of the two-qubit depolarizing channel on the
%   reference Bell state |Psi+> by comparing numerical results with the
%   corresponding analytical predictions.
%
%   The plotted quantities are:
%
%       1. Global purity, reduced purities, fidelity, and concurrence
%       2. Pauli correlations c_xx, c_yy, and c_zz
%
% Input:
%   results_experiment_3 - structure returned by
%                          run_experiment_3_depolarization
%
% Output:
%   fig - handle to the generated figure
%
% Notes:
%   This function assumes that results_experiment_3 contains both numerical
%   results and analytical predictions stored in consistent vector form.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('plot_depolarization_summary:InvalidNumInputs', ...
              'Expected exactly 1 input argument: results_experiment_3.');
    end

    if ~isstruct(results_experiment_3)
        error('plot_depolarization_summary:InvalidType', ...
              'results_experiment_3 must be a structure.');
    end

    required_fields = { ...
        'p_values', ...
        'purity_global', ...
        'purity_A', ...
        'purity_B', ...
        'fidelity_psi_plus', ...
        'concurrence', ...
        'c_xx', ...
        'c_yy', ...
        'c_zz', ...
        'analytical'};

    for k = 1:numel(required_fields)
        if ~isfield(results_experiment_3, required_fields{k})
            error('plot_depolarization_summary:MissingField', ...
                  'Missing required field: %s.', required_fields{k});
        end
    end

    required_analytical_fields = { ...
        'purity_global', ...
        'purity_A', ...
        'purity_B', ...
        'fidelity_psi_plus', ...
        'concurrence', ...
        'c_xx', ...
        'c_yy', ...
        'c_zz'};

    for k = 1:numel(required_analytical_fields)
        if ~isfield(results_experiment_3.analytical, required_analytical_fields{k})
            error('plot_depolarization_summary:MissingAnalyticalField', ...
                  'Missing required analytical field: %s.', ...
                  required_analytical_fields{k});
        end
    end

    p_values = results_experiment_3.p_values(:).';

    num_p = numel(p_values);

    numeric_fields = { ...
        results_experiment_3.purity_global, ...
        results_experiment_3.purity_A, ...
        results_experiment_3.purity_B, ...
        results_experiment_3.fidelity_psi_plus, ...
        results_experiment_3.concurrence, ...
        results_experiment_3.c_xx, ...
        results_experiment_3.c_yy, ...
        results_experiment_3.c_zz, ...
        results_experiment_3.analytical.purity_global, ...
        results_experiment_3.analytical.purity_A, ...
        results_experiment_3.analytical.purity_B, ...
        results_experiment_3.analytical.fidelity_psi_plus, ...
        results_experiment_3.analytical.concurrence, ...
        results_experiment_3.analytical.c_xx, ...
        results_experiment_3.analytical.c_yy, ...
        results_experiment_3.analytical.c_zz};

    for k = 1:numel(numeric_fields)
        current_values = numeric_fields{k};

        if ~isnumeric(current_values) || ~isvector(current_values)
            error('plot_depolarization_summary:InvalidFieldShape', ...
                  'All plotted fields must be numeric vectors.');
        end

        if numel(current_values) ~= num_p
            error('plot_depolarization_summary:InconsistentLength', ...
                  'All plotted fields must have the same length as p_values.');
        end
    end


    % =========================
    % Main computation
    % =========================

    fig = figure('Name', 'Experiment 3 - Depolarizing Channel Summary', ...
                 'NumberTitle', 'off');

    tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');


    % =========================
    % Panel 1: State metrics
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    % Numerical results
    plot(p_values, results_experiment_3.purity_global, 'o', ...
        'DisplayName', '\gamma_{AB} numerical');
    plot(p_values, results_experiment_3.purity_A, 's', ...
        'DisplayName', '\gamma_{A} numerical');
    plot(p_values, results_experiment_3.purity_B, 'd', ...
        'DisplayName', '\gamma_{B} numerical');
    plot(p_values, results_experiment_3.fidelity_psi_plus, '^', ...
        'DisplayName', 'F_{\Psi^+} numerical');
    plot(p_values, results_experiment_3.concurrence, 'v', ...
        'DisplayName', 'C numerical');

    % Analytical predictions
    plot(p_values, results_experiment_3.analytical.purity_global, '-', ...
        'LineWidth', 1.2, 'DisplayName', '\gamma_{AB} analytical');
    plot(p_values, results_experiment_3.analytical.purity_A, '--', ...
        'LineWidth', 1.2, 'DisplayName', '\gamma_{A} analytical');
    plot(p_values, results_experiment_3.analytical.purity_B, ':', ...
        'LineWidth', 1.5, 'DisplayName', '\gamma_{B} analytical');
    plot(p_values, results_experiment_3.analytical.fidelity_psi_plus, '-.', ...
        'LineWidth', 1.2, 'DisplayName', 'F_{\Psi^+} analytical');
    plot(p_values, results_experiment_3.analytical.concurrence, '-', ...
        'LineWidth', 1.5, 'DisplayName', 'C analytical');

    xlabel('Depolarization parameter p');
    ylabel('Metric value');
    title('Experiment 3: State metrics under depolarizing noise');
    xlim([min(p_values), max(p_values)]);
    ylim([-0.05, 1.05]);
    legend('Location', 'eastoutside');


    % =========================
    % Panel 2: Correlations
    % =========================

    nexttile;
    hold on;
    grid on;
    box on;

    % Numerical results
    plot(p_values, results_experiment_3.c_xx, 'o', ...
        'DisplayName', 'c_{xx} numerical');
    plot(p_values, results_experiment_3.c_yy, 's', ...
        'DisplayName', 'c_{yy} numerical');
    plot(p_values, results_experiment_3.c_zz, 'd', ...
        'DisplayName', 'c_{zz} numerical');

    % Analytical predictions
    plot(p_values, results_experiment_3.analytical.c_xx, '-', ...
        'LineWidth', 1.2, 'DisplayName', 'c_{xx} analytical');
    plot(p_values, results_experiment_3.analytical.c_yy, '--', ...
        'LineWidth', 1.2, 'DisplayName', 'c_{yy} analytical');
    plot(p_values, results_experiment_3.analytical.c_zz, '-.', ...
        'LineWidth', 1.2, 'DisplayName', 'c_{zz} analytical');

    xlabel('Depolarization parameter p');
    ylabel('Correlation value');
    title('Experiment 3: Pauli correlations under depolarizing noise');
    xlim([min(p_values), max(p_values)]);
    ylim([-1.05, 1.05]);
    legend('Location', 'eastoutside');

end