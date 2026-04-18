function test_density_matrix()
% TEST_DENSITY_MATRIX  Validate density matrix construction

    disp('Running test_density_matrix...');

    psi = bell_state('psi_plus');
    rho = state_to_density_matrix(psi);

    % Hermiticity
    assert(norm(rho - rho', 'fro') < 1e-12, ...
        'Density matrix is not Hermitian.');

    % Trace = 1
    assert(abs(trace(rho) - 1) < 1e-12, ...
        'Density matrix is not normalized.');

    % Rank = 1 (pure state)
    eigvals = eig(rho);
    assert(sum(abs(eigvals) > 1e-12) == 1, ...
        'Density matrix is not rank-1 for pure state.');

    disp('test_density_matrix passed.');
end