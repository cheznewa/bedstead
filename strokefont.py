from __future__ import print_function

import fontforge
from math import radians
from psMat import translate
from sys import argv

class Stroker(object):
    def __init__(self, fontname):
        self.fontname = fontname
        self.dotwidth = max(0, 100 - self.nibwidth)
        self.dotheight = max(0, 100 - self.nibheight)
    def modify_font(self, f):
        f.strokedfont = False

        for g in f.glyphs():
            for i, c in enumerate(list(g.layers[1])):
                newc = self.adjust_contour(c)
                if newc != None: g.layers[1] += newc
            g.stroke(*self.nib)
            g.removeOverlap()
            g.addExtrema()
            g.transform(translate(0, self.nibheight/2.0))

        f.familyname = self.familyname
        f.fontname = self.fontname
        f.fullname = self.fullname
        f.appendSFNTName('English (US)', 'Preferred Family', self.familyname)
        f.private['StdHW'] = self.nibheight
        f.private['StdVW'] = self.nibwidth
        def adjustblue(y): return y - 100 + self.nibheight
        bv = list(f.private['BlueValues'])
        bv[1:] = map(adjustblue, bv[1:])
        f.private['BlueValues'] = tuple(bv)
        f.uwidth = self.nibheight
        f.os2_weight = self.ttfweight
        f.weight = self.weight
        return f
    def adjust_contour(self, c):
        # This function just expands dots.
        if len(c) != 1: return None
        if self.dotwidth == 0 and self.dotheight == 0: return None
        newc = fontforge.contour()
        newc.moveTo(c[0].x + self.dotwidth/2, c[0].y)
        newc.lineTo(c[0].x, c[0].y + self.dotheight/2)
        newc.lineTo(c[0].x - self.dotwidth/2, c[0].y)
        newc.lineTo(c[0].x, c[0].y - self.dotheight/2)
        newc.closed = True
        return newc
        
class Plotter(Stroker):
    familyname = "Bedstead Plotter"
    def __init__(self, penwidth, weight, ttfweight):
        self.nib = ['circular', penwidth, 'round', 'round']
        self.nibwidth = self.nibheight = penwidth
        self.fontname = "BedsteadPlotter-" + weight
        self.fullname = "%s %s" % (self.familyname, weight)
        self.ttfweight = ttfweight
        self.weight = weight
        super(Plotter, self).__init__("BedsteadPlotter-" + weight)

class Chiseltip(Stroker):
    familyname = "Bedstead Chiseltip"
    fullname = "Bedstead Chiseltip"
    weight = "Medium"
    ttfweight = 500
    def __init__(self):
        chisel = fontforge.contour()
        chisel.moveTo(-56, 7)
        chisel.lineTo(39, 41)
        chisel.lineTo(56, -7)
        chisel.lineTo(-39, -41)
        chisel.closed = True
        self.nib = ['polygonal', chisel]
        self.nibwidth = 112
        self.nibheight = 82
        super(Chiseltip, self).__init__("BedsteadChiseltip")

modes = {
    'plotter-thin': Plotter(10, "Thin", 100),
    'plotter-light': Plotter(50, "Light", 300),
    'plotter-medium': Plotter(100, "Medium", 500),
    'plotter-bold': Plotter(150, "Bold", 700),
    'chiseltip': Chiseltip(),
}

mode = modes[argv[1]]

f = fontforge.open(argv[2])

mode.modify_font(f)

f.save(argv[3])

