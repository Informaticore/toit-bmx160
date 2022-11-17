import serial
import .register as reg

I2C_ADDRESS     ::= 0x68
I2C_ADDRESS_ALT ::= 0x69

class BMX160:

  static SOFT_RESET_CMD ::= 0xb6
  static MAGN_UT_LSB    ::= 0.3

  reg_/serial.Registers ::= ?
  accel_range_/float := ?
  gyro_range_/float := ?

  constructor device/serial.Device:
    reg_ = device.registers
    accel_range_ = AccelRange.MG_LSB_2G.val
    gyro_range_ = GyroRange.GR_250DPS.val

    soft_reset
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x11
    sleep --ms=50
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x15
    sleep --ms=100
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x19
    sleep --ms=10
    set_magn_conf

  soft_reset:
    reg_.write_u8 reg.COMMAND_REG_ADDR SOFT_RESET_CMD
    sleep --ms=15

  set_magn_conf:
    reg_.write_u8 reg.MAGN_IF_0_ADDR 0x80
    sleep --ms=1
    reg_.write_u8 reg.MAGN_IF_3_ADDR 0x01
    reg_.write_u8 reg.MAGN_IF_2_ADDR 0x4B
    reg_.write_u8 reg.MAGN_IF_3_ADDR 0x04
    reg_.write_u8 reg.MAGN_IF_2_ADDR 0x51
    reg_.write_u8 reg.MAGN_IF_3_ADDR 0x0E
    reg_.write_u8 reg.MAGN_IF_2_ADDR 0x52
    reg_.write_u8 reg.MAGN_IF_3_ADDR 0x02
    reg_.write_u8 reg.MAGN_IF_2_ADDR 0x4C
    reg_.write_u8 reg.MAGN_IF_1_ADDR 0x42
    reg_.write_u8 reg.MAGN_CONFIG_ADDR 0x08
    reg_.write_u8 reg.MAGN_IF_0_ADDR 0x03
    sleep --ms=1

  wake_up:
    soft_reset
    sleep --ms=100
    set_magn_conf
    sleep --ms=100
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x11 
    sleep --ms=4 //command takes max. 4ms
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x15
    sleep --ms=90 //command takes max. 80ms
    reg_.write_u8 reg.COMMAND_REG_ADDR 0x19
    sleep --ms=1 //command takes max. 0.5ms

  set_gyro_range range/GyroRange:
    gyro_range_ = range.val

  set_accel_range range/AccelRange:
    accel_range_ = range.val

  get_all_data -> MAGData:
    data := reg_.read_bytes reg.MAG_DATA_ADDR 20

    magnx := calc_value data[0] data[1] MAGN_UT_LSB
    magny := calc_value data[2] data[3] MAGN_UT_LSB
    magnz := calc_value data[4] data[5] MAGN_UT_LSB
    //print "magnX: $(%.2f magnx) magnY: $(%.2f magny) magnZ: $(%.2f magnz)"

    gyrox := calc_value data[8] data[9] gyro_range_
    gyroy := calc_value data[10] data[11] gyro_range_
    gyroz := calc_value data[12] data[13] gyro_range_
    //print "gyroX: $(%.2f gyrox) gyroY: $(%.2f gyroy) gyroZ: $(%.2f gyroz)"

    accelx := calc_value data[14] data[15] (accel_range_ * 9.8)
    accely := calc_value data[16] data[17] (accel_range_ * 9.8)
    accelz := calc_value data[18] data[19] (accel_range_ * 9.8)
    //print "accelY: $(%.2f accelx) accelY: $(%.2f accely) accelZ: $(%.2f accelz)"

    return MAGData magnx magny magnz gyrox gyroy gyroz accelx accely accelz
  
  calc_value dataLSB dataMSB multiplier -> float:
    value := ((dataMSB << 8) | (dataLSB)).sign_extend --bits=16
    return value * multiplier

class GyroRange:
  val/float
  constructor.private_ .val/float:
  
  static GR_125DPS/GyroRange ::= GyroRange.private_ 0.0038110
  static GR_250DPS/GyroRange ::= GyroRange.private_ 0.0076220
  static GR_500DPS/GyroRange ::= GyroRange.private_ 0.0152439
  static GR_1000DPS/GyroRange ::= GyroRange.private_ 0.0304878
  static GR_2000DPS/GyroRange ::= GyroRange.private_ 0.0609756

class AccelRange:
  val/float
  constructor.private_ .val/float:
  
  static MG_LSB_2G/GyroRange ::= GyroRange.private_ 0.000061035
  static MG_LSB_4G/GyroRange ::= GyroRange.private_ 0.000122070
  static MG_LSB_8G/GyroRange ::= GyroRange.private_ 0.000244141
  static MG_LSB_16G/GyroRange ::= GyroRange.private_ 0.000488281

class MAGData:

  mx  := ?
  my  := ?
  mz  := ?
  gx  := ?
  gy  := ?
  gz  := ?
  ax := ?
  ay := ?
  az := ?

  constructor .mx .my .mz .gx .gy .gz .ax .ay .az:

  to_string -> string:
    return "magnX: $(%.2f mx) magnY: $(%.2f my) magnZ: $(%.2f mz) gyroX: $(%.2f gx) gyroY: $(%.2f gy) gyroZ: $(%.2f gz) accelY: $(%.2f ax) accelY: $(%.2f ay) accelZ: $(%.2f az)"