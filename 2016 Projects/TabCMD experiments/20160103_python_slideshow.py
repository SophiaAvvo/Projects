# -*- coding: utf-8 -*-
"""
Created on Mon Oct 03 13:51:08 2016

@author: srobinson
"""

''' tk_imageview_slides102.py
display a number of images as a simple slide show using Tkinter

uses PIL for image formats other then the Tkinter native GIF format
PIL/pillow is the third-party Python Image Library module

(dns)
'''

# ImageTk may need a separate install on Linux
from PIL import Image, ImageTk
import time
try:
    # Python2
    import Tkinter as tk
except ImportError:
    # Python3
    import tkinter as tk
    
import os   


# create the root window
root = tk.Tk()
# set ULC (x, y) position of root window
root.geometry("+{}+{}".format(0, 0))
root.title("Tableau Server Slide Show")

# delay in seconds (time each slide shows)
delay = 10

# create a list of image file names
# (you can add more files as needed)
# pick image files you have in your working directory or use full path
# PIL's ImageTk allows .gif  .jpg  .png  .bmp formats
#imageFiles = 

#[
#"../image/A_Dog01.jpg",
#"../image/A_Dog02.jpg",
#"../image/A_Dog03.jpg",
#"../image/A_Dog04.jpg",
#"../image/Flowers.jpg"
#]

#get all image files from directory
imageFiles = [f for f in os.listdir(os.curdir) if f.endswith('.png') and f.startswith('display')]

# create a list of image objects
# PIL's ImageTk converts to an image object that Tkinter can handle
photos = [ImageTk.PhotoImage(file=fname) for fname in imageFiles]

# use a button to display the slides
# this way a simple mouse click on the picture-button stops the show
button = tk.Button(root, command=root.destroy)
button.pack(padx=5, pady=5)

for photo in photos:
    button["image"] = photo
    root.update()
    time.sleep(delay)

# execute the event loop
root.mainloop()