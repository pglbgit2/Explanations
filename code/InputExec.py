import subprocess
def inputExec(inputFile=None, execFile=None):
    if inputFile == None:
        inputFile = input("Enter input file")
    if execFile == None:
        execFile = input("Enter executable location")
    command = execFile+" < "+inputFile
    try:
        result = subprocess.check_output(command, shell = True, executable = "/bin/bash", stderr = subprocess.STDOUT)

    except subprocess.CalledProcessError as cpe:
        result = cpe.output

    finally:
        for line in result.splitlines():
            print(line.decode())
    return result
        
        
