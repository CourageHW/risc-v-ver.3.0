import core_pkg::*;
interface inst_if;

  logic [INST_MEM_ADDR_WIDTH-1:0] addr_i;
  logic [INST_WIDTH-1:0] instruction_o;

  modport SLAVE (
    input addr_i,
    output instruction_o
  );

  modport MASTER (
    input instruction_o,
    output addr_i
  );
endinterface
