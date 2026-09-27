library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  generic (
    DATA_W : positive := 8
  );
  port(
    op_A       : in  std_logic_vector(DATA_W-1 downto 0);
    op_B       : in  std_logic_vector(DATA_W-1 downto 0);
    ALU_op     : in  std_logic_vector(3 downto 0);

    ALU_result : out std_logic_vector(DATA_W-1 downto 0);

    Z : out std_logic;  -- Zero
    C : out std_logic;  -- Carry
    N : out std_logic;  -- Negative
    V : out std_logic   -- Overflow
  );

end entity alu;





architecture Behaviour of alu is

begin

  process(all)



    -- internal arithmetic values for computation
    variable extended_sum    : unsigned(DATA_W downto 0);
    variable result_u        : unsigned(DATA_W-1 downto 0); --unsigned result


    -- signed views (using these signals for overflow detection)
    variable a_signed        : signed(DATA_W-1 downto 0); --op_A signed view
    variable b_signed        : signed(DATA_W-1 downto 0); --op_B signed view
    variable result_signed   : signed(DATA_W-1 downto 0); --result after op signed view


    -- flag temporaries
    variable zero_flag       : std_logic; --Z
    variable carry_flag      : std_logic; --C
    variable negative_flag   : std_logic; --N
    variable overflow_flag   : std_logic; --V




  begin

    result_u := (others => '0');
    extended_sum := (others => '0');
    zero_flag := '0';
    carry_flag := '0';
    negative_flag := '0';
    overflow_flag := '0';


    a_signed := signed(op_A);
    b_signed := signed(op_B);


    --case for the ops that require ALU (MOVE uses passthrough but load and store don't)
    case ALU_op is


      --MOVE (passthrough)

      when "0011" =>
        result_u := unsigned(op_B); --just copy value B

      -- OR
      when "0111" =>
        result_u := unsigned(op_A or op_B);

      -- XOR
      when "1000" =>
        result_u := unsigned(op_A xor op_B);

      -- AND
      when "1001" =>
        result_u := unsigned(op_A and op_B);

      -- NOT
      when "1010" =>
        result_u := unsigned(not op_A);

      -- ADD
      when "1011" =>
        extended_sum := unsigned('0' & op_A) + unsigned('0' & op_B);
        result_u     := extended_sum(DATA_W-1 downto 0); --the output of ALU gets this value!!!
        carry_flag   := extended_sum(DATA_W);

        result_signed := signed(std_logic_vector(result_u));

        --flag calculations
          if (a_signed(DATA_W-1) = b_signed(DATA_W-1)) and --equal
            (result_signed(DATA_W-1) /= a_signed(DATA_W-1)) then --not equal !=
          overflow_flag := '1'; --overflow happens when both operands are both positive or both negative, and the result is opposite sign
        end if;

      -- SUB
      when "1100" =>
        extended_sum := unsigned('0' & op_A) - unsigned('0' & op_B);
        result_u     := extended_sum(DATA_W-1 downto 0);

        --C flag 
        carry_flag   := extended_sum(DATA_W);

        result_signed := signed(std_logic_vector(result_u));

        --V flag
          if (a_signed(DATA_W-1) /= b_signed(DATA_W-1)) and
            (result_signed(DATA_W-1) /= a_signed(DATA_W-1)) then
          overflow_flag := '1';
        end if;

      -- INC
      when "1101" =>
        extended_sum := unsigned('0' & op_A) + 1;
        result_u     := extended_sum(DATA_W-1 downto 0);

        --C flag
        carry_flag   := extended_sum(DATA_W);

        --V flag
        result_signed := signed(std_logic_vector(result_u));
        if (a_signed(DATA_W-1) = '0') and (result_signed(DATA_W-1) = '1') then
          overflow_flag := '1';
        end if;

      -- DEC
      when "1110" =>
        extended_sum := unsigned('0' & op_A) - 1;
        result_u     := extended_sum(DATA_W-1 downto 0);
        carry_flag   := extended_sum(DATA_W); --C flag

        result_signed := signed(std_logic_vector(result_u));

        --V flag
        if (a_signed(DATA_W-1) = '1') and (result_signed(DATA_W-1) = '0') then
          overflow_flag := '1';
        end if;

      -- non-ALU opcodes
      when others =>
        result_u      := (others => '0'); --Just placholder 0, ALU is not router here anyway for reg wb
        carry_flag    := '0';
        overflow_flag := '0';
        zero_flag := '0';
        negative_flag := '0';
        
    end case;

    -- common flags
    if result_u = 0 then
      zero_flag := '1';
    end if;

    negative_flag := result_u(DATA_W-1);

    -- drive outputs
    ALU_result <= std_logic_vector(result_u);
    Z <= zero_flag;
    C <= carry_flag;
    N <= negative_flag;
    V <= overflow_flag;

  end process;

end architecture Behaviour;
