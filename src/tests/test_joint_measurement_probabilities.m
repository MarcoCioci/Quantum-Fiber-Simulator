function test_joint_measurement_probabilities()
% TEST_JOINT_MEASUREMENT_PROBABILITIES
% Validate joint projective measurement probabilities for representative
% two-qubit states and local measurement bases.

    tolerance = 1e-12;

    H = computational_basis('0');
    V = computational_basis('1');

    D = (H + V) / sqrt(2);
    A = (H - V) / sqrt(2);

    basis_Z = [H, V];
    basis_X = [D, A];

    psi_plus = bell_state('psi_plus');

    %--------------------------------------------------------------
    % |Psi+> in the Z basis
    %
    % Expected:
    %
    % P(H,H) = 0
    % P(H,V) = 1/2
    % P(V,H) = 1/2
    % P(V,V) = 0
    %--------------------------------------------------------------

    probabilities_Z = compute_joint_measurement_probabilities( ...
        psi_plus, ...
        basis_Z, ...
        basis_Z);

    expected_Z = [ ...
        0,   0.5; ...
        0.5, 0   ...
    ];

    assert( ...
        norm(probabilities_Z - expected_Z, 'fro') < tolerance, ...
        'test_joint_measurement_probabilities:PsiPlusZ', ...
        'Incorrect |Psi+> joint probabilities in the Z basis.');

    %--------------------------------------------------------------
    % |Psi+> in the X basis
    %
    % |Psi+> = (|D,D> - |A,A>) / sqrt(2)
    %
    % Expected:
    %
    % P(D,D) = 1/2
    % P(D,A) = 0
    % P(A,D) = 0
    % P(A,A) = 1/2
    %--------------------------------------------------------------

    probabilities_X = compute_joint_measurement_probabilities( ...
        psi_plus, ...
        basis_X, ...
        basis_X);

    expected_X = [ ...
        0.5, 0; ...
        0,   0.5 ...
    ];

    assert( ...
        norm(probabilities_X - expected_X, 'fro') < tolerance, ...
        'test_joint_measurement_probabilities:PsiPlusX', ...
        'Incorrect |Psi+> joint probabilities in the X basis.');

    %--------------------------------------------------------------
    % Maximally mixed state
    %
    % Every joint outcome must occur with probability 1/4 in any
    % orthonormal product basis.
    %--------------------------------------------------------------

    rho_mixed = eye(4) / 4;

    probabilities_mixed_Z = compute_joint_measurement_probabilities( ...
        rho_mixed, ...
        basis_Z, ...
        basis_Z);

    probabilities_mixed_X = compute_joint_measurement_probabilities( ...
        rho_mixed, ...
        basis_X, ...
        basis_X);

    expected_mixed = ones(2, 2) / 4;

    assert( ...
        norm(probabilities_mixed_Z - expected_mixed, 'fro') < tolerance, ...
        'test_joint_measurement_probabilities:MixedZ', ...
        'Incorrect maximally mixed probabilities in the Z basis.');

    assert( ...
        norm(probabilities_mixed_X - expected_mixed, 'fro') < tolerance, ...
        'test_joint_measurement_probabilities:MixedX', ...
        'Incorrect maximally mixed probabilities in the X basis.');

    %--------------------------------------------------------------
    % Probability normalization
    %--------------------------------------------------------------

    assert( ...
        abs(sum(probabilities_Z, 'all') - 1) < tolerance, ...
        'test_joint_measurement_probabilities:NormalizationZ', ...
        'Z-basis probabilities are not normalized.');

    assert( ...
        abs(sum(probabilities_X, 'all') - 1) < tolerance, ...
        'test_joint_measurement_probabilities:NormalizationX', ...
        'X-basis probabilities are not normalized.');

    fprintf('test_joint_measurement_probabilities passed.\n');

end