// `timescale 1ns / 1ps
 
 
/////////////////////////Transaction
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class transaction extends uvm_sequence_item;
  rand bit [3:0] a2;
  rand bit [3:0] b2;
  bit [4:0] out;
 
function new(input string inst = "TRANS");
super.new(inst);
endfunction
 
`uvm_object_utils_begin(transaction)
  `uvm_field_int(a2, UVM_DEFAULT)
  `uvm_field_int(b2, UVM_DEFAULT)
  `uvm_field_int(out, UVM_DEFAULT)
`uvm_object_utils_end
 
endclass
 
//////////////////////////////////////////////////////////////
class generator extends uvm_sequence #(transaction);
`uvm_object_utils(generator)
 
transaction t;
integer i;
 
function new(input string inst = "GEN");
super.new(inst);
endfunction
 
 
virtual task body();
t = transaction::type_id::create("TRANS");
for(i =0; i< 10; i++) begin
start_item(t);
t.randomize();
  `uvm_info("GEN",$sformatf("Data send to Driver a2 :%0d , b2 :%0d",t.a2,t.b2), UVM_NONE);
t.print(uvm_default_line_printer);
finish_item(t);
#10;  
end
endtask
 
endclass
 
////////////////////////////////////////////////////////////////////
class driver extends uvm_driver #(transaction);
`uvm_component_utils(driver)
 
function new(input string inst = " DRV", uvm_component c);
super.new(inst, c);
endfunction
 
transaction data;
virtual add_if aif;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
data = transaction::type_id::create("TRANS");
if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif)) 
`uvm_info("DRV","Unable to access uvm_config_db",UVM_NONE);
endfunction
 
virtual task run_phase(uvm_phase phase);
forever begin
seq_item_port.get_next_item(data);
aif.a2 = data.a2;
aif.b2 = data.b2;
  `uvm_info("DRV", $sformatf("Trigger DUT a2: %0d ,b2 :  %0d",data.a2, data.b2), UVM_NONE);
data.print(uvm_default_line_printer);
seq_item_port.item_done();
end
endtask
endclass
 
////////////////////////////////////////////////////////////////////////
class monitor extends uvm_monitor;
`uvm_component_utils(monitor)
 
uvm_analysis_port #(transaction) send;
 

 
transaction t;
virtual add_if aif;
  
   ///////////adding coverage
  
  ///a2 b2
  
  covergroup cg ;
    option.per_instance = 1;
    
    cov_p1: coverpoint t.a2;
    cov_p2: coverpoint t.b2;
endgroup:cg
  
function new(input string inst = "MON", uvm_component c);
super.new(inst, c);
send = new("Write", this);
 cg = new();
endfunction
  
  
  
  
  
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
t = transaction::type_id::create("TRANS");
if(!uvm_config_db #(virtual add_if)::get(this,"","aif",aif)) 
`uvm_info("MON","Unable to access uvm_config_db",UVM_NONE);
endfunction
 
virtual task run_phase(uvm_phase phase);
forever begin
#10;
t.a2 = aif.a2;
t.b2 = aif.b2;
t.out = aif.out;
cg.sample();
  `uvm_info("MON", $sformatf("Data send to Scoreboard a2 : %0d , b2 : %0d and out : %0d", t.a2,t.b2,t.out), UVM_NONE);
t.print(uvm_default_line_printer);
send.write(t);
end
endtask
endclass
 
///////////////////////////////////////////////////////////////////////
class scoreboard extends uvm_scoreboard;
`uvm_component_utils(scoreboard)
 
uvm_analysis_imp #(transaction,scoreboard) recv;
 
transaction data;
 
function new(input string inst = "SCO", uvm_component c);
super.new(inst, c);
recv = new("Read", this);
endfunction
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
data = transaction::type_id::create("TRANS");
endfunction
 
virtual function void write(input transaction t);
data = t;
  `uvm_info("SCO",$sformatf("Data rcvd from Monitor a2: %0d , b2 : %0d and out : %0d",t.a2,t.b2,t.out), UVM_NONE);
data.print(uvm_default_line_printer);
  if(data.out == data.a2 * data.b2)
`uvm_info("SCO","Test Passed", UVM_NONE)
else
`uvm_info("SCO","Test Failed", UVM_NONE);
endfunction
endclass
////////////////////////////////////////////////
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
 
function new(input string inst = "AGENT", uvm_component c);
super.new(inst, c);
endfunction
 
monitor m;
driver d;
uvm_sequencer #(transaction) seq;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
m = monitor::type_id::create("MON",this);
d = driver::type_id::create("DRV",this);
seq = uvm_sequencer #(transaction)::type_id::create("SEQ",this);
endfunction
 
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
d.seq_item_port.connect(seq.seq_item_export);
endfunction
endclass
 
/////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
 
function new(input string inst = "ENV", uvm_component c);
super.new(inst, c);
endfunction
 
scoreboard s;
agent a;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
s = scoreboard::type_id::create("SCO",this);
a = agent::type_id::create("AGENT",this);
endfunction
 
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.m.send.connect(s.recv);
endfunction
 
endclass
 
////////////////////////////////////////////
 
class test extends uvm_test;
`uvm_component_utils(test)
 
 
function new(input string inst = "TEST", uvm_component c);
super.new(inst, c);
endfunction
 
generator gen;
env e;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
gen = generator::type_id::create("GEN",this);
e = env::type_id::create("ENV",this);
endfunction
 
virtual task run_phase(uvm_phase phase);
phase.raise_objection(phase);
gen.start(e.a.seq);
#10;
phase.drop_objection(phase);

endtask
endclass
//////////////////////////////////////
 
module add_tb();
test te;
add_if aif();
 
  nikhilum dut (.a2(aif.a2), .b2(aif.b2), .out(aif.out));
 
initial begin
 
$dumpfile("dump.vcd");
$dumpvars;  
te = new("TEST",null);
uvm_config_db #(virtual add_if)::set(null, "*", "aif", aif);
run_test();
end
 
endmodule
