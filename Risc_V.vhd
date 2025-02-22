library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Risc_V is
    generic(WSIZE : natural := 32);  -- Tamanho da palavra (32 bits)
end Risc_V;

architecture main of Risc_V is

    -- Declaração dos módulos

    component ULA_RiscV is
        port(
            opcode: in std_logic_vector(3 downto 0);
            A, B : in std_logic_vector(WSIZE -1 downto 0);
            Z : out std_logic_vector(WSIZE -1 downto 0);
            zero : out std_logic
        );
    end component;

    component XREGS is
        port(
            clk, wren, rst : in std_logic;
            rs1, rs2, rd : in std_logic_vector(4 downto 0);
            data : in std_logic_vector(WSIZE-1 downto 0);
            ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    component imm32 is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

    component Code_Mem_RV is
        port (
            clk : in std_logic;
            addr : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component Data_Mem_RV is
        port (
            clk : in std_logic;
            we : in std_logic;
            addr : in std_logic_vector(31 downto 0);
            data_in : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component Control is
        port (
            instr : in std_logic_vector(31 downto 0);
            ALUOp : out std_logic_vector(1 downto 0);
            ALUSrc, Branch, MemRead, MemWrite, RegWrite, Mem2Reg : out std_logic
        );
    end component;

    component Control_ALU is
        port (
            ALUOp : in std_logic_vector(1 downto 0);
            funct7 : in std_logic;
            funct3 : in std_logic_vector(2 downto 0);
            opOut : out std_logic_vector(3 downto 0)
        );
    end component;

    component mux is
        port (
            a, b : in std_logic_vector(WSIZE-1 downto 0);
            ctrl : in std_logic;
            z : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    -- Sinais
    signal clk, rst, zero, ALUSrc, Branch, MemRead, MemWrite, RegWrite, Mem2Reg : std_logic;
    signal ula_command : std_logic_vector(3 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal xreg_out1, xreg_out2, xreg_in, ula_in1, ula_in2, ula_out, imm_value : std_logic_vector(WSIZE-1 downto 0);
    signal instr, mem_out, mem_in, pc, next_pc, pc_plus_4, branch_target : std_logic_vector(WSIZE-1 downto 0);
    signal ALUOp : std_logic_vector(1 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic;

begin

    -- Instanciação dos módulos

    xreg: XREGS port map(
        clk => clk,
        wren => RegWrite,
        rs1 => rs1,
        rs2 => rs2,
        rd => rd,
        data => xreg_in,
        ro1 => xreg_out1,
        ro2 => xreg_out2
    );

    ula: ULA_RiscV port map(
        opcode => ula_command,
        A => ula_in1,
        B => ula_in2,
        Z => ula_out,
        zero => zero
    );

    imm: imm32 port map(
        instr => instr,
        imm32 => signed(imm_value)
    );

    code_mem: Code_Mem_RV port map(
        clk => clk,
        addr => pc,
        data_out => instr
    );

    data_mem: Data_Mem_RV port map(
        clk => clk,
        we => MemWrite,
		  mr => MemRead
        addr => ula_out,
        data_in => xreg_out2,
        data_out => mem_out
    );

    ctrl: Control port map(
        instr => instr,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        MemRead => MemRead,
        MemWrite => MemWrite,
        RegWrite => RegWrite,
        Mem2Reg => Mem2Reg
		  isCa => isCa
    );

    ula_ctrl: Control_ALU port map(
        ALUOp => ALUOp,
        funct7 => funct7,
        funct3 => funct3,
        opOut => ula_command
    );

    mux_ula: mux port map(
        a => xreg_out2,
        b => imm_value,
        ctrl => ALUSrc,
        z => ula_in2
    );

    mux_mem: mux port map(
        a => ula_out,
        b => mem_out,
        ctrl => Mem2Reg,
        z => xreg_in
    );

    mux_pc: mux port map(
        a => pc_plus_4,
        b => branch_target,
        ctrl => Branch and zero,
        z => next_pc
    );

    -- Lógica do PC
    process(clk)
    begin
        if rising_edge(clk) then
            pc <= next_pc;
        end if;
    end process;

    -- Cálculo de PC + 4
    pc_plus_4 <= std_logic_vector(unsigned(pc) + 4;

    -- Cálculo do endereço de branch
    branch_target <= std_logic_vector(unsigned(pc) + unsigned(imm_value);

    -- Decodificação de funct3 e funct7
    funct3 <= instr(14 downto 12);
    funct7 <= instr(30);

    -- Decodificação de rs1, rs2 e rd
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    rd <= instr(11 downto 7);

    -- Entrada A da ULA
    ula_in1 <= xreg_out1;

end main;
