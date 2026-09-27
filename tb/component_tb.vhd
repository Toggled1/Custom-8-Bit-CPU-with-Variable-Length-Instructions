library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity alu_tb is
end entity alu_tb;

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

architecture test of alu_tb is
    signal op_A       : std_logic_vector(7 downto 0) := (others => '0');
    signal op_B       : std_logic_vector(7 downto 0) := (others => '0');
    signal ALU_op     : std_logic_vector(3 downto 0) := (others => '0');
    signal ALU_result : std_logic_vector(7 downto 0);
    signal Z, C, N, V : std_logic;
begin
    dut : entity work.ALU
        port map (
            op_A => op_A, op_B => op_B, ALU_op => ALU_op,
            ALU_result => ALU_result, Z => Z, C => C, N => N, V => V
        );





    stimulus : process
    begin
        -- Signed overflow: 127 + 1 = -128 in 8-bit two's complement.
        op_A <= x"7F";
        op_B <= x"01";
        ALU_op <= "1011";
        wait for 1 ns;
        assert ALU_result = x"80" and Z = '0' and C = '0' and N = '1' and V = '1'
            report "ALU ADD overflow test failed" severity failure;

        -- Unsigned carry and zero result.
        op_A <= x"FF";
        op_B <= x"01";
        wait for 1 ns;
        assert ALU_result = x"00" and Z = '1' and C = '1' and N = '0' and V = '0'
            report "ALU ADD carry test failed" severity failure;



        -- MOVE passes operand B through.
        op_A <= x"A5";
        op_B <= x"3C";
        ALU_op <= "0011";
        wait for 1 ns;
        assert ALU_result = x"3C" and Z = '0' and N = '0'
            report "ALU MOVE test failed" severity failure;

        report "alu_tb passed" severity note;
        finish;
        wait;
    end process;
end architecture test;











library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity dreg_tb is
end entity dreg_tb;

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;



architecture test of dreg_tb is
    signal CLK    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal enable : std_logic := '0';
    signal D      : std_logic_vector(7 downto 0) := (others => '0');
    signal Q      : std_logic_vector(7 downto 0);

begin
    CLK <= not CLK after 5 ns;

    dut : entity work.Dreg
        port map (D => D, Q => Q, enable => enable, reset => reset, CLK => CLK);

    stimulus : process
    begin
        reset <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert Q = x"00" report "Dreg synchronous reset test failed" severity failure;

        reset <= '0';
        enable <= '1';
        D <= x"5A";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert Q = x"5A" report "Dreg enabled write test failed" severity failure;

        enable <= '0';
        D <= x"A5";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert Q = x"5A" report "Dreg hold-when-disabled test failed" severity failure;

        report "dreg_tb passed" severity note;
        finish;
        wait;

    end process;

end architecture test;













library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity regfile_tb is
end entity regfile_tb;

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

architecture test of regfile_tb is
    signal CLK          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal write_enable : std_logic := '0';
    signal write_select : std_logic_vector(2 downto 0) := (others => '0');
    signal read_select  : std_logic_vector(2 downto 0) := (others => '0');
    signal din          : std_logic_vector(7 downto 0) := (others => '0');
    signal dout         : std_logic_vector(7 downto 0);
begin
    CLK <= not CLK after 5 ns;

    dut : entity work.Dregx8
        port map (
            din => din, dout => dout, CLK => CLK, reset => reset,
            write_enable => write_enable,
            write_select => write_select, read_select => read_select
        );

    stimulus : process
    begin
        reset <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        reset <= '0';

        write_enable <= '1';
        write_select <= "010";
        din <= x"A5";
        wait until rising_edge(CLK);
        wait for 1 ns;
        write_enable <= '0';
        read_select <= "010";
        wait for 1 ns;
        assert dout = x"A5" report "Register-bank readback for register 2 failed" severity failure;

        write_enable <= '1';
        write_select <= "101";
        din <= x"3C";

        wait until rising_edge(CLK);
        wait for 1 ns;
        write_enable <= '0';
        read_select <= "101";
        wait for 1 ns;
        assert dout = x"3C" report "Register-bank readback for register 5 failed" severity failure;

        read_select <= "010";
        wait for 1 ns;
        assert dout = x"A5" report "Register-bank register isolation test failed" severity failure;

        report "regfile_tb passed" severity note;
        finish;
        wait;

    end process;

end architecture test;











library ieee;
use ieee.std_logic_1164.all;
use work.ram_pkg.all;
use std.env.all;

entity ram_tb is
end entity ram_tb;

library ieee;
use ieee.std_logic_1164.all;
use work.ram_pkg.all;
use std.env.all;

