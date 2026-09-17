function classification = classify_bbm92_operation(qber, qber_threshold)
% CLASSIFY_BBM92_OPERATION
% Classify a simulated state according to the adopted BBM92 QBER threshold.
%
% A configuration is classified as operational when both basis-dependent
% QBERs satisfy
%
%   Q_Z < Q_th
%   Q_X < Q_th.
%
% Inputs:
%   qber           - Structure returned by compute_bbm92_qber.
%   qber_threshold - Adopted BBM92 QBER threshold.
%
% Output:
%   classification - Structure containing:
%                    .is_operational
%                    .Q_Z
%                    .Q_X
%                    .Q_worst
%                    .threshold
%                    .margin_Z
%                    .margin_X
%                    .margin_worst

    required_fields = {'Q_Z', 'Q_X'};

    check_required_fields( ...
        qber, ...
        required_fields, ...
        'classify_bbm92_operation:MissingField');

    if ~isscalar(qber_threshold) || ...
       ~isreal(qber_threshold) || ...
       ~isfinite(qber_threshold) || ...
       qber_threshold < 0 || ...
       qber_threshold > 1

        error( ...
            'classify_bbm92_operation:InvalidThreshold', ...
            'QBER threshold must be a finite scalar in the interval [0,1].');

    end

    Q_Z = qber.Q_Z;
    Q_X = qber.Q_X;

    if ~isscalar(Q_Z) || ~isscalar(Q_X) || ...
       ~isfinite(Q_Z) || ~isfinite(Q_X)

        error( ...
            'classify_bbm92_operation:InvalidQBER', ...
            'Q_Z and Q_X must be finite scalar values.');

    end

    Q_worst = max(Q_Z, Q_X);

    margin_Z = qber_threshold - Q_Z;
    margin_X = qber_threshold - Q_X;
    margin_worst = qber_threshold - Q_worst;

    is_operational = ...
        (Q_Z < qber_threshold) && ...
        (Q_X < qber_threshold);

    classification = struct();

    classification.is_operational = is_operational;

    classification.Q_Z = Q_Z;
    classification.Q_X = Q_X;
    classification.Q_worst = Q_worst;

    classification.threshold = qber_threshold;

    classification.margin_Z = margin_Z;
    classification.margin_X = margin_X;
    classification.margin_worst = margin_worst;

end