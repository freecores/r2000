library verilog;
use verilog.vl_types.all;
entity watch_variable is
    generic(
        LEFT_BIT        : integer := 7;
        RIGHT_BIT       : integer := 0;
        FIRST_ADDR      : integer := 0;
        LAST_ADDR       : integer := 1023
    );
end watch_variable;
