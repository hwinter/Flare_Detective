#!/usr/bin/env python
"""Based on http://matplotlib.sourceforge.net/examples/animation/dynamic_image2.html"""
import os
import sunpy
import matplotlib.pyplot as plt
import matplotlib.animation as animation
 
imagedir = '/home//hwinter/programs/Flare_Detective/test_files'
filenames = sorted(os.listdir(imagedir))
 
fig = plt.figure()
 
ims = []
for x in filenames:
    print("Processing %s" % x)
    im = sunpy.make_map(os.path.join(imagedir, x)).resample((1024, 1024))
    extent = im.xrange + im.yrange
    axes = plt.imshow(im, origin='lower', extent=extent, norm=im.norm(), cmap=im.cmap)
 
    ims.append([axes])
 
ani = animation.ArtistAnimation(fig, ims, interval=50, blit=True, repeat_delay=1000)
ani.save('output.mp4', fps=20)
 
plt.show()
