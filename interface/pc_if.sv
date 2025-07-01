import core_pkg::*;
interface pc_if;
  
  logic [DATA_WIDTH-1:0] pc_i;
  logic [DATA_WIDTH-1:0] pc_o;
  logic pc_we;

  modport SLAVE (
    input pc_i,
    input pc_we,
    output pc_o
  );

  modport MASTER (
    output pc_i,
    input pc_o
  );
endinterface
