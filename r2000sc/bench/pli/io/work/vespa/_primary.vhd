library verilog;
use verilog.vl_types.all;
entity vespa is
    generic(
        WIDTH           : integer := 32;
        NUMREGS         : integer := 32;
        MEMSIZE         : integer := 8192
    );
end vespa;
