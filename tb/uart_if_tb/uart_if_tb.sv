/*
Description
Author : Foez Ahmed (foez.official@gmail.com)
<br>
<br>This file is part of squared-studio:uart
<br>Copyright (c) 2024 squared-studio
<br>Licensed under the MIT License
<br>See LICENSE file in the project root for full license information
*/

module uart_if_tb;

`define ENABLE_DUMPFILE

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-IMPORTS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // bring in the testbench essentials functions and macros
`include "vip/tb_ess.sv"

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INTERFACES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  uart_if intf ();

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  initial
  begin

    fork
      #0ns intf.send_tx(8'hFF);
      #1ns intf.send_tx(8'h00);
      #2ns intf.send_tx(8'h08);
      #3ns intf.send_tx(8'h18);

      repeat(4)
      begin
        logic [7:0] data;
        logic parity;
        intf.recv_tx(data, parity);
        $display("Received data: %h, parity: %b", data, parity);
      end

      begin
        intf.wait_tx_idle();
        $display("Transmitter is idle");
      end

      begin
        intf.wait_rx_idle();
        $display("Receiver is idle");
      end

    join

    #10us;

    $finish;

  end

endmodule
