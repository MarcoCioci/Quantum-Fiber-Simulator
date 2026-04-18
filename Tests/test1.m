function test_all()
% TEST_ALL  Run all tests in sequence

    clc;

    test_bell_state();
    test_density_matrix();
    test_partial_trace();
    test_correlations();

    disp('All tests passed successfully.');
end