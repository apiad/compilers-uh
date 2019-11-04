# coding: utf8

import sys
sys.path.append('..')

from source.diagrams import Pipeline, Lexer
from source.trees import Tree

class Lecture0:
    @staticmethod
    def compiler_pipeline_0():
        return Pipeline(['HULK', 'Compilador', 'MIPS'], [
                  (0, 1, ""),
                  (1, 2, ""),
               ], startshape='plaintext', endshape='plaintext')

    @staticmethod
    def compiler_pipeline_1():
        return Pipeline(['HULK', 'Parser', 'Generador', 'MIPS'], [
                  (0, 1, ""),
                  (1, 2, ""),
                  (2, 3, ""),
               ], startshape='plaintext', endshape='plaintext')

    
    @staticmethod
    def compiler_pipeline_2():
        return Pipeline(['HULK', 'Parser', 'Generador', 'MIPS'], [
                   (0, 1, ""),
                   (1, 2, "IR"),
                   (2, 3, ""),
               ], startshape='plaintext', endshape='plaintext')

    @staticmethod
    def compiler_pipeline_3():
        return Pipeline(['HULK', 'Parser', 'Semántico', 'Generador', 'MIPS'], [
                   (0, 1, ""),
                   (1, 2, ""),
                   (2, 3, ""),
                   (3, 4, ""),
               ], startshape='plaintext', endshape='plaintext')

    @staticmethod
    def compiler_pipeline_4():
        return Pipeline(['HULK', 'Parser', 'Semántico', 'Generador', 'MIPS'], [
                   (0, 1, ""),
                   (1, 2, ""),
                   (2, 3, ""),
                   (3, 4, ""),
                   (3, 3, "Optimización"),
               ], startshape='plaintext', endshape='plaintext')

    @staticmethod
    def example_tree():
        return Tree("IF-EXPR",
                   Tree("<=",
                       Tree("a"),
                       Tree("0")
                   ),
                   Tree("b"),
                   Tree("c"),
               )

    @staticmethod
    def example_lexer_0():
        return Lexer(r'i f \\s ( a < = 0 ) \\n \\t b \\n e l s e \\n \\t c \\n $'.split())

    @staticmethod
    def example_lexer_1():
        return Lexer('if ( a <= 0 ) b else c'.split())

    @staticmethod
    def compiler_pipeline_5():
        return Pipeline(['HULK', 'Lexer', 'Parser', 'Semántico', 'Generador', 'MIPS'], [
                   (0, 1, ""),
                   (1, 2, ""),
                   (2, 3, ""),
                   (3, 4, ""),
                   (4, 4, "Optimización"),
                   (4, 5, ""),
               ], startshape='plaintext', endshape='plaintext')
