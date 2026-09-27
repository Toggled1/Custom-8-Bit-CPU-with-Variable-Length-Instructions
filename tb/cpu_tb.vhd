library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ram_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity CPU_TB is
    generic (
        ADDR_W : positive := 8;
        DATA_W : positive range 8 to integer'high := 8
    );
end entity CPU_TB;

architecture Behavioural of CPU_TB is

    signal CLK : std_logic := '0';
    signal reset : std_logic := '1';
    signal debug_RAM_contents : ram_type(0 to (2**ADDR_W)-1)(DATA_W-1 downto 0);
    signal pc_debug : std_logic_vector(ADDR_W-1 downto 0);
begin

    

    dut : entity work.cpu_frame

    generic map (
        ADDR_W => ADDR_W,
        Data_W => DATA_W
    )

    port map(
        CLK => CLK,

        reset => reset,

        debug_RAM_contents_full => debug_RAM_contents,

        pc_debug => pc_debug
    );




    stim : process

    begin


        while true loop
        CLK <= '0';
        wait for 5 ns;
        CLK <= '1';
        wait for 5 ns;

    end loop;

    end process;


    process


    variable line_var : line;
    variable i : integer := 0;
    file ram_dump_file : text open write_mode is "tb/ram_dump.txt";


    
begin
    reset <= '1';   --NOTE: Verification was done with waveform comparison with programs hardcoded in preloaded RAM
                    --UPDATE: Toolchain preloads the RAM now for execution

    wait for 25 ns;   --guarantees at least two rising edges at 5ns and 15ns

    reset <= '0';     --release reset, CPU starts running

    wait for 5 us; --until times out!
            

    --Writing the Ram contents to a dump file

    while i < 2**ADDR_W loop

        line_var := null;
        write(line_var, i); --so it is in form i: value
        write(line_var, string'(": "));--i hate this string syntax so much
        hwrite(line_var, debug_RAM_contents(i) );
        
        writeline(ram_dump_file, line_var );
        i := i + 1; --increment the counter
    end loop;


    
    assert false report "Simulation finished" severity failure;
  end process;

end architecture;