function results = experiment_01_effective_models_bbm92(do_plot, do_save)
% EXPERIMENT_01_EFFECTIVE_MODELS_BBM92
% Compare effective fiber models through state metrics and BBM92 performance.
%
% Objective:
%   Establish the distinction between state-quality metrics and operational
%   BBM92 performance using analytically transparent effective fiber models.
%
%   Three propagation mechanisms are considered:
%
%       1. Coherent relative-phase evolution
%       2. Statistical phase fluctuations / dephasing
%       3. Symmetric two-arm depolarization
%
%   For each model, the propagated state is characterized through:
%
%       purity
%       fidelity
%       concurrence
%       Q_Z
%       Q_X
%       Q_worst = max(Q_Z, Q_X)
%
%   The BBM92 operating condition is defined by
%
%       Q_Z < Q_th
%       Q_X < Q_th.
%
%   The experiment demonstrates that entanglement preservation alone does
%   not determine BBM92 operation in fixed measurement bases.
%
% Inputs:
%   do_plot - Logical flag enabling figure visualization.
%   do_save - Logical flag enabling thesis-ready figure export.
%
% Output:
%   results - Structure containing parameters, numerical metrics,
%             operating boundaries, and consistency errors.


    % ==============================================================
    % Input handling
    % ==============================================================

    if nargin < 1
        do_plot = true;
    end

    if nargin < 2
        do_save = false;
    end


    % ==============================================================
    % Experiment parameters
    % ==============================================================

    num_phase_points = 181;
    num_dephasing_points = 101;
    num_depolarization_points = 101;

    theta_values = linspace(0, pi, num_phase_points);

    coherence_values = linspace(1, 0, num_dephasing_points);

    p_values = linspace(0, 1, num_depolarization_points);

    % BBM92 QBER threshold adopted for the present numerical study.

    qber_threshold = 0.11;

    % General numerical tolerance for direct algebraic comparisons.

    tolerance = 1e-12;

    % Concurrence is obtained through an eigenvalue-based numerical
    % evaluation and can accumulate errors above machine precision for
    % theoretically pure states. A dedicated tolerance is therefore used
    % for analytical concurrence consistency checks.

    concurrence_tolerance = 1e-7;


    % ==============================================================
    % Console header
    % ==============================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Experiment 1 - Effective Fiber Models and BBM92 Performance\n');
    fprintf('============================================================\n');
    fprintf('Phase points:                 %d\n', num_phase_points);
    fprintf('Dephasing points:             %d\n', num_dephasing_points);
    fprintf('Depolarization points:        %d\n', num_depolarization_points);
    fprintf('BBM92 QBER threshold:         %.4f\n', qber_threshold);
    fprintf('============================================================\n\n');


    % ==============================================================
    % Reference state
    % ==============================================================

    psi_reference = bell_state('psi_plus');

    rho_reference = state_to_density_matrix(psi_reference);

    H = computational_basis('0');
    V = computational_basis('1');

    HV = tensor_product(H, V);
    VH = tensor_product(V, H);


    % ==============================================================
    % Allocate result arrays
    % ==============================================================

    phase_results = initialize_result_arrays( ...
        num_phase_points);

    dephasing_results = initialize_result_arrays( ...
        num_dephasing_points);

    depolarization_results = initialize_result_arrays( ...
        num_depolarization_points);


    % ==============================================================
    % Model 1 - Coherent relative-phase evolution
    % ==============================================================
    %
    % The initial state is
    %
    %   |Psi+> =
    %   (|HV> + |VH>) / sqrt(2).
    %
    % A local phase transformation is applied to arm B. The resulting
    % state remains pure and maximally entangled, while its correlations
    % in the fixed diagonal measurement basis vary with theta.
    %
    % ==============================================================

    fprintf('Computing coherent phase model...\n');

    for k = 1:num_phase_points

        theta = theta_values(k);

        U_B = phase_unitary(theta);

        psi_out = apply_unitary( ...
            eye(2), ...
            U_B, ...
            psi_reference);

        rho_out = state_to_density_matrix(psi_out);

        phase_results = evaluate_state( ...
            phase_results, ...
            k, ...
            rho_out, ...
            rho_reference, ...
            qber_threshold);

    end


    % ==============================================================
    % Model 2 - Statistical dephasing
    % ==============================================================
    %
    % The reduced Bell-state family is
    %
    %   rho(mu) =
    %
    %       1/2 |HV><HV|
    %       +
    %       1/2 |VH><VH|
    %       +
    %       mu/2 |HV><VH|
    %       +
    %       mu/2 |VH><HV|,
    %
    % with real mu in [0,1].
    %
    % Therefore:
    %
    %   mu = 1  -> ideal |Psi+>
    %   mu = 0  -> complete dephasing.
    %
    % For this state family:
    %
    %   C   = mu
    %   Q_Z = 0
    %   Q_X = (1 - mu)/2.
    %
    % ==============================================================

    fprintf('Computing statistical dephasing model...\n');

    for k = 1:num_dephasing_points

        mu = coherence_values(k);

        rho_out = ...
            0.5 * (HV * HV') + ...
            0.5 * (VH * VH') + ...
            0.5 * mu * (HV * VH') + ...
            0.5 * mu * (VH * HV');

        dephasing_results = evaluate_state( ...
            dephasing_results, ...
            k, ...
            rho_out, ...
            rho_reference, ...
            qber_threshold);

    end


    % ==============================================================
    % Model 3 - Symmetric two-arm depolarization
    % ==============================================================
    %
    % The same local depolarization probability is applied to both arms:
    %
    %   p_A = p_B = p.
    %
    % ==============================================================

    fprintf('Computing symmetric two-arm depolarization model...\n');

    for k = 1:num_depolarization_points

        p = p_values(k);

        rho_out = two_arm_depolarizing_channel( ...
            rho_reference, ...
            p, ...
            p);

        depolarization_results = evaluate_state( ...
            depolarization_results, ...
            k, ...
            rho_out, ...
            rho_reference, ...
            qber_threshold);

    end


    % ==============================================================
    % Extract operating boundaries
    % ==============================================================

    phase_boundary = extract_operating_boundary( ...
        theta_values, ...
        phase_results.Q_worst, ...
        qber_threshold);

    % coherence_values is decreasing, whereas the generic boundary
    % extraction routine requires a strictly increasing parameter vector.

    coherence_values_increasing = flip( ...
        coherence_values);

    dephasing_Q_worst_increasing = flip( ...
        dephasing_results.Q_worst);

    dephasing_boundary = extract_operating_boundary( ...
        coherence_values_increasing, ...
        dephasing_Q_worst_increasing, ...
        qber_threshold);

    depolarization_boundary = extract_operating_boundary( ...
        p_values, ...
        depolarization_results.Q_worst, ...
        qber_threshold);


    % ==============================================================
    % Analytical consistency checks
    % ==============================================================

    % --------------------------------------------------------------
    % Coherent phase
    % --------------------------------------------------------------
    %
    % Expected:
    %
    %   C   = 1
    %   Q_Z = 0
    %   Q_X = (1 - cos(theta))/2.
    %
    % --------------------------------------------------------------

    analytical_phase_Q_X = ...
        (1 - cos(theta_values)) / 2;

    phase_Q_error = max(abs( ...
        phase_results.Q_X - analytical_phase_Q_X));

    phase_C_error = max(abs( ...
        phase_results.concurrence - 1));


    % --------------------------------------------------------------
    % Statistical dephasing
    % --------------------------------------------------------------
    %
    % Expected:
    %
    %   C   = mu
    %   Q_Z = 0
    %   Q_X = (1 - mu)/2.
    %
    % --------------------------------------------------------------

    analytical_dephasing_Q_X = ...
        (1 - coherence_values) / 2;

    dephasing_Q_error = max(abs( ...
        dephasing_results.Q_X - analytical_dephasing_Q_X));

    dephasing_C_error = max(abs( ...
        dephasing_results.concurrence - coherence_values));


    % --------------------------------------------------------------
    % Print numerical consistency
    % --------------------------------------------------------------

    fprintf('\n');
    fprintf('Numerical consistency\n');
    fprintf('------------------------------------------------------------\n');
    fprintf('Max phase Q_X error:          %.16e\n', phase_Q_error);
    fprintf('Max phase concurrence error:  %.16e\n', phase_C_error);
    fprintf('Max dephasing Q_X error:      %.16e\n', dephasing_Q_error);
    fprintf('Max dephasing C error:        %.16e\n', dephasing_C_error);


    % --------------------------------------------------------------
    % Enforce analytical consistency
    % --------------------------------------------------------------

    assert(phase_Q_error < tolerance, ...
        'experiment_01_effective_models_bbm92:PhaseQBERMismatch', ...
        'Coherent-phase QBER does not match the analytical result.');

    assert(phase_C_error < concurrence_tolerance, ...
        'experiment_01_effective_models_bbm92:PhaseConcurrenceMismatch', ...
        ['Coherent phase evolution must preserve concurrence within ', ...
         'numerical precision.']);

    assert(dephasing_Q_error < tolerance, ...
        'experiment_01_effective_models_bbm92:DephasingQBERMismatch', ...
        'Dephasing QBER does not match the analytical result.');

    assert(dephasing_C_error < concurrence_tolerance, ...
        'experiment_01_effective_models_bbm92:DephasingConcurrenceMismatch', ...
        ['Dephasing concurrence does not match the analytical result ', ...
         'within numerical precision.']);


    % ==============================================================
    % Assemble output structure
    % ==============================================================

    results = struct();

    results.qber_threshold = qber_threshold;

    results.parameters.theta = theta_values;

    results.parameters.coherence = ...
        coherence_values;

    results.parameters.depolarization_probability = ...
        p_values;

    results.phase.theta = theta_values;
    results.phase.metrics = phase_results;
    results.phase.boundary = phase_boundary;

    results.dephasing.coherence = coherence_values;
    results.dephasing.metrics = dephasing_results;
    results.dephasing.boundary = dephasing_boundary;

    results.depolarization.p = p_values;
    results.depolarization.metrics = depolarization_results;
    results.depolarization.boundary = depolarization_boundary;

    results.validation.phase_Q_error = ...
        phase_Q_error;

    results.validation.phase_C_error = ...
        phase_C_error;

    results.validation.dephasing_Q_error = ...
        dephasing_Q_error;

    results.validation.dephasing_C_error = ...
        dephasing_C_error;

    results.validation.tolerance = ...
        tolerance;

    results.validation.concurrence_tolerance = ...
        concurrence_tolerance;


    % ==============================================================
    % Console summary
    % ==============================================================

    fprintf('\n');
    fprintf('BBM92 operating boundaries\n');
    fprintf('------------------------------------------------------------\n');

    print_boundary( ...
        'Coherent phase theta', ...
        phase_boundary, ...
        'rad');

    print_boundary( ...
        'Dephasing coherence', ...
        dephasing_boundary, ...
        '');

    print_boundary( ...
        'Depolarization p', ...
        depolarization_boundary, ...
        '');

    fprintf('============================================================\n\n');


    % ==============================================================
    % Generate figures
    % ==============================================================
    %
    % Figures are generated when either visualization or saving is
    % requested. This allows do_plot = false and do_save = true.
    %
    % ==============================================================

    figure_handles = struct();

    if do_plot || do_save

        figure_handles = build_experiment_plots( ...
            theta_values, ...
            coherence_values, ...
            p_values, ...
            phase_results, ...
            dephasing_results, ...
            depolarization_results, ...
            qber_threshold, ...
            do_plot);

    end


    % ==============================================================
    % Save thesis figures
    % ==============================================================

    if do_save

        % ----------------------------------------------------------
        % Locate project root
        % ----------------------------------------------------------
        %
        % The experiment determines the project root from its own file
        % location rather than relying on the current MATLAB directory.
        %
        % The search terminates when the directory containing
        %
        %   text/thesis
        %
        % is found.
        %
        % ----------------------------------------------------------

        experiment_file = mfilename('fullpath');

        experiment_directory = fileparts( ...
            experiment_file);

        project_root = experiment_directory;

        while ~isfolder(fullfile( ...
                project_root, ...
                'text', ...
                'thesis'))

            parent_directory = fileparts( ...
                project_root);

            if strcmp( ...
                    parent_directory, ...
                    project_root)

                error( ...
                    ['experiment_01_effective_models_bbm92:', ...
                     'ProjectRootNotFound'], ...
                    ['Unable to locate the project root containing ', ...
                     'text/thesis.']);

            end

            project_root = parent_directory;

        end


        % ----------------------------------------------------------
        % Thesis output directory
        % ----------------------------------------------------------

        output_directory = fullfile( ...
            project_root, ...
            'text', ...
            'thesis', ...
            'figures', ...
            'experiment_1');

        if ~exist(output_directory, 'dir')

            mkdir(output_directory);

        end


        % ----------------------------------------------------------
        % Export configuration
        % ----------------------------------------------------------

        export_resolution = 300;


        % ----------------------------------------------------------
        % Export complete thesis figures
        % ----------------------------------------------------------

        fprintf('Saving thesis figures...\n');
        fprintf('Output directory:\n');
        fprintf('%s\n\n', output_directory);


        % Coherent relative-phase summary

        exportgraphics( ...
            figure_handles.phase, ...
            fullfile( ...
                output_directory, ...
                'phase_summary.png'), ...
            'Resolution', ...
            export_resolution);


        % Statistical-dephasing summary

        exportgraphics( ...
            figure_handles.dephasing, ...
            fullfile( ...
                output_directory, ...
                'dephasing_summary.png'), ...
            'Resolution', ...
            export_resolution);


        % Symmetric two-arm depolarization summary

        exportgraphics( ...
            figure_handles.depolarization, ...
            fullfile( ...
                output_directory, ...
                'depolarization_summary.png'), ...
            'Resolution', ...
            export_resolution);


        % Concurrence-QBER operational comparison

        exportgraphics( ...
            figure_handles.operational, ...
            fullfile( ...
                output_directory, ...
                'concurrence_vs_qber.png'), ...
            'Resolution', ...
            export_resolution);


        % ----------------------------------------------------------
        % Console confirmation
        % ----------------------------------------------------------

        fprintf('Saved thesis figures:\n');
        fprintf('  phase_summary.png\n');
        fprintf('  dephasing_summary.png\n');
        fprintf('  depolarization_summary.png\n');
        fprintf('  concurrence_vs_qber.png\n\n');

    end

end


% ==================================================================
% Local function - Initialize metric arrays
% ==================================================================

function result = initialize_result_arrays(num_points)

    result = struct();

    result.purity = zeros(1, num_points);

    result.fidelity = zeros(1, num_points);

    result.concurrence = zeros(1, num_points);

    result.Q_Z = zeros(1, num_points);

    result.Q_X = zeros(1, num_points);

    result.Q_mean = zeros(1, num_points);

    result.Q_worst = zeros(1, num_points);

    result.margin = zeros(1, num_points);

    result.is_operational = false(1, num_points);

end


% ==================================================================
% Local function - Evaluate propagated state
% ==================================================================

function result = evaluate_state( ...
        result, ...
        index, ...
        rho, ...
        rho_reference, ...
        qber_threshold)

    result.purity(index) = ...
        compute_purity(rho);

    result.fidelity(index) = ...
        compute_fidelity( ...
            rho, ...
            rho_reference);

    result.concurrence(index) = ...
        compute_concurrence(rho);

    qber = compute_bbm92_qber(rho);

    classification = classify_bbm92_operation( ...
        qber, ...
        qber_threshold);

    result.Q_Z(index) = ...
        qber.Q_Z;

    result.Q_X(index) = ...
        qber.Q_X;

    result.Q_mean(index) = ...
        qber.Q_mean;

    result.Q_worst(index) = ...
        classification.Q_worst;

    result.margin(index) = ...
        classification.margin_worst;

    result.is_operational(index) = ...
        classification.is_operational;

end


% ==================================================================
% Local function - Print operating boundary
% ==================================================================

function print_boundary(name, boundary, unit)

    if boundary.num_crossings == 0

        fprintf( ...
            '%-28s : no crossing\n', ...
            name);

        return;

    end

    if isempty(unit)

        fprintf( ...
            '%-28s : %.6f\n', ...
            name, ...
            boundary.first_crossing);

    else

        fprintf( ...
            '%-28s : %.6f %s\n', ...
            name, ...
            boundary.first_crossing, ...
            unit);

    end

end


% ==================================================================
% Local function - Build experiment plots
% ==================================================================

function figure_handles = build_experiment_plots( ...
        theta_values, ...
        coherence_values, ...
        p_values, ...
        phase_results, ...
        dephasing_results, ...
        depolarization_results, ...
        qber_threshold, ...
        do_plot)

    figure_handles = struct();

    if do_plot
        figure_visibility = 'on';
    else
        figure_visibility = 'off';
    end


    % ==============================================================
    % Figure 1 - Coherent phase evolution
    % ==============================================================

    figure_handles.phase = figure( ...
        'Name', ...
        'Experiment 1 - Coherent Phase', ...
        'Visible', ...
        figure_visibility);

    tiledlayout(2, 1);


    % --------------------------------------------------------------
    % State metrics
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        theta_values / pi, ...
        phase_results.concurrence, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        theta_values / pi, ...
        phase_results.fidelity, ...
        'LineWidth', ...
        1.5);

    plot( ...
        theta_values / pi, ...
        phase_results.purity, ...
        'LineWidth', ...
        1.5);

    hold off;

    xlabel('\theta / \pi');

    ylabel('State metric');

    legend( ...
        'Concurrence', ...
        'Fidelity', ...
        'Purity', ...
        'Location', ...
        'best');

    ylim([0, 1.05]);

    grid on;


    % --------------------------------------------------------------
    % BBM92 QBER
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        theta_values / pi, ...
        phase_results.Q_Z, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        theta_values / pi, ...
        phase_results.Q_X, ...
        'LineWidth', ...
        1.5);

    yline( ...
        qber_threshold, ...
        '--', ...
        'Q_{th}', ...
        'LineWidth', ...
        1.2);

    hold off;

    xlabel('\theta / \pi');

    ylabel('QBER');

    legend( ...
        'Q_Z', ...
        'Q_X', ...
        'Location', ...
        'best');

    ylim([0, 1.05]);

    grid on;


    % ==============================================================
    % Figure 2 - Statistical dephasing
    % ==============================================================

    figure_handles.dephasing = figure( ...
        'Name', ...
        'Experiment 1 - Dephasing', ...
        'Visible', ...
        figure_visibility);

    tiledlayout(2, 1);


    % --------------------------------------------------------------
    % State metrics
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        coherence_values, ...
        dephasing_results.concurrence, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        coherence_values, ...
        dephasing_results.fidelity, ...
        'LineWidth', ...
        1.5);

    plot( ...
        coherence_values, ...
        dephasing_results.purity, ...
        'LineWidth', ...
        1.5);

    hold off;

    set(gca, ...
        'XDir', ...
        'reverse');

    xlabel('Coherence |\mu|');

    ylabel('State metric');

    legend( ...
        'Concurrence', ...
        'Fidelity', ...
        'Purity', ...
        'Location', ...
        'best');

    ylim([0, 1.05]);

    grid on;


    % --------------------------------------------------------------
    % BBM92 QBER
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        coherence_values, ...
        dephasing_results.Q_Z, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        coherence_values, ...
        dephasing_results.Q_X, ...
        'LineWidth', ...
        1.5);

    yline( ...
        qber_threshold, ...
        '--', ...
        'Q_{th}', ...
        'LineWidth', ...
        1.2);

    hold off;

    set(gca, ...
        'XDir', ...
        'reverse');

    xlabel('Coherence |\mu|');

    ylabel('QBER');

    legend( ...
        'Q_Z', ...
        'Q_X', ...
        'Location', ...
        'best');

    ylim([0, 0.55]);

    grid on;


    % ==============================================================
    % Figure 3 - Symmetric two-arm depolarization
    % ==============================================================

    figure_handles.depolarization = figure( ...
        'Name', ...
        'Experiment 1 - Depolarization', ...
        'Visible', ...
        figure_visibility);

    tiledlayout(2, 1);


    % --------------------------------------------------------------
    % State metrics
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        p_values, ...
        depolarization_results.concurrence, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        p_values, ...
        depolarization_results.fidelity, ...
        'LineWidth', ...
        1.5);

    plot( ...
        p_values, ...
        depolarization_results.purity, ...
        'LineWidth', ...
        1.5);

    hold off;

    xlabel('Local depolarization probability p');

    ylabel('State metric');

    legend( ...
        'Concurrence', ...
        'Fidelity', ...
        'Purity', ...
        'Location', ...
        'best');

    ylim([0, 1.05]);

    grid on;


    % --------------------------------------------------------------
    % BBM92 QBER
    % --------------------------------------------------------------

    nexttile;

    plot( ...
        p_values, ...
        depolarization_results.Q_Z, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        p_values, ...
        depolarization_results.Q_X, ...
        'LineWidth', ...
        1.5);

    yline( ...
        qber_threshold, ...
        '--', ...
        'Q_{th}', ...
        'LineWidth', ...
        1.2);

    hold off;

    xlabel('Local depolarization probability p');

    ylabel('QBER');

    legend( ...
        'Q_Z', ...
        'Q_X', ...
        'Location', ...
        'best');

    ylim([0, 0.55]);

    grid on;


    % ==============================================================
    % Figure 4 - Direct operational comparison
    % ==============================================================

    figure_handles.operational = figure( ...
        'Name', ...
        'Experiment 1 - Operational Comparison', ...
        'Visible', ...
        figure_visibility);

    plot( ...
        phase_results.concurrence, ...
        phase_results.Q_worst, ...
        'LineWidth', ...
        1.5);

    hold on;

    plot( ...
        dephasing_results.concurrence, ...
        dephasing_results.Q_worst, ...
        'LineWidth', ...
        1.5);

    plot( ...
        depolarization_results.concurrence, ...
        depolarization_results.Q_worst, ...
        'LineWidth', ...
        1.5);

    yline( ...
        qber_threshold, ...
        '--', ...
        'Q_{th}', ...
        'LineWidth', ...
        1.2);

    hold off;

    xlabel('Concurrence C');

    ylabel('Worst-basis QBER');

    legend( ...
        'Coherent phase', ...
        'Dephasing', ...
        'Two-arm depolarization', ...
        'Location', ...
        'best');

    xlim([0, 1.05]);

    ylim([0, 1.05]);

    grid on;

end