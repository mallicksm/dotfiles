import lauterbach.trace32.rcl as t32
dbg = t32.connect(node='10.1.12.138', port=20000, protocol="UDP", packlen=1024, timeout=10.0)
addr = dbg.address.from_string('D:0x11010280')
value = 0xc001c0de
dbg.memory.write_uint32(address=addr, value=value)
print(hex(dbg.memory.read_uint32(address=addr)))

