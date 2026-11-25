#!/bin/bash
# SCREENSAVER POLIGONAL DIGITAL
# Ativa a cada 15 minutos de inatividade
# Não trava o ecra, apenas mostra animação poligonal

export DISPLAY=:0
export WAYLAND_DISPLAY=$(echo $WAYLAND_DISPLAY)

# Verificar se o display está disponível
if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "Warning: WAYLAND_DISPLAY not set, using fallback"
fi

# Executar o screensaver
python3 /home/etl-bi/kernel-dev/customize/polygonsaver/polygon_saver.py &

echo "Polygon saver iniciado com PID $!"
