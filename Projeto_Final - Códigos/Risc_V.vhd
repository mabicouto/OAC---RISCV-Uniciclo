library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Risc_V is
    generic(WSIZE : natural := 32);  
    port (
        clk : in std_logic;        
        rst : in std_logic;        
        debug_pc : out std_logic_vector(WSIZE-1 downto 0) 
    );
end Risc_V;

architecture main of Risc_V is



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
				clk : in std_logic;        

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
            SignExtend : in  std_logic;  
            datain : in std_logic_vector(31 downto 0);
            dataout : out std_logic_vector(31 downto 0)
        );
    end component;

    component controle is
        port (
            instr : in std_logic_vector(31 downto 0);
            ALUOp : out std_logic_vector(1 downto 0);
            ALUSrc, isCa, Branch, MemRead, MemWrite, RegWrite, Mem2Reg, Byte_en, SignExtend, JAL : out std_logic
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
    signal zero, ALUSrc, Branch, MemRead, MemWrite, RegWrite, Mem2Reg, isCa, Byte_en, SignExtend, JAL : std_logic;
    signal ula_command : std_logic_vector(3 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal xreg_out1, xreg_out2, xreg_in, ula_in1, ula_in2, ula_out : std_logic_vector(WSIZE-1 downto 0);
    signal instr, mem_out, pc, next_pc, memula, pc_plus_4, branch_target, jalr_target,salto : std_logic_vector(WSIZE-1 downto 0);
    signal ALUOp : std_logic_vector(1 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic;
    signal imm_value : signed(31 downto 0);  
    signal imm_value_vector : std_logic_vector(WSIZE-1 downto 0); 
    signal branch_condition,jalr_condition : std_logic; 

begin

    -- Instanciação dos módulos

    xreg_insta: Xreg port map(
        wren => RegWrite,
		  clk =>clk,
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
        Byte_en => Byte_en,
        JAL => JAL
    );

    ula_ctrl: aluctr port map(
        ALUOp => ALUOp,
        funct7 => funct7,
        funct3 => funct3,
        opOut => ula_command
    );

    imm_value_vector <= std_logic_vector(imm_value);

    branch_target <= std_logic_vector(signed(pc) + imm_value);

    jalr_target <= std_logic_vector(signed(xreg_out1) + imm_value);

    branch_condition <= Branch and (JAL or zero);
	 jalr_condition <= JAL and not(instr(3));

    -- Multiplexador para selecionar a entrada B da ULA
    Mux_ula: Mux port map(
        a => xreg_out2,
        b => imm_value_vector,  
        ctrl => ALUSrc,
        z => ula_in2
    );

    -- Multiplexador para selecionar o dado de write-back
    Mux_mem: Mux port map(
        a => ula_out,
        b => mem_out,
        ctrl => Mem2Reg,
        z => memula
    );
	 
    Mux_auipc: Mux port map(
        a => xreg_out1,
        b => pc,
        ctrl => isCa,
        z => ula_in1
    );
	 
	 
    -- Multiplexador para selecionar entre memula e PC + 4 (para JAL/JALR)
    Mux_memula: Mux port map(
        a => memula,
        b => pc_plus_4,
        ctrl => JAL,
        z => xreg_in
    );

    -- Multiplexador para selecionar o próximo PC
    Mux_pc: Mux port map(
        a => pc_plus_4,
        b => salto,  -- Endereço de branch
        ctrl => branch_condition,  
        z => next_pc
    );

    -- Multiplexador adicional para JALR
    Mux_jalr: Mux port map(
        a => branch_target,
        b => jalr_target,  -- Endereço de JALR
        ctrl => jalr_condition,
        z => salto
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
            pc <= (others => '0');  
        elsif rising_edge(clk) then
            pc <= next_pc;
        end if;
    end process;

    pc_plus_4 <= std_logic_vector(unsigned(pc) + 4);

    funct3 <= instr(14 downto 12);
    funct7 <= instr(30);

    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    rd <= instr(11 downto 7);

    debug_pc <= pc;

end main;