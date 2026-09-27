library ieee;
use ieee.std_logic_1164.all;

package ram_pkg is



    -- Constrain both dimensions where the type is used.
    type ram_type is array (natural range <>) of std_logic_vector;

    end package;