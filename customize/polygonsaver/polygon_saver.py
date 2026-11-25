#!/usr/bin/env python3
"""
POLYGON DIGITAL SCREEN SAVER
Desenha geometria poligonal digital animada para tela de bloqueio.
- Ativa a cada 15 min de inatividade
- Mostra por X segundos
- Sem block (ecrã não trava)
- Tema visual "macOS-like"

Requisitos: python3, pycairo, PyGObject
Instalação: pip3 install pycairo PyGObject
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
gi.require_version('Cairo', '1.0')

import math
import random
import sys
import os
import cairo
import threading
import time
import signal
import sys

from gi.repository import Gtk, Gdk, GLib

# ===== CONFIGURAÇÕES =====
FULLSCREEN_RADIUS = 8.0
POLYGON_COLOR = (0.2, 0.4, 0.9, 1.0)  # Azul technological
POLYGON2_COLOR = (0.8, 0.3, 0.4, 1.0)  # Verde avermelhado
POLYGON3_COLOR = (0.18, 0.6, 0.35, 1.0)  # Verde

# Perímetro do polígono
NUMBER_OF_SIDES = 5
# Velocidade do movimento
MOVE_SPEED = 0.03
# Fade in/out speed
FADE_SPEED = 20.0
# Duração que o vídeo permanece (seconds)
SHOW_DURATION = 10.0

class PolygonScreenSaver:
    def __init__(self):
        self.running = True
        self.angle = 0.0
        self.zoom = 1.0
        self.time_elapsed = 0
        self.cursor_pos = (0.0, 0.0)
        
    def generate_polygons(self, ctx, width, height, time):
        """Generate the polygon pattern for the screen saver"""
        
        # Background color
        ctx.set_source_rgba(0.02, 0.06, 0.12, 1.0)  # Dark blue-black
        ctx.paint()
        
        # Seuil de afunilar
        alpha = min(1.0, (self.time_elapsed % 4.0) / 4.0)
        
        # Desenhar vários polígonos espalhados
        for i in range(25):
            # Posição e tamanho de cada polígono
            cx = (i * 7919) % width
            cy = (i * 104729) % height
            size = 40 + (i * 17) % 200
            rotation = (i * 137.508) % 360
            
            # Cor baseada no tempo e posição
            hue = (random.random() * 60 + 240) % 360
            saturation = 0.7 + 0.3 * random.random()
            value = 0.8 + random.random() * 0.2
            
            # Converter HSL para RGB
            r, g, b = self.hsl_to_rgb(hue, saturation, value)
            
            # Pesos de alta e baixa
            alpha_layer = 0.3 + 0.7 * (abs(math.sin(time * 0.5 + i)) ** 0.5)
            
            self.draw_polygon(ctx, cx, cy, size, rotation, r, g, b, alpha_layer)
        
        # Linha central de polinômios
        for i in range(8):
            cx = width / 2 + (i - 4) * 100
            size = 10 + (i % 5) * 25
            color = (0.3, 0.6, 0.9, 0.2 + 0.8 * abs(math.sin(time * 0.3 + i)))
            self.draw_polygon(ctx, cx, height / 2, size, 0, *color)
            
            cx2 = width / 2 + (i - 4) * 150 + 50
            size2 = 8 + (i % 4) * 20
            color2 = (0.7, 0.6, 0.2, 0.3 + 0.7 * abs(math.sin(time * 0.25 + i)))
            self.draw_polygon(ctx, cx2, height / 2, size2, 0, *color2)
            
        # Texto de estado
        ctx.set_source_rgba(1.0, 1.0, 1.0, 0.8)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(28)
        text = time.strftime("%H:%M:%S")
        (text_width, text_height), _ = ctx.text_extents(text)
        ctx.move_to((width - text_width) / 2, height / 2 + text_height / 2 + 100)
        ctx.show_text(text)
        
        # Mensagem
        ctx.set_source_rgba(1.0, 1.0, 1.0, 0.6)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        ctx.set_font_size(18)
        subtitle = "Digital Polygon Screen Saver"
        (sub_width, sub_height), _ = ctx.text_extents(subtitle)
        ctx.move_to((width - sub_width) / 2, height / 2 + sub_height / 2 + 130)
        ctx.show_text(subtitle)
        
        # Indicador de fragmintas
        ctx.set_source_rgba(0.9, 0.8, 0.6, 0.7)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        ctx.set_font_size(14)
        frag = "system quantum-gluon"
        (frag_w, frag_h), _ = ctx.text_extents(frag)
        ctx.move_to((width - frag_w) / 2, height / 2 + frag_h / 2 + 150)
        ctx.show_text(frag)
        
        # Desenhar linhas de rede
        for i in range(4):
            y = i * height / 5
            ctx.set_source_rgba(0.2, 0.6, 0.9, 0.2 + 0.3 * abs(math.sin(time * 0.8 + i)))
            ctx.set_line_width(1.5)
            ctx.move_to(0, y)
            ctx.line_to(width, y)
            ctx.stroke()
        
    def draw_polygon(self, ctx, cx, cy, size, rotation, r, g, b, alpha):
        """Desenhar um polígono com cores"""
        ctx.set_source_rgba(r, g, b, alpha)
        n_corners = NUMBER_OF_SIDES
        points = []
        for i in range(n_corners):
            angle = 2 * math.pi * i / n_corners - math.pi / 2
            x = cx + size * math.cos(angle + rotation)
            y = cy + size * math.sin(angle + rotation)
            points.append((x, y))
        
        ctx.move_to(points[0][0], points[0][1])
        for x, y in points[1:]:
            ctx.line_to(x, y)
        ctx.close_path()
        ctx.fill()
        
        # Borda
        ctx.set_source_rgba(1.0, 1.0, 1.0, 0.3)
        ctx.set_line_width(0.5)
        ctx.stroke()
    
    def hsl_to_rgb(self, h, s, l):
        """Converter HSL para RGB"""
        h = h / 60.0
        c = (1 - abs(2 * l - 1)) * s
        x = c * (1 - abs((h % 2) - 1))
        m = l - c / 2
        if 0 <= h < 1:
            r, g, b = c, x, 0
        elif 1 <= h < 2:
            r, g, b = x, c, 0
        elif 2 <= h < 3:
            r, g, b = 0, c, x
        elif 3 <= h < 4:
            r, g, b = 0, x, c
        elif 4 <= h < 5:
            r, g, b = x, 0, c
        else:
            r, g, b = c, 0, x
        return r + m, g + m, b + m
    
    def on_draw(self, widget, ctx):
        """Callback de desenho"""
        width = widget.get_width()
        height = widget.get_height()
        
        self.clean_draw(ctx)
        self.count_draw()
        self.draw_polygons(ctx, width, height, widget.get_frame_clock())
    
    def clean_draw(self, ctx):
        """Draw the background"""
        ctx.set_source_rgba(0.02, 0.06, 0.12, 1.0)
        ctx.paint()
    
    def count_draw(self):
        """Update internal state"""
        self.time_elapsed += 0.1
        self.angle += 0.03
        self.zoom = 1.0 + 0.1 * math.sin(self.time_elapsed * 0.01)
    
    def draw_polygons(self, ctx, width, height, frame_clock):
        """Desenhar os polígonos no canvas"""
        self.count_draw()
        
        for i in range(20):
            cx = (i * 7919) % width
            cy = (i * 104729) % height
            size = 40 + (i * 17) % 200
            rotation = (i * 137.508) % 360
            
            hue = (random.random() * 60 + 240) % 360
            sat = 0.7 + 0.3 * random.random()
            val = 0.8 + random.random() * 0.2
            r, g, b = self.hsl_to_rgb(hue, sat, val)
            alpha = 0.3 + 0.7 * (abs(math.sin(self.time_elapsed * 0.5 + i)) ** 0.5)
            
            self.draw_polygon(ctx, cx, cy, size, rotation, r, g, b, alpha)
        
        # Linhas de rede
        for i in range(4):
            y = i * height / 5
            ctx.set_source_rgba(0.2, 0.6, 0.9, 0.2 + 0.3 * abs(math.sin(self.time_elapsed * 0.8 + i)))
            ctx.set_line_width(1.5)
            ctx.move_to(0, y)
            ctx.line_to(width, y)
            ctx.stroke()
        
        # Mostrar o estado atual
        t = time.strftime("%H:%M:%S")
        ctx.set_source_rgba(1.0, 1.0, 1.0, 0.8)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        ctx.set_font_size(28)
        text = t
        (text_width, text_height), _ = ctx.text_extents(text)
        ctx.move_to((width - text_width) / 2, height / 2 + text_height / 2 + 100)
        ctx.show_text(text)
        
        ctx.set_source_rgba(1.0, 1.0, 1.0, 0.6)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        ctx.set_font_size(18)
        subtitle = "Digital Polygon Screen Saver"
        (sub_width, sub_height), _ = ctx.text_extents(subtitle)
        ctx.move_to((width - sub_width) / 2, height / 2 + sub_height / 2 + 130)
        ctx.show_text(subtitle)
        
        ctx.set_source_rgba(0.9, 0.8, 0.6, 0.7)
        ctx.select_font_face("monospace", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
        ctx.set_font_size(14)
        frag = "system quantum-gluon"
        (frag_w, frag_h), _ = ctx.text_extents(frag)
        ctx.move_to((width - frag_w) / 2, height / 2 + frag_h / 2 + 150)
        ctx.show_text(frag)

def main():
    app = PolygonScreenSaver()
    Gtk.init()
    window = Gtk.Window(orientation=Gtk.WindowOrientation.POP_UP, title="Polygon Saver")
    drawing_area = Gtk.DrawingArea()
    window.set_child(drawing_area)
    window.set_visible(True)
    drawing_area.set_can_focus(False)
    drawing_area.set_vexpand(True)
    drawing_area.set_vexpand(True)
    window.set_default_size(1920, 1080)
    window.connect("draw", app.on_draw)
    window.present()
    Gtk.main()

if __name__ == "__main__":
    main()
