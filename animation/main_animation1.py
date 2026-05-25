from manim import *
import numpy as np

class MultiWindowSignal(Scene):
    def construct(self):
        # 1. Configurazione del sistema di assi cartesiani
        axes = Axes(
            x_range=[0, 10, 1],
            y_range=[-2, 2, 1],
            x_length=10,
            y_length=4,
            axis_config={"include_numbers": True},
        )
        axes_labels = axes.get_axis_labels(x_label="t", y_label="f(t)")
        
        # Definizione del segnale f(t)
        def signal_func(t):
            return np.sin(2 * np.pi * t) + 0.5 * np.sin(4 * np.pi * t)
            
        signal_line = axes.plot(signal_func, color=BLUE)
        
        self.play(Create(axes), Write(axes_labels))
        self.play(Create(signal_line), run_time=2)
        self.wait(0.5)
        
        # Dimensioni geometriche comuni per le finestre
        rect_height = axes.y_axis.unit_size * 4
        window_time_width = 1.0
        rect_width = axes.x_axis.unit_size * window_time_width

        # =========================================================================
        # FASE 1: Finestra con sovrapposizione (Avanzamento di 0.8s)
        # =========================================================================
        overlap = 0.2
        step_size_1 = window_time_width - overlap  # 0.8 secondi
        
        window1 = Rectangle(
            width=rect_width,
            height=rect_height,
            fill_color=BLACK, 
            fill_opacity=0.85,
            stroke_color=YELLOW,
            stroke_width=2
        )
        
        # Posizionamento iniziale della prima finestra (centro a t=0.5)
        current_t_center = window_time_width / 2
        window1.move_to(axes.c2p(current_t_center, 0))
        
        self.play(FadeIn(window1))
        self.wait(0.5)
        
        while current_t_center + (window_time_width / 2) < 10:
            current_t_center += step_size_1
            if current_t_center + (window_time_width / 2) > 10:
                current_t_center = 10 - (window_time_width / 2)
                
            self.play(
                window1.animate.move_to(axes.c2p(current_t_center, 0)),
                run_time=0.4,
                rate_func=linear
            )
            self.wait(0.2)
            
        # Rimozione della prima finestra
        self.play(FadeOut(window1))
        self.wait(1.0)

        # =========================================================================
        # FASE 2: Nuova finestra senza sovrapposizione (Avanzamento di 1.0s)
        # =========================================================================
        step_size_2 = window_time_width  # 1.0 secondo netto (nessuna sovrapposizione)
        
        window2 = Rectangle(
            width=rect_width,
            height=rect_height,
            fill_color=BLACK,
            fill_opacity=0.85,
            stroke_color=RED,  # Colore rosso per distinguere visivamente la seconda fase
            stroke_width=2
        )
        
        # Reset del posizionamento all'inizio del grafico (t=0.5)
        current_t_center = window_time_width / 2
        window2.move_to(axes.c2p(current_t_center, 0))
        
        self.play(FadeIn(window2))
        self.wait(0.5)
        
        while current_t_center + (window_time_width / 2) < 10:
            current_t_center += step_size_2
            if current_t_center + (window_time_width / 2) > 10:
                current_t_center = 10 - (window_time_width / 2)
            
            # Animazione di spostamento lineare senza intersezioni residue
            self.play(
                window2.animate.move_to(axes.c2p(current_t_center, 0)),
                run_time=0.4,
                rate_func=linear
            )
            self.wait(0.2)
            
        self.play(FadeOut(window2))
        self.wait(1)