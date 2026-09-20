# Linux Kernel 7.2.x - ThinkPad P52 (Custom Build)

Kernel monolitico/hibrido para Lenovo ThinkPad P52 (i7-8850H, 8a Geracao).

## Estrategia
- Built-in (=y): Todo hardware essencial
- Modulos (=m): Apenas NVIDIA driver 550 + CUDA
- Desabilitado: RTL, ISH, hardware legado

## Hardware
- CPU: Intel i7-8850H (6C/12T, Coffee Lake-H)
- RAM: 128 GB DDR4
- Storage: Kingston NV2 4TB NVMe + Seagate 2TB HDD
- GPU: Intel UHD 630 (built-in) + NVIDIA (modulo)
- Rede: Intel I219-LM + Intel 9460/9560 WiFi/BT
- Audio: Intel Cannon Lake PCH cAVS (ALC285)
- Input: TrackPoint + Elantech Touchpad + Logitech M575
- USB: Chicony Camera + Synaptics Fingerprint + Alcor Smartcard

## Builds
- 7.2.4-1 (2026-09-19): Build limpo, RTL/ISH removidos, TrackPoint/Elantech SMBus habilitados
