library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Risc_V is
    generic(WSIZE : natural := 32);  -- Tamanho da palavra (32 bits)
    port (
        clk : in std_logic;          -- Sinal de clock
        rst : in std_logic;          -- Sinal de reset
        debug_pc : out std_logic_vector(WSIZE-1 downto 0)  -- Saída de depuração para o PC
    );
end Risc_V;

architecture main of Risc_V is

    -- Declaração dos módulos

    component ulaRV is
        port(
            opcode: in std_logic_vector(3 downto 0);
            A, B : in std_logic_vector(WSIZE -1 downto 0);
            Z : out std_logic_vector(WSIZE -1 downto 0);
            cond : out std_logic
        );
    end component;

    component Xreg is
        port(
            wren : in std_logic;
            rs1, rs2, rd : in std_logic_vector(4 downto 0);
            data : in std_logic_vector(WSIZE-1 downto 0);
            ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    component GeImm is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

    component Code_mem is
        port (
            addr : in std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component data_mem is
        port (
            we : in std_logic;
            addr : in std_logic_vector(13 downto 0);
            Byte_en  : in  std_logic;
            SignExtend : in  std_logic;  -- Extensão de sinal para leitura de byte
            datain : in std_logic_vector(31 downto 0);
            dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    component controle is
        port (
            instr : in std_logic_vector(31 downto 0);
            ALUOp : out std_logic_vector(1 downto 0);
            ALUSrc, isCa, Branch, MemRead, MemWrite, RegWrite, Mem2Reg, Byte_en, SignExtend : out std_logic
        );
    end component;

    component aluctr is
        port (
            ALUOp : in std_logic_vector(1 downto 0);
            funct7 : in std_logic;
            funct3 : in std_logic_vector(2 downto 0);
            opOut : out std_logic_vector(3 downto 0)
        );
    end component;

    component Mux is
        port (
            a, b : in std_logic_vector(WSIZE-1 downto 0);
            ctrl : in std_logic;
            z : out std_logic_vector(WSIZE-1 downto 0)
        );
    end component;

    -- Sinais
    signal zero, ALUSrc, Branch, MemRead, MemWrite, RegWrite, Mem2Reg, isCa, Byte_en, SignExtend : std_logic;
    signal ula_command : std_logic_vector(3 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal xreg_out1, xreg_out2, xreg_in, ula_in1, ula_in2, ula_out : std_logic_vector(WSIZE-1 downto 0);
    signal instr, mem_out, pc, next_pc, pc_plus_4 : std_logic_vector(WSIZE-1 downto 0);
    signal ALUOp : std_logic_vector(1 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic;
    signal imm_value : signed(31 downto 0);  -- Sinal para o valor imediato gerado pelo GeImm
    signal imm_value_vector, branch_jump : std_logic_vector(WSIZE-1 downto 0);  -- Sinal para armazenar imm_value convertido
    signal branch_condition : std_logic;  -- Sinal para armazenar Branch and zero

begin

    -- Instanciação dos módulos

    xreg_insta: Xreg port map(
        wren => RegWrite,
        rs1 => instr(19 downto 15),
        rs2 => instr(24 downto 20),
        rd => instr(11 downto 7),
        data => xreg_in,
        ro1 => xreg_out1,
        ro2 => xreg_out2
    );

    ula: ulaRV port map(
        opcode => ula_command,
        A => ula_in1,
        B => ula_in2,
        Z => ula_out,
        cond => zero
    );

    imm: GeImm port map(
        instr => instr,
        imm32 => imm_value
    );

    ctrl: controle port map(
        instr => instr,
        ALUOp => ALUOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        MemRead => MemRead,
        MemWrite => MemWrite,
        RegWrite => RegWrite,
        Mem2Reg => Mem2Reg,
        isCa => isCa,
        SignExtend => SignExtend,
        Byte_en => Byte_en
    );

    ula_ctrl: aluctr port map(
        ALUOp => ALUOp,
        funct7 => funct7,
        funct3 => funct3,
        opOut => ula_command
    );

    -- Conversão de imm_value para std_logic_vector
    imm_value_vector <= std_logic_vector(imm_value);

    -- Cálculo da condição de branch
    branch_condition <= Branch and zero;
	 
	 branch_jump <= std_logic_vector(signed(pc) + imm_value);

    Mux_ula: Mux port map(
        a => xreg_out2,
        b => imm_value_vector,  -- Usa o sinal convertido
        ctrl => ALUSrc,
        z => ula_in2
    );

    Mux_mem: Mux port map(
        a => ula_out,
        b => mem_out,
        ctrl => Mem2Reg,
        z => xreg_in
    );

    Mux_pc: Mux port map(
        a => pc_plus_4,
        b => branch_jump,  -- Converte signed para std_logic_vector
        ctrl => branch_condition,  -- Usa o sinal calculado
        z => next_pc
    );

    code_mem_inst: Code_mem port map(
        addr => pc,
        data_out => instr
    );

    data_mem_inst: data_mem port map(
        we => MemWrite,
        Byte_en => Byte_en,
        SignExtend => SignExtend,
        addr => ula_out(13 downto 0),
        datain => xreg_out2,
        dataout => mem_out
    );

    -- Lógica do PC
    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');  -- Reset do PC para 0
        elsif rising_edge(clk) then
            pc <= next_pc;
        end if;
    end process;

    -- Cálculo de PC + 4
    pc_plus_4 <= std_logic_vector(unsigned(pc) + 4);

    -- Decodificação de funct3 e funct7
    funct3 <= instr(14 downto 12);
    funct7 <= instr(30);

    -- Decodificação de rs1, rs2 e rd
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    rd <= instr(11 downto 7);

    -- Entrada A da ULA
    ula_in1 <= xreg_out1;

    -- Saída de depuração para o PC
    debug_pc <= pc;

end main;