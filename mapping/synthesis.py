import fileinput

with fileinput.FileInput('build/NeuromorphicProcessor.v', inplace=True, backup='.bak') as f:
    for line in f:
        print(line.replace('`ifndef SYNTHESIS', ''), end='')

with fileinput.FileInput('build/NeuromorphicProcessor.v', inplace=True, backup='.bak') as f:
    for line in f:
        print(line.replace('`endif // SYNTHESIS', ''), end='')
