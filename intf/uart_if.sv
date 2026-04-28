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
  int unsigned stop_bits    = 1;        // number of stop bits
  int unsigned data_bits    = 8;        // number of data bits
  /* verilog_format: on */

  //////////////////////////////////////////////////////////////////////////////////////////////////
  //-METHODS
  //////////////////////////////////////////////////////////////////////////////////////////////////

`define UART_IF_METHODS(__NAME__)                                                                  \
                                                                                                   \
  bit ``__NAME__``_drive;                                                                          \
  bit ``__NAME__``_reg;                                                                            \
  assign ``__NAME__`` = ``__NAME__``_drive ? ``__NAME__``_reg : 1'bz;                              \
  task automatic send_``__NAME__``(input int unsigned data,                                        \
                                   input int unsigned _baud_rate = baud_rate,                      \
                                   input int unsigned _parity_type = parity_type,                  \
                                   input int unsigned _stop_bits = stop_bits,                      \
                                   input int unsigned _data_bits = data_bits);                     \
                                                                                                   \
    realtime        _bit_time;                                                                     \
    bit             _parity_bit;                                                                   \
    bit             _queue      [$];                                                               \
    bit      [31:0] _data;                                                                         \
                                                                                                   \
    baud_rate   = _baud_rate;                                                                      \
    parity_type = _parity_type;                                                                    \
    stop_bits   = _stop_bits;                                                                      \
    data_bits   = _data_bits;                                                                      \
    _data       = data;                                                                            \
                                                                                                   \
    case (_parity_type)                                                                            \
      1: _parity_bit = ^_data;                                                                     \
      2: _parity_bit = ~(^_data);                                                                  \
      3: _parity_bit = 1;                                                                          \
      4: _parity_bit = 0;                                                                          \
      default: _parity_bit = 0;                                                                    \
    endcase                                                                                        \
                                                                                                   \
    _bit_time = 1s / _baud_rate;                                                                   \
                                                                                                   \
    _queue.push_back('0);                                                                          \
    for (int i = 0; i < _data_bits; i++) begin                                                     \
      _queue.push_back(_data[i]);                                                                  \
    end                                                                                            \
    if (_parity_type != 0) begin                                                                   \
      _queue.push_back(_parity_bit);                                                               \
    end                                                                                            \
    for (int i = 0; i < _stop_bits; i++) begin                                                     \
      _queue.push_back('1);                                                                        \
    end                                                                                            \
                                                                                                   \
    ``__NAME__``_drive <= '1;                                                                      \
                                                                                                   \
    while (_queue.size() > 0) begin                                                                \
      ``__NAME__``_reg <= _queue.pop_front();                                                      \
      #_bit_time;                                                                                  \
    end                                                                                            \
                                                                                                   \
    ``__NAME__``_drive <= '0;                                                                      \
                                                                                                   \
  endtask                                                                                          \


  `UART_IF_METHODS(tx)
  `UART_IF_METHODS(rx)

  `undef UART_IF_METHODS

endinterface
