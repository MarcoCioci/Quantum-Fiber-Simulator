function results = experiment_02_single_arm_pmd_operating_region( ...
        do_plot, do_save)
% EXPERIMENT_02_SINGLE_ARM_PMD_OPERATING_REGION
% Source-fiber BBM92 operating region under single-arm PMD.
%
% Objective:
%   Determine how the source spectral bandwidth sigma_omega and the
%   differential group delay delta_tau of one fiber arm determine the
%   BBM92 operating region.
%
%   The normalized PMD strength is
%
%       chi = sigma_omega * delta_tau.
%
%   The source emits |Psi+>. Photon A propagates through one first-order
%   PMD segment aligned with the x axis, while photon B is unaffected.
%
%   The joint spectrum is Gaussian and uncorrelated, with equal marginal
%   bandwidth sigma_omega for the two photons.
%
%   The reduced polarization state is obtained by tracing over the
%   unresolved joint spectrum.
%
%   The operational quantity is
%
%       Q_worst = max(Q_Z, Q_X),
%
%   and the adopted BBM92 operating condition is
%
%       Q_worst < Q_th.
%
% Inputs:
%   do_plot - Logical flag enabling figure visualization.
%   do_save - Logical flag enabling thesis-ready PNG export.
%
% Output:
%   results - Structure containing parameter grids, concurrence, QBER,
%             operating region, and normalized operating boundary.


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

    num_bandwidth_points = 41;

    num_dgd_points = 121;

    num_frequency_nodes = 81;

    spectral_window_sigma = 6.0;

    qber_threshold = 0.11;


    % --------------------------------------------------------------
    % Physical parameter ranges
    % --------------------------------------------------------------

    sigma_omega_values = linspace( ...
        0.25e11, ...
        2.00e11, ...
        num_bandwidth_points);

    delta_tau_values = linspace( ...
        0, ...
        30e-12, ...
        num_dgd_points);


    % ==============================================================
    % PMD configuration
    % ==============================================================

    % Arm A:
    % one PMD segment aligned with the x axis.
    %
    % The carrier-frequency differential phase is zero so that only the
    % frequency-dependent PMD contribution is investigated.

    delta_phase_A = 0;

    pmd_axis_A = [1, 0, 0];


    % Arm B:
    % ideal reference arm represented by a zero-DGD segment.

    delta_phase_B = 0;

    delta_tau_B = 0;

    pmd_axis_B = [0, 0, 1];


    % ==============================================================
    % Reference state
    % ==============================================================

    psi_reference = bell_state( ...
        'psi_plus');

    rho_reference = state_to_density_matrix( ...
        psi_reference);


    % ==============================================================
    % Console header
    % ==============================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf(' Experiment 2 - Single-Arm PMD BBM92 Operating Region\n');
    fprintf('============================================================\n');
    fprintf('Bandwidth points:             %d\n', ...
        num_bandwidth_points);
    fprintf('DGD points:                   %d\n', ...
        num_dgd_points);
    fprintf('Frequency nodes / arm:        %d\n', ...
        num_frequency_nodes);
    fprintf('Spectral window:              +/- %.1f sigma_omega\n', ...
        spectral_window_sigma);
    fprintf('Bandwidth range:              [%.3e, %.3e] rad/s\n', ...
        min(sigma_omega_values), ...
        max(sigma_omega_values));
    fprintf('DGD range:                    [%.3f, %.3f] ps\n', ...
        min(delta_tau_values) * 1e12, ...
        max(delta_tau_values) * 1e12);
    fprintf('PMD axis arm A:               [%.1f %.1f %.1f]\n', ...
        pmd_axis_A);
    fprintf('BBM92 QBER threshold:         %.4f\n', ...
        qber_threshold);
    fprintf('============================================================\n\n');


    % ==============================================================
    % Allocate result maps
    % ==============================================================

    map_size = [ ...
        num_bandwidth_points, ...
        num_dgd_points];

    concurrence_map = zeros( ...
        map_size);

    Q_Z_map = zeros( ...
        map_size);

    Q_X_map = zeros( ...
        map_size);

    Q_worst_map = zeros( ...
        map_size);

    operating_mask = false( ...
        map_size);


    % ==============================================================
    % Source-fiber parameter sweep
    % ==============================================================

    fprintf('Computing source-fiber parameter map...\n\n');

    for i_sigma = 1:num_bandwidth_points

        sigma_omega = ...
            sigma_omega_values(i_sigma);


        % ----------------------------------------------------------
        % Frequency grid
        % ----------------------------------------------------------

        max_frequency_offset = ...
            spectral_window_sigma * sigma_omega;

        omega_offsets_A = pmd_frequency_grid( ...
            num_frequency_nodes, ...
            max_frequency_offset);

        omega_offsets_B = pmd_frequency_grid( ...
            num_frequency_nodes, ...
            max_frequency_offset);


        % ----------------------------------------------------------
        % Uncorrelated Gaussian joint spectrum
        % ----------------------------------------------------------
        %
        % The PMD spectral model uses sigma_sum and sigma_difference.
        %
        % Equal uncorrelated marginal bandwidths sigma_omega correspond
        % to
        %
        %   sigma_sum        = sqrt(2) sigma_omega
        %   sigma_difference = sqrt(2) sigma_omega.
        %
        % ----------------------------------------------------------

        sigma_sum = ...
            sqrt(2) * sigma_omega;

        sigma_difference = ...
            sqrt(2) * sigma_omega;

        spectral_weights = pmd_joint_spectral_weights( ...
            omega_offsets_A, ...
            omega_offsets_B, ...
            sigma_sum, ...
            sigma_difference);


        fprintf( ...
            'Bandwidth %2d/%2d: sigma_omega = %.3e rad/s\n', ...
            i_sigma, ...
            num_bandwidth_points, ...
            sigma_omega);


        % ----------------------------------------------------------
        % DGD sweep
        % ----------------------------------------------------------

        for i_dgd = 1:num_dgd_points

            delta_tau_A = ...
                delta_tau_values(i_dgd);


            % ------------------------------------------------------
            % Frequency-resolved propagation
            % ------------------------------------------------------

            frequency_states = pmd_frequency_resolved_states( ...
                rho_reference, ...
                omega_offsets_A, ...
                omega_offsets_B, ...
                delta_phase_A, ...
                delta_tau_A, ...
                pmd_axis_A, ...
                delta_phase_B, ...
                delta_tau_B, ...
                pmd_axis_B);


            % ------------------------------------------------------
            % Spectral trace
            % ------------------------------------------------------

            rho_pol = pmd_spectral_average_state( ...
                frequency_states, ...
                spectral_weights);


            % ------------------------------------------------------
            % State and operational quantities
            % ------------------------------------------------------

            concurrence_map(i_sigma, i_dgd) = ...
                compute_concurrence( ...
                    rho_pol);

            qber = compute_bbm92_qber( ...
                rho_pol);

            Q_Z_map(i_sigma, i_dgd) = ...
                qber.Q_Z;

            Q_X_map(i_sigma, i_dgd) = ...
                qber.Q_X;

            Q_worst_map(i_sigma, i_dgd) = ...
                max( ...
                    qber.Q_Z, ...
                    qber.Q_X);

            operating_mask(i_sigma, i_dgd) = ...
                Q_worst_map(i_sigma, i_dgd) < ...
                qber_threshold;

        end

    end


    % ==============================================================
    % Extract numerical BBM92 boundary
    % ==============================================================

    delta_tau_boundary = nan( ...
        1, ...
        num_bandwidth_points);

    chi_boundary = nan( ...
        1, ...
        num_bandwidth_points);

    concurrence_boundary = nan( ...
        1, ...
        num_bandwidth_points);


    for i_sigma = 1:num_bandwidth_points

        boundary = extract_operating_boundary( ...
            delta_tau_values, ...
            Q_worst_map(i_sigma, :), ...
            qber_threshold);

        if boundary.num_crossings > 0

            delta_tau_boundary(i_sigma) = ...
                boundary.first_crossing;

            chi_boundary(i_sigma) = ...
                sigma_omega_values(i_sigma) * ...
                boundary.first_crossing;

            concurrence_boundary(i_sigma) = interp1( ...
                delta_tau_values, ...
                concurrence_map(i_sigma, :), ...
                boundary.first_crossing, ...
                'linear');

        end

    end


    % ==============================================================
    % Analytical normalized boundary
    % ==============================================================
    %
    % For the present Gaussian single-arm PMD configuration,
    %
    %   C(chi) = exp(-chi^2 / 2)
    %
    % and, for the selected PMD-axis orientation,
    %
    %   Q_worst = (1 - C) / 2.
    %
    % Therefore
    %
    %   chi_th =
    %       sqrt[-2 log(1 - 2 Q_th)].
    %
    % ==============================================================

    chi_boundary_analytical = ...
        sqrt( ...
            -2 * log( ...
                1 - 2 * qber_threshold));


    % ==============================================================
    % Boundary statistics
    % ==============================================================

    valid_boundary = ...
        ~isnan(chi_boundary);

    mean_chi_boundary = mean( ...
        chi_boundary(valid_boundary));

    std_chi_boundary = std( ...
        chi_boundary(valid_boundary));

    max_chi_error = max(abs( ...
        chi_boundary(valid_boundary) - ...
        chi_boundary_analytical));

    mean_concurrence_boundary = mean( ...
        concurrence_boundary(valid_boundary));

    std_concurrence_boundary = std( ...
        concurrence_boundary(valid_boundary));


    % ==============================================================
    % Numerical consistency
    % ==============================================================

    zero_dgd_concurrence_error = max(abs( ...
        concurrence_map(:, 1) - 1));

    zero_dgd_Q_Z_error = max(abs( ...
        Q_Z_map(:, 1)));

    zero_dgd_Q_X_error = max(abs( ...
        Q_X_map(:, 1)));

    max_protected_basis_error = max( ...
        abs(Q_X_map(:)));


    % ==============================================================
    % Console summary
    % ==============================================================

    fprintf('\n');
    fprintf('Numerical consistency\n');
    fprintf('------------------------------------------------------------\n');

    fprintf( ...
        'Zero-DGD concurrence error:   %.3e\n', ...
        zero_dgd_concurrence_error);

    fprintf( ...
        'Zero-DGD Q_Z error:           %.3e\n', ...
        zero_dgd_Q_Z_error);

    fprintf( ...
        'Zero-DGD Q_X error:           %.3e\n', ...
        zero_dgd_Q_X_error);

    fprintf( ...
        'Max protected-basis Q_X:      %.3e\n', ...
        max_protected_basis_error);


    fprintf('\n');
    fprintf('BBM92 operating-region summary\n');
    fprintf('------------------------------------------------------------\n');

    fprintf( ...
        'Analytical chi threshold:     %.6f\n', ...
        chi_boundary_analytical);

    fprintf( ...
        'Mean numerical chi threshold: %.6f\n', ...
        mean_chi_boundary);

    fprintf( ...
        'Std numerical chi threshold:  %.3e\n', ...
        std_chi_boundary);

    fprintf( ...
        'Max chi boundary error:        %.3e\n', ...
        max_chi_error);

    fprintf( ...
        'Mean C at QBER boundary:       %.6f\n', ...
        mean_concurrence_boundary);

    fprintf( ...
        'Std C at QBER boundary:        %.3e\n', ...
        std_concurrence_boundary);

    fprintf('============================================================\n\n');


    % ==============================================================
    % Assemble results
    % ==============================================================

    results = struct();


    % --------------------------------------------------------------
    % Parameters
    % --------------------------------------------------------------

    results.parameters.sigma_omega = ...
        sigma_omega_values;

    results.parameters.delta_tau = ...
        delta_tau_values;

    results.parameters.pmd_axis_A = ...
        pmd_axis_A;

    results.parameters.qber_threshold = ...
        qber_threshold;

    results.parameters.num_frequency_nodes = ...
        num_frequency_nodes;

    results.parameters.spectral_window_sigma = ...
        spectral_window_sigma;


    % --------------------------------------------------------------
    % Maps
    % --------------------------------------------------------------

    results.maps.concurrence = ...
        concurrence_map;

    results.maps.Q_Z = ...
        Q_Z_map;

    results.maps.Q_X = ...
        Q_X_map;

    results.maps.Q_worst = ...
        Q_worst_map;

    results.maps.operating = ...
        operating_mask;


    % --------------------------------------------------------------
    % Boundary
    % --------------------------------------------------------------

    results.boundary.delta_tau = ...
        delta_tau_boundary;

    results.boundary.chi = ...
        chi_boundary;

    results.boundary.chi_analytical = ...
        chi_boundary_analytical;

    results.boundary.concurrence = ...
        concurrence_boundary;

    results.boundary.mean_chi = ...
        mean_chi_boundary;

    results.boundary.std_chi = ...
        std_chi_boundary;

    results.boundary.max_chi_error = ...
        max_chi_error;

    results.boundary.mean_concurrence = ...
        mean_concurrence_boundary;


    % ==============================================================
    % Figures
    % ==============================================================

    figure_handles = struct();

    if do_plot || do_save

        figure_handles = build_experiment_plots( ...
            sigma_omega_values, ...
            delta_tau_values, ...
            Q_worst_map, ...
            concurrence_map, ...
            delta_tau_boundary, ...
            chi_boundary, ...
            chi_boundary_analytical, ...
            qber_threshold, ...
            do_plot);

    end


    % ==============================================================
    % Save figures
    % ==============================================================

    if do_save

        project_root = locate_project_root();

        output_directory = fullfile( ...
            project_root, ...
            'text', ...
            'thesis', ...
            'figures', ...
            'experiment_2');

        if ~exist(output_directory, 'dir')

            mkdir( ...
                output_directory);

        end


        fprintf('Saving thesis figures...\n');

        fprintf( ...
            'Output directory:\n%s\n\n', ...
            output_directory);


        exportgraphics( ...
            figure_handles.operating_region, ...
            fullfile( ...
                output_directory, ...
                'single_arm_pmd_operating_region.png'), ...
            'Resolution', ...
            300);

        exportgraphics( ...
            figure_handles.concurrence, ...
            fullfile( ...
                output_directory, ...
                'single_arm_pmd_concurrence_map.png'), ...
            'Resolution', ...
            300);

        exportgraphics( ...
            figure_handles.normalized_boundary, ...
            fullfile( ...
                output_directory, ...
                'single_arm_pmd_normalized_boundary.png'), ...
            'Resolution', ...
            300);


        fprintf('Saved thesis figures:\n');

        fprintf( ...
            '  single_arm_pmd_operating_region.png\n');

        fprintf( ...
            '  single_arm_pmd_concurrence_map.png\n');

        fprintf( ...
            '  single_arm_pmd_normalized_boundary.png\n\n');

    end

