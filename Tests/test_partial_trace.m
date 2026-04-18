function test_partial_trace()
% TEST_PARTIAL_TRACE  Validate reduced density operators

    disp('Running test_partial_trace...');

    % =========================
    % Test 1: Bell state
    % =========================

    psi = bell_state('psi_plus');
    rho = state_to_density_matrix(psi);

    rho_A = partial_trace_B(rho);
    rho_B = partial_trace_A(rho);

    expected = eye(2) / 2;

    assert(norm(rho_A - expected, 'fro') < 1e-12, ...
        'rho_A incorrect for Bell state.');

    assert(norm(rho_B - expected, 'fro') < 1e-12, ...
        'rho_B incorrect for Bell state.');

    % =========================
    % Test 2: Phase-evolved Bell state
    % =========================

    theta = pi/3;

    psi_theta = ( ...
        computational_basis('01') + ...
        exp(1i * theta) * computational_basis('10') ...
    ) / sqrt(2);

    rho_theta = state_to_density_matrix(psi_theta);

    rho_A_theta = partial_trace_B(rho_theta);
    rho_B_theta = partial_trace_A(rho_theta);

    assert(norm(rho_A_theta - expected, 'fro') < 1e-12, ...
        'rho_A incorrect for phase-evolved Bell state.');

    assert(norm(rho_B_theta - expected, 'fro') < 1e-12, ...
        'rho_B incorrect for phase-evolved Bell state.');

    disp('test_partial_trace passed.');
end