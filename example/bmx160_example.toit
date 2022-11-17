import gpio
import i2c
import bmx160

main:
  bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22

  device := bus.device bmx160.I2C_ADDRESS
  bmx160 := bmx160.BMX160 device

  while true:
    bmx160.get_all_data
    sleep --ms=100