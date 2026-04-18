function test_correlations()
% TEST_CORRELATIONS  Validate correlation observables

    disp('Running test_correlations...');

    theta = pi/4;

    psi = ( ...
        computational_basis('01') + ...
        exp(1i * theta) * computational_basis('10') ...
    ) / sqrt(2);

    results = compute_correlations(psi);

    % Expected:
    % c_xx = cos(theta)
    % c_yy = cos(theta)
    % c_zz = -1

    assert(abs(results.c_xx - cos(theta)) < 1e-12, ...
        'c_xx incorrect.');

    assert(abs(results.c_yy - cos(theta)) < 1e-12, ...
        'c_yy incorrect.');

    assert(abs(results.c_zz + 1) < 1e-12, ...
        'c_zz incorrect.');

    disp('test_correlations passed.');
end