end


% ==================================================================
% Local function - Build experiment plots
% ==================================================================

function figure_handles = build_experiment_plots( ...
        sigma_omega_values, ...
        delta_tau_values, ...
        Q_worst_map, ...
        concurrence_map, ...
        delta_tau_boundary, ...
        chi_boundary, ...
        chi_boundary_analytical, ...
        qber_threshold, ...
        do_plot)

    figure_handles = struct();


    % ==============================================================
    % Visibility
    % ==============================================================

    if do_plot

        figure_visibility = 'on';

    else

        figure_visibility = 'off';

    end


    % ==============================================================
    % Plot coordinates
    % ==============================================================

    bandwidth_plot = ...
        sigma_omega_values / 1e11;

    dgd_plot = ...
        delta_tau_values * 1e12;

    boundary_dgd_plot = ...
        delta_tau_boundary * 1e12;


    % ==============================================================
    % Figure 1 - Physical BBM92 operating map
    % ==============================================================

    figure_handles.operating_region = figure( ...
        'Name', ...
        'Experiment 2 - Single-Arm PMD Operating Region', ...
        'Visible', ...
        figure_visibility);

    imagesc( ...
        dgd_plot, ...
        bandwidth_plot, ...
        Q_worst_map);

    set( ...
        gca, ...
        'YDir', ...
        'normal');

    hold on;

    plot( ...
        boundary_dgd_plot, ...
        bandwidth_plot, ...
        'k--', ...
        'LineWidth', ...
        2.0);

    hold off;

    xlabel( ...
        'Differential group delay \Delta\tau [ps]');

    ylabel( ...
        'Spectral bandwidth \sigma_\omega [10^{11} rad/s]');

    title( ...
        'Single-arm PMD: worst-basis BBM92 QBER');

    colorbar;

    clim([0, 0.5]);

    grid on;


    % ==============================================================
    % Figure 2 - Concurrence and operational boundary
    % ==============================================================

    figure_handles.concurrence = figure( ...
        'Name', ...
        'Experiment 2 - Concurrence and BBM92 Boundary', ...
        'Visible', ...
        figure_visibility);

    imagesc( ...
        dgd_plot, ...
        bandwidth_plot, ...
        concurrence_map);

    set( ...
        gca, ...
        'YDir', ...
        'normal');

    hold on;

    plot( ...
        boundary_dgd_plot, ...
        bandwidth_plot, ...
        'k--', ...
        'LineWidth', ...
        2.0);

    hold off;

    xlabel( ...
        'Differential group delay \Delta\tau [ps]');

    ylabel( ...
        'Spectral bandwidth \sigma_\omega [10^{11} rad/s]');

    title( ...
        'Concurrence with BBM92 operating boundary');

    colorbar;

    clim([0, 1]);

    grid on;


    % ==============================================================
    % Figure 3 - Normalized PMD boundary
    % ==============================================================

    figure_handles.normalized_boundary = figure( ...
        'Name', ...
        'Experiment 2 - Normalized PMD Boundary', ...
        'Visible', ...
        figure_visibility);

    valid_boundary = ...
        ~isnan(chi_boundary);

    plot( ...
        bandwidth_plot(valid_boundary), ...
        chi_boundary(valid_boundary), ...
        'o-', ...
        'LineWidth', ...
        1.4, ...
        'MarkerSize', ...
        5);

    hold on;

    yline( ...
        chi_boundary_analytical, ...
        '--', ...
        sprintf( ...
            'Analytical \\chi_{th} = %.4f', ...
            chi_boundary_analytical), ...
        'LineWidth', ...
        1.5);

    hold off;

    xlabel( ...
        'Spectral bandwidth \sigma_\omega [10^{11} rad/s]');

    ylabel( ...
        '\chi_{th} = \sigma_\omega \Delta\tau_{th}');

    title( ...
        'Normalized BBM92 operating boundary');

    ylim([0.69, 0.72]);

    grid on;

end


% ==================================================================
% Local function - Locate project root
% ==================================================================

function project_root = locate_project_root()

    experiment_file = ...
        mfilename('fullpath');

    project_root = ...
        fileparts(experiment_file);

    while ~isfolder(fullfile( ...
            project_root, ...
            'text', ...
            'thesis'))

        parent_directory = ...
            fileparts(project_root);

        if strcmp( ...
                parent_directory, ...
                project_root)

            error( ...
                ['experiment_02_single_arm_pmd_operating_region:', ...
                 'ProjectRootNotFound'], ...
                ['Unable to locate the project root containing ', ...
                 'text/thesis.']);

        end

        project_root = ...
            parent_directory;

    end

end