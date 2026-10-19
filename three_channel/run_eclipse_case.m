function runInformation = run_eclipse_case(caseDirectory, caseName)
%RUN_ECLIPSE_CASE Launch one ECLIPSE case and report the process result.

if nargin < 2 || isempty(caseName)
    caseName = 'BASE';
end
dataFile = fullfile(caseDirectory, [caseName, '.DATA']);
summaryFile = fullfile(caseDirectory, [caseName, '.RSM']);
assert(isfile(dataFile), 'run_eclipse_case:MissingDeck', ...
    'The ECLIPSE deck does not exist: %s', dataFile);

if isfile(summaryFile)
    delete(summaryFile);
end
command = sprintf('eclrun eclipse "%s"', dataFile);
[status, consoleOutput] = system(command);
assert(status == 0, 'run_eclipse_case:SimulatorFailure', ...
    'ECLIPSE returned status %d.\n%s', status, consoleOutput);
assert(isfile(summaryFile), 'run_eclipse_case:MissingSummary', ...
    'ECLIPSE completed without creating %s.', summaryFile);

runInformation = struct('command', command, 'status', status, ...
    'consoleOutput', consoleOutput, 'dataFile', dataFile, ...
    'summaryFile', summaryFile);
end
