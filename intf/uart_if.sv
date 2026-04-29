interface uart_if;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  tri1 tx;
  tri1 rx;

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-INTERNAL VARIABLES
  //////////////////////////////////////////////////////////////////////////////////////////////////

  /* verilog_format: off */
  int unsigned baud_rate    = 115200;   // bits per second
  int unsigned parity_type  = 0;        // 0:none 1:odd 2:even 3:mark 4:space
  int unsigned data_bits    = 8;        // number of data bits
  int unsigned stop_bits    = 1;        // number of stop bits
  /* verilog_format: on */

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

  `define UART_IF_METHODS(__NAME__)                                                                \
                                                                                                   \
    bit ``__NAME__``_drive;                                                                        \
    bit ``__NAME__``_reg;                                                                          \
    semaphore ``__NAME__``_send_sem = new(1);                                                      \
                                                                                                   \
    assign ``__NAME__`` = ``__NAME__``_drive ? ``__NAME__``_reg : 1'bz;                            \
                                                                                                   \
    task automatic send_``__NAME__``(                                                              \
        input integer unsigned data,                                                               \
        input int unsigned _baud_rate = baud_rate,                                                 \
        input int unsigned _parity_type = parity_type,                                             \
        input int unsigned _data_bits = data_bits,                                                 \
        input int unsigned _stop_bits = stop_bits                                                  \
      );                                                                                           \
                                                                                                   \
      realtime        _bit_time;                                                                   \
      logic           _parity_bit;                                                                 \
      logic           _queue      [$];                                                             \
      logic    [31:0] _data;                                                                       \
                                                                                                   \
      baud_rate   = _baud_rate;                                                                    \
      parity_type = _parity_type;                                                                  \
      data_bits   = _data_bits;                                                                    \
      stop_bits   = _stop_bits;                                                                    \
      _data       = data;                                                                          \
                                                                                                   \
      case (_parity_type)                                                                          \
        1: _parity_bit = ^_data;                                                                   \
        2: _parity_bit = ~(^_data);                                                                \
        3: _parity_bit = 1;                                                                        \
        4: _parity_bit = 0;                                                                        \
        default: _parity_bit = 0;                                                                  \
      endcase                                                                                      \
                                                                                                   \
      _bit_time = 1s / _baud_rate;                                                                 \
                                                                                                   \
      _queue.push_back('0);                                                                        \
      for (int i = 0; i < _data_bits; i++) begin                                                   \
        _queue.push_back(_data[i]);                                                                \
      end                                                                                          \
      if (_parity_type != 0) begin                                                                 \
        _queue.push_back(_parity_bit);                                                             \
      end                                                                                          \
      for (int i = 0; i < _stop_bits; i++) begin                                                   \
        _queue.push_back('1);                                                                      \
      end                                                                                          \
                                                                                                   \
      ``__NAME__``_send_sem.get(1);                                                                \
      ``__NAME__``_drive <= '1;                                                                    \
                                                                                                   \
      while (_queue.size() > 0) begin                                                              \
        ``__NAME__``_reg <= _queue.pop_front();                                                    \
        #_bit_time;                                                                                \
      end                                                                                          \
                                                                                                   \
      ``__NAME__``_drive <= '0;                                                                    \
      ``__NAME__``_send_sem.put(1);                                                                \
                                                                                                   \
    endtask                                                                                        \
                                                                                                   \
    semaphore ``__NAME__``_recv_sem = new(1);                                                      \
                                                                                                   \
    task automatic recv_``__NAME__``(                                                              \
        output integer unsigned data,                                                              \
        output integer unsigned parity_bit,                                                        \
        input  int unsigned _baud_rate = baud_rate,                                                \
        input  int unsigned _parity_type = parity_type,                                            \
        input  int unsigned _data_bits = data_bits                                                 \
      );                                                                                           \
                                                                                                   \
      realtime        _bit_time;                                                                   \
      logic           _parity_bit;                                                                 \
      logic    [31:0] _data;                                                                       \
                                                                                                   \
      baud_rate   = _baud_rate;                                                                    \
      parity_type = _parity_type;                                                                  \
      data_bits   = _data_bits;                                                                    \
      _data       = data;                                                                          \
      _bit_time = 1s / _baud_rate;                                                                 \
                                                                                                   \
      ``__NAME__``_recv_sem.get(1);                                                                \
                                                                                                   \
      do begin                                                                                     \
        @(negedge ``__NAME__``);                                                                   \
        #(_bit_time / 2);                                                                          \
      end while (``__NAME__``);                                                                    \
                                                                                                   \
      for (int i = 0; i < _data_bits; i++) begin                                                   \
        #(_bit_time);                                                                              \
        _data[i] = ``__NAME__``;                                                                   \
      end                                                                                          \
                                                                                                   \
      if (_parity_type != 0) begin                                                                 \
        #(_bit_time);                                                                              \
        _parity_bit = ``__NAME__``;                                                                \
      end                                                                                          \
                                                                                                   \
      #(_bit_time);                                                                                \
                                                                                                   \
      data = _data;                                                                                \
      parity_bit = _parity_bit;                                                                    \
                                                                                                   \
      ``__NAME__``_recv_sem.put(1);                                                                \
                                                                                                   \
    endtask                                                                                        \
                                                                                                   \
    task automatic wait_``__NAME__``_idle(int wait_cycles = 30);                                   \
      realtime done_time;                                                                          \
      bit completed;                                                                               \
                                                                                                   \
      completed = 0;                                                                               \
      done_time = $realtime + ((wait_cycles * 1s) / baud_rate);                                    \
                                                                                                   \
      fork                                                                                         \
        while (!completed) begin                                                                   \
          @(``__NAME__`` or completed);                                                            \
          if (!completed) done_time = $realtime + ((wait_cycles * 1s) / baud_rate);                \
        end                                                                                        \
        while (!completed) begin                                                                   \
          #(1s / baud_rate);                                                                       \
          if ($realtime >= done_time) completed = 1;                                               \
        end                                                                                        \
      join                                                                                         \
                                                                                                   \
    endtask                                                                                        \


  `UART_IF_METHODS(tx)
  // task automatic send_tx(
  //     input int unsigned data,
  //     input int unsigned _baud_rate = baud_rate,
  //     input int unsigned _parity_type = parity_type,
  //     input int unsigned _data_bits = data_bits,
  //     input int unsigned _stop_bits = stop_bits
  // ); 
  //
  // task automatic recv_tx(
  //     output int unsigned data,
  //     output int unsigned parity_bit,
  //     input  int unsigned _baud_rate = baud_rate,
  //     input  int unsigned _parity_type = parity_type,
  //     input  int unsigned _data_bits = data_bits
  // ); 
  //
  // task automatic wait_tx_idle(int wait_cycles = 30);

  `UART_IF_METHODS(rx)
  // task automatic send_rx(
  //     input int unsigned data,
  //     input int unsigned _baud_rate = baud_rate,
  //     input int unsigned _parity_type = parity_type,
  //     input int unsigned _data_bits = data_bits,
  //     input int unsigned _stop_bits = stop_bits
  // ); 
  //
  // task automatic recv_rx(
  //     output int unsigned data,
  //     output int unsigned parity_bit,
  //     input  int unsigned _baud_rate = baud_rate,
  //     input  int unsigned _parity_type = parity_type,
  //     input  int unsigned _data_bits = data_bits
  // ); 
  //
  // task automatic wait_rx_idle(int wait_cycles = 30);

  `undef UART_IF_METHODS

endinterface
