function objective = evaluate_three_channel_npv( ...
    controls, caseDirectory, stepLength, summaryRow)
%EVALUATE_THREE_CHANNEL_NPV Run the Three-Channel objective workflow.
%
% The optimizer minimizes the negative net present value. Summary columns
% are interpreted according to the Three-Channel BASE.RSM configuration.
% The project-specific schedule writer is linked through the
% write_three_channel_schedule interface.

if isvector(controls)
    controls = reshape(controls, 1, []);
end
assert(size(controls, 2) == 130, ...
    'evaluate_three_channel_npv:ControlSize', ...
    'The three-channel case expects 130 control variables.');

objective = zeros(size(controls, 1), 1);
for sample = 1:size(controls, 1)
    write_three_channel_schedule( ...
        controls(sample, :), caseDirectory, stepLength);
    runInformation = run_eclipse_case(caseDirectory, 'BASE');
    summary = read_rsm_summary(runInformation.summaryFile, summaryRow);

    fieldOilProduction = summary(3);
    fieldWaterProduction = summary(4);
    fieldWaterInjection = summary(5);
    netPresentValue = fieldOilProduction * 50 - ...
        fieldWaterProduction * 5 - fieldWaterInjection * 0;
    objective(sample) = -netPresentValue;
end
end
