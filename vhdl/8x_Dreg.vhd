library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Dregx8 is
    generic (
        DATA_W : positive := 8
    );
    port(
        din          : in  std_logic_vector(DATA_W-1 downto 0);
        dout         : out std_logic_vector(DATA_W-1 downto 0);
        CLK          : in  std_logic;
        reset        : in  std_logic;
        write_enable : in  std_logic;
        write_select : in  std_logic_vector(2 downto 0);
        read_select  : in  std_logic_vector(2 downto 0)
    );
end entity Dregx8;

architecture structural of Dregx8 is
    type register_array_t is array (0 to 7) of std_logic_vector(DATA_W-1 downto 0);
    signal registers : register_array_t;
    signal reg_en    : std_logic_vector(7 downto 0);
begin
    registers_gen : for i in 0 to 7 generate
        reg_en(i) <= write_enable when
            write_select = std_logic_vector(to_unsigned(i, write_select'length)) else '0';

        reg_i : entity work.Dreg
            generic map (
                cells => DATA_W
            )
            port map (
                D => din,
                Q => registers(i),
                enable => reg_en(i),
                reset => reset,
                CLK => CLK
            );
    end generate;

    process(all)
    begin
        case read_select is
            when "000" => dout <= registers(0);
            when "001" => dout <= registers(1);
            when "010" => dout <= registers(2);
            when "011" => dout <= registers(3);
            when "100" => dout <= registers(4);
            when "101" => dout <= registers(5);
            when "110" => dout <= registers(6);
            when others => dout <= registers(7);
        end case;
    end process;
end architecture structural;
