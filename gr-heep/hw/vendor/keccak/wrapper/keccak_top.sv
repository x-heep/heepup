//
// keccak_top: keccak accelerator top-level. 
// Designed by Mattia Mirigaldi
// mattia.mirigaldi@polito.it
//

module keccak_top 
  import keccak_reg_pkg::*;
  import xheep_reg_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,
	input  xheep_reg_req_t reg_req_i,
    output xheep_reg_rsp_t reg_rsp_o,
	output logic keccak_intr_o
);

   xheep_reg_req_t periph_req_i;   
   xheep_reg_rsp_t periph_rsp_o;
   
   keccak_reg2hw_t reg_file_to_ip;
   keccak_hw2reg_t ip_to_reg_file;


   keccak_reg_top #(
	.reg_req_t(xheep_reg_req_t),
	.reg_rsp_t(xheep_reg_rsp_t)
	) i_data_regfile (
		.clk_i,
		.rst_ni,
		.devmode_i(1'b1),
		// From the bus to regfile
		.reg_req_i(reg_req_i),
		.reg_rsp_o(reg_rsp_o),
		
		// Signals from regfile to keccak IP
		.reg2hw(reg_file_to_ip),
		.hw2reg(ip_to_reg_file) 
	);


     
// wiring signals between control unit and ip
logic[1599:0] din_keccak, dout_keccak;
   assign din_keccak = reg_file_to_ip.data;
			       			        	
	keccak_f i_keccak (
		.clk(clk_i),
		.rst_n(rst_ni),
		.start_i(reg_file_to_ip.ctrl.q),
		.Din(din_keccak),
		.Dout(dout_keccak),
		.status_d(ip_to_reg_file.status.d),
		.keccak_intr(keccak_intr_o)
	);


	assign ip_to_reg_file.data[49].d = dout_keccak[1599:1568];
	assign ip_to_reg_file.data[48].d = dout_keccak[1567:1536];
	assign ip_to_reg_file.data[47].d = dout_keccak[1535:1504];
	assign ip_to_reg_file.data[46].d = dout_keccak[1503:1472];
	assign ip_to_reg_file.data[45].d = dout_keccak[1471:1440];
	assign ip_to_reg_file.data[44].d = dout_keccak[1439:1408];
	assign ip_to_reg_file.data[43].d = dout_keccak[1407:1376];
	assign ip_to_reg_file.data[42].d = dout_keccak[1375:1344];
	assign ip_to_reg_file.data[41].d = dout_keccak[1343:1312];
	assign ip_to_reg_file.data[40].d = dout_keccak[1311:1280];
	assign ip_to_reg_file.data[39].d = dout_keccak[1279:1248];
	assign ip_to_reg_file.data[38].d = dout_keccak[1247:1216];
	assign ip_to_reg_file.data[37].d = dout_keccak[1215:1184];
	assign ip_to_reg_file.data[36].d = dout_keccak[1183:1152];
	assign ip_to_reg_file.data[35].d = dout_keccak[1151:1120];
	assign ip_to_reg_file.data[34].d = dout_keccak[1119:1088];
	assign ip_to_reg_file.data[33].d = dout_keccak[1087:1056];
	assign ip_to_reg_file.data[32].d = dout_keccak[1055:1024];
	assign ip_to_reg_file.data[31].d = dout_keccak[1023:992];
	assign ip_to_reg_file.data[30].d = dout_keccak[991:960];
	assign ip_to_reg_file.data[29].d = dout_keccak[959:928];
	assign ip_to_reg_file.data[28].d = dout_keccak[927:896];
	assign ip_to_reg_file.data[27].d = dout_keccak[895:864];
	assign ip_to_reg_file.data[26].d = dout_keccak[863:832];
	assign ip_to_reg_file.data[25].d = dout_keccak[831:800];
	assign ip_to_reg_file.data[24].d = dout_keccak[799:768];
	assign ip_to_reg_file.data[23].d = dout_keccak[767:736];
	assign ip_to_reg_file.data[22].d = dout_keccak[735:704];
	assign ip_to_reg_file.data[21].d = dout_keccak[703:672];
	assign ip_to_reg_file.data[20].d = dout_keccak[671:640];
	assign ip_to_reg_file.data[19].d = dout_keccak[639:608];
	assign ip_to_reg_file.data[18].d = dout_keccak[607:576];
	assign ip_to_reg_file.data[17].d = dout_keccak[575:544];
	assign ip_to_reg_file.data[16].d = dout_keccak[543:512];
	assign ip_to_reg_file.data[15].d = dout_keccak[511:480];
	assign ip_to_reg_file.data[14].d = dout_keccak[479:448];
	assign ip_to_reg_file.data[13].d = dout_keccak[447:416];
	assign ip_to_reg_file.data[12].d = dout_keccak[415:384];
	assign ip_to_reg_file.data[11].d = dout_keccak[383:352];
	assign ip_to_reg_file.data[10].d = dout_keccak[351:320];
	assign ip_to_reg_file.data[9].d  = dout_keccak[319:288];
	assign ip_to_reg_file.data[8].d  = dout_keccak[287:256];
	assign ip_to_reg_file.data[7].d  = dout_keccak[255:224];
	assign ip_to_reg_file.data[6].d  = dout_keccak[223:192];
	assign ip_to_reg_file.data[5].d  = dout_keccak[191:160];
	assign ip_to_reg_file.data[4].d  = dout_keccak[159:128];
	assign ip_to_reg_file.data[3].d  = dout_keccak[127:96];
	assign ip_to_reg_file.data[2].d  = dout_keccak[95:64];
	assign ip_to_reg_file.data[1].d  = dout_keccak[63:32];
	assign ip_to_reg_file.data[0].d  = dout_keccak[31:0];

endmodule : keccak_top
