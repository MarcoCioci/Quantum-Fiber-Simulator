function test_correlations()
% TEST_CORRELATIONS  Validate standard two-qubit Pauli correlations.
%
% Objective:
%   Verify that compute_correlations correctly reproduces the theoretical
%   values of the aligned Pauli-Pauli correlations
%
%       sigma_x ⊗ sigma_x
%       sigma_y ⊗ sigma_y
%       sigma_z ⊗ sigma_z
%
%   for representative two-qubit states.
%
%   The following cases are tested:
%
%       1. Phase-evolved Bell-like pure state:
%          c_xx = cos(theta)
%          c_yy = cos(theta)
%          c_zz = -1
%
%       2. Same state represented as density matrix:
%          same expected correlations
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected value is not matched within
%   numerical tolerance. If all checks pass, a success message is printed.

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_correlations...\n');


    % =========================
    % Test 1: Phase-evolved Bell-like pure state
    % =========================

    theta = pi / 4;

    psi = ( ...
        computational_basis('01') + ...
        exp(1i * theta) * computational_basis('10') ...
    ) / sqrt(2);

    correlations_pure = compute_correlations(psi);

    assert(abs(correlations_pure.c_xx - cos(theta)) < tolerance, ...
        'test_correlations:PureStateCxxFailed', ...
        'Pure-state correlation c_xx does not match cos(theta).');

    assert(abs(correlations_pure.c_yy - cos(theta)) < tolerance, ...
        'test_correlations:PureStateCyyFailed', ...
        'Pure-state correlation c_yy does not match cos(theta).');

    assert(abs(correlations_pure.c_zz + 1) < tolerance, ...
        'test_correlations:PureStateCzzFailed', ...
        'Pure-state correlation c_zz should be -1.');


    % =========================
    % Test 2: Same state as density matrix
    % =========================

    rho = state_to_density_matrix(psi);
    correlations_density = compute_correlations(rho);

    assert(abs(correlations_density.c_xx - cos(theta)) < tolerance, ...
        'test_correlations:DensityStateCxxFailed', ...
        'Density-matrix correlation c_xx does not match cos(theta).');

    assert(abs(correlations_density.c_yy - cos(theta)) < tolerance, ...
        'test_correlations:DensityStateCyyFailed', ...
        'Density-matrix correlation c_yy does not match cos(theta).');

    assert(abs(correlations_density.c_zz + 1) < tolerance, ...
        'test_correlations:DensityStateCzzFailed', ...
        'Density-matrix correlation c_zz should be -1.');


    % =========================
    % Success message
    % =========================

    fprintf('test_correlations passed.\n');

end