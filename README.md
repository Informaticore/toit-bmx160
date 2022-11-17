# toit-dps368
Library to control a DPS368 Pressure Sensor with toitlang

## Getting Started
```
import gpio
import i2c
import dps368
import dps368.config as cfg

main:
  bus := i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22

  device := bus.device dps368.I2C_ADDRESS_PD
  dps368 := dps368.DPS368 device
  dps368.init cfg.MEASURE_RATE.TIMES_4 cfg.OVERSAMPLING_RATE.TIMES_64 cfg.MEASURE_RATE.TIMES_4 cfg.OVERSAMPLING_RATE.TIMES_1

  sleep --ms=100 
  dps368.measureContinousPressureAndTemperature

  print "ProductId:  $dps368.productId"
  print "Config: $dps368.measure_config"
  while true:
    print "$(%.2f dps368.pressure) pA"
    print "$(%.2f dps368.temperature) °C"
    sleep --ms=1000
```

## Run tests
To run all tests you can use
```
toit run --no-device tests/run_all.toit
```