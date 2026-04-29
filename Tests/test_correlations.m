function test_correlations()
% TEST_CORRELATIONS  Validate diagonal and full two-qubit Pauli correlations.
%
% Objective:
%   Verify that the simulator correctly computes:
%
%       1. diagonal Pauli correlations:
%          c_xx, c_yy, c_zz
%
%       2. full Pauli correlation tensor:
%          T(i,j) = Tr[rho_AB * (sigma_i ⊗ sigma_j)]
%
%   for the phase-evolved Bell-like state
%
%       |psi(θ)> = (|01> + exp(i * θ)|10>) / sqrt(2).
%
% Analytical predictions:
%
%       T(θ) =
%         [  cos(θ), -sin(θ),  0  ;
%            sin(θ),  cos(θ),  0  ;
%                 0,       0,  -1 ]
%
%   Therefore:
%
%       c_xx = T(1,1) = cos(θ)
%       c_yy = T(2,2) = cos(θ)
%       c_zz = T(3,3) = -1
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The index convention is:
%
%       1 -> x
%       2 -> y
%       3 -> z
%
%   The test is performed both for:
%       - pure-state vector representation
%       - density-matrix representation

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_correlations...\n');


    % =========================
    % Reference state
    % =========================

    theta = pi / 4;

    psi = ( ...
        computational_basis('01') + ...
        exp(1i * theta) * computational_basis('10') ...
    ) / sqrt(2);

    rho = state_to_density_matrix(psi);

    T_expected = [ ...
         cos(theta), -sin(theta),  0; ...
         sin(theta),  cos(theta),  0; ...
         0,           0,          -1 ...
    ];


    % =========================
    % Test 1: Diagonal correlations from pure state
    % =========================

    correlations_pure = compute_diagonal_correlations(psi);

    assert(abs(correlations_pure.c_xx - T_expected(1,1)) < tolerance, ...
        'test_correlations:PureStateCxxFailed', ...
        'Pure-state correlation c_xx does not match expected value.');

    assert(abs(correlations_pure.c_yy - T_expected(2,2)) < tolerance, ...
        'test_correlations:PureStateCyyFailed', ...
        'Pure-state correlation c_yy does not match expected value.');

    assert(abs(correlations_pure.c_zz - T_expected(3,3)) < tolerance, ...
        'test_correlations:PureStateCzzFailed', ...
        'Pure-state correlation c_zz does not match expected value.');


    % =========================
    % Test 2: Diagonal correlations from density matrix
    % =========================

    correlations_density = compute_diagonal_correlations(rho);

    assert(abs(correlations_density.c_xx - T_expected(1,1)) < tolerance, ...
        'test_correlations:DensityStateCxxFailed', ...
        'Density-matrix correlation c_xx does not match expected value.');

    assert(abs(correlations_density.c_yy - T_expected(2,2)) < tolerance, ...
        'test_correlations:DensityStateCyyFailed', ...
        'Density-matrix correlation c_yy does not match expected value.');

    assert(abs(correlations_density.c_zz - T_expected(3,3)) < tolerance, ...
        'test_correlations:DensityStateCzzFailed', ...
        'Density-matrix correlation c_zz does not match expected value.');


    % =========================
    % Test 3: Full tensor from pure state
    % =========================

    T_pure = compute_correlation_tensor(psi);

    assert(norm(T_pure - T_expected, 'fro') < tolerance, ...
        'test_correlations:PureStateTensorFailed', ...
        'Pure-state correlation tensor does not match analytical prediction.');


    % =========================
    % Test 4: Full tensor from density matrix
    % =========================

    T_density = compute_correlation_tensor(rho);

    assert(norm(T_density - T_expected, 'fro') < tolerance, ...
        'test_correlations:DensityStateTensorFailed', ...
        'Density-matrix correlation tensor does not match analytical prediction.');


    % =========================
    % Consistency check: diagonal correlations are tensor diagonal
    % =========================

    assert(abs(correlations_pure.c_xx - T_pure(1,1)) < tolerance, ...
        'test_correlations:PureDiagonalTensorMismatch', ...
        'Pure-state c_xx does not match T(1,1).');

    assert(abs(correlations_pure.c_yy - T_pure(2,2)) < tolerance, ...
        'test_correlations:PureDiagonalTensorMismatch', ...
        'Pure-state c_yy does not match T(2,2).');

    assert(abs(correlations_pure.c_zz - T_pure(3,3)) < tolerance, ...
        'test_correlations:PureDiagonalTensorMismatch', ...
        'Pure-state c_zz does not match T(3,3).');


    % =========================
    % Success message
    % =========================

    fprintf('test_correlations passed.\n');

end