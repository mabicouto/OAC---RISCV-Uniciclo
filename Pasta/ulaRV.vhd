library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ulaRV is
    generic (WSIZE : natural := 32);
    port (
        opcode : in std_logic_vector(3 downto 0);
        A : in std_logic_vector(WSIZE-1 downto 0);
        B : in std_logic_vector(WSIZE-1 downto 0);
        Z : out std_logic_vector(WSIZE-1 downto 0);
        cond : out std_logic
    );
end ulaRV;

architecture Behavioral of ulaRV is
begin
    process (opcode, A, B)
    begin
        case opcode is
            when "0010" => -- ADD
                Z <= std_logic_vector(signed(A) + signed(B));
                cond <= '0';
            when "0110" => -- SUB
                Z <= std_logic_vector(signed(A) - signed(B));
                cond <= '0';
            when "0000" => -- AND
                Z <= A and B;
                cond <= '0';
            when "0001" => -- OR
                Z <= A or B;
                cond <= '0';
            when "0100" => -- XOR
                Z <= A xor B;
                cond <= '0';
            when "0101" => -- SLL (Shift Left Logical)
                Z <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                cond <= '0';
            when "1111" => -- SRL (Shift Right Logical)
                Z <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                cond <= '0';
            when "0111" => -- SRA (Shift Right Arithmetic)
                Z <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
                cond <= '0';
            when "1000" => -- SLT (Set Less Than)
                if signed(A) < signed(B) then
                    Z <= (others => '0'); Z(0) <= '1';
                    cond <= '1';
                else
                    Z <= (others => '0');
                end if;
            when "1001" => -- SLTU (Set Less Than Unsigned)
                if unsigned(A) < unsigned(B) then
                    Z <= (others => '0'); Z(0) <= '1';
                    cond <= '1';
                else
                    Z <= (others => '0');
                end if;
            when "1010" => -- SGE (Set Greater Than or Equal)
                if signed(A) >= signed(B) then
                    Z <= (others => '0'); Z(0) <= '1';
                    cond <= '1';
                else
                    Z <= (others => '0');
                end if;
            when "1011" => -- SGEU (Set Greater Than or Equal Unsigned)
                if unsigned(A) >= unsigned(B) then
                    Z <= (others => '0'); Z(0) <= '1';
                    cond <= '1';
                else
                    Z <= (others => '0');
                end if;
            when "1100" => -- LUI (Load Upper Immediate)
                Z <= B(31 downto 12) & "000000000000";
                cond <= '0';
            when "1101" => -- AUIPC (Add Upper Immediate to PC)
                Z <= std_logic_vector(signed(A) + signed(B(31 downto 12) & "000000000000"));
                cond <= '0';
            when others =>
                Z <= (others => '0');
                cond <= '0';
        end case;
    end process;
end Behavioral;