architecture test of ram_tb is
    signal CLK          : std_logic := '0';
    signal enable       : std_logic := '0';
    signal w_enable     : std_logic := '0';
    signal address_bus  : std_logic_vector(1 downto 0) := (others => '0');
    signal data_in      : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out     : std_logic_vector(7 downto 0);
    signal debug_memory : ram_type(0 to 3)(7 downto 0);

begin
    CLK <= not CLK after 5 ns;

    dut : entity work.ram_block
        generic map (address_bits => 2, ram_word_width => 8)
        port map (
            CLK => CLK, enable => enable, w_enable => w_enable,
            address_bus => address_bus, data_in => data_in,
            data_out => data_out, debug_RAM_contents => debug_memory
        );

    stimulus : process
    begin
        -- Write address 1, then read it on a later enabled cycle.
        enable <= '1';
        w_enable <= '1';
        address_bus <= "01";
        data_in <= x"5A";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert debug_memory(1) = x"5A" report "RAM write test failed" severity failure;

        w_enable <= '0';
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert data_out = x"5A" report "RAM synchronous read test failed" severity failure;

        -- With enable low, the registered output should hold its value.
        enable <= '0';
        address_bus <= "10";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert data_out = x"5A" report "RAM output hold test failed" severity failure;

        report "ram_tb passed" severity note;
        finish;
        wait;
    end process;

end architecture test;









library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity datapath_tb is
end entity datapath_tb;

library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

architecture test of datapath_tb is
    signal mem_din      : std_logic_vector(7 downto 0) := (others => '0');
    signal mem_dout     : std_logic_vector(7 downto 0);
    signal CLK          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal reg_we       : std_logic := '0';
    signal reg_read_sel : std_logic_vector(2 downto 0) := (others => '0');
    signal reg_write_sel: std_logic_vector(2 downto 0) := (others => '0');
    signal pc_we        : std_logic := '0';
    signal pc_src_sel   : std_logic := '0';
    signal pc_target    : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_out       : std_logic_vector(7 downto 0);
    signal ir_we        : std_logic := '0';
    signal ir_out       : std_logic_vector(7 downto 0);
    signal ir1_we       : std_logic := '0';
    signal ir1_out      : std_logic_vector(7 downto 0);
    signal alu_result   : std_logic_vector(7 downto 0) := (others => '0');
    signal imm8         : std_logic_vector(7 downto 0) := (others => '0');
    signal wb_sel       : std_logic_vector(1 downto 0) := (others => '0');
    signal sr_in        : std_logic_vector(7 downto 0) := (others => '0');
    signal sr_out       : std_logic_vector(7 downto 0);
    signal sr_we        : std_logic := '0';

begin
    CLK <= not CLK after 5 ns;

    dut : entity work.datapath
        port map (
            mem_din => mem_din, mem_dout => mem_dout, CLK => CLK, reset => reset,
            reg_we => reg_we, reg_read_sel => reg_read_sel,
            reg_write_sel => reg_write_sel,
            pc_we => pc_we, pc_src_sel => pc_src_sel,
            pc_target => pc_target, pc_out => pc_out,
            ir_we => ir_we, ir_out => ir_out,
            ir1_we => ir1_we, ir1_out => ir1_out,
            alu_result => alu_result, imm8 => imm8, wb_sel => wb_sel,
            sr_in => sr_in, sr_out => sr_out, sr_we => sr_we
        );

    stimulus : process
    begin
        reset <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert pc_out = x"00" report "Datapath PC reset test failed" severity failure;

        reset <= '0';
        pc_we <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert pc_out = x"01" report "Datapath PC increment test failed" severity failure;

        pc_src_sel <= '1';
        pc_target <= x"20";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert pc_out = x"20" report "Datapath PC branch-target test failed" severity failure;
        pc_we <= '0';
        pc_src_sel <= '0';

        mem_din <= x"C3";
        ir_we <= '1';
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert ir_out = x"C3" report "Datapath instruction-register test failed" severity failure;
        ir_we <= '0';

        reg_we <= '1';
        reg_write_sel <= "010";
        reg_read_sel <= "010";
        wb_sel <= "00";
        alu_result <= x"A6";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert mem_dout = x"A6" report "Datapath ALU writeback/register read test failed" severity failure;
        reg_we <= '0';

        sr_we <= '1';
        sr_in <= x"B0";
        wait until rising_edge(CLK);
        wait for 1 ns;
        assert sr_out = x"B0" report "Datapath status-register test failed" severity failure;

        report "datapath_tb passed" severity note;
        finish;
        wait;
    end process;

end architecture test;

