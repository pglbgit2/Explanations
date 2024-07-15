
        
def fileMerger(files=None, outputName=None):
    if files is None:
        files = input("Enter input files paths: ")
    files = files.split(" ")
    if outputName is None:
        outputName = input("Enter output file path: ")
    
    buf = bytearray()
    for file in files:
        with open(file, "rb") as fileSock:
            buf.extend(fileSock.read()+b'\n')
    
    with open(outputName, "wb") as outputFile:
        outputFile.write(buf)
