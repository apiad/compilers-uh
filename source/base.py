# coding: utf8

import pydot
import os


class Globals:
    images = 0


class Graph:
    def _image_name(self):
        Globals.images += 1
        filename = os.getenv('FILENAME')
        filename = os.path.basename(filename).split(".")[0]
        return f"image-{filename}-{Globals.images}"

    def print(self, label="", caption="", float=True, width="50%"):
        if not label:
            label = self._image_name()

        fname = f"build/graphics/{label}.svg"

        self.graph().write_svg(fname)

        output = f"![{caption}](../graphics/{label}.svg){{ #{label} width={width} }}"

        if not float:
            output += "\\"

        print(output)

    def _repr_svg_(self):
        return self.graph().create_svg().decode('utf8')

    def graph(self) -> pydot.Graph:
        raise NotImplementedError()
