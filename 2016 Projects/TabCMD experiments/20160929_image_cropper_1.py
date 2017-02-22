# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from PIL import Image

img1 = Image.open("C:/Users/srobinson/Documents/TabCMD/view1.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

box1 = (0, 77, 983, 997)
region1 = img1.crop(box1)

region1.save("display1.png")



