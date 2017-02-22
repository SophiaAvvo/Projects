# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from PIL import Image

box1 = (0, 77, 983, 997)
box2 = (0, 912, 983, 1538)
box3 = (0, 102, 983, 733)
box4 = (0, 738, 983, 1404)
box5 = (0, 346, 983, 869)
box6 = (0, 0, 983, 522)
box7 = (0, 521, 983, 901)
box8 = (0, 38, 983, 611)
box9 = (0, 626, 983, 1106)
box10 = (0, 0, 983, 635)
box11 = (0, 678, 983, 1246)
box12 = (0, 1700, 983, 2283)
box13 = (0, 0, 983, 671)
box14 = (0, 1180, 983, 1586)
box15 = (0, 156, 983, 835)
box16 = (0, 1127, 983, 1826) # fix filter on image extraction
box17 = (0, 428, 983, 1003) # more views can be made from these consumer KPIs
box18 = (0, 437, 983, 1047) #lawyer KPIs
box19 = (0, 1007, 983, 1566) #consumer KPIs
box20 = (0, 1050, 983, 1627) #lawyer KPIs
box21 = (0, 41, 983, 775) #Key Consumer Engagement Metrics
box22 = (0, 817, 983, 1434) #Key Consumer Engagement Metrics
box23 = (0, 91, 983, 735) #Lawyer Engagement Metrics
box24 = (0, 737, 983, 1360) #Lawyer Engagement Metrics
box25 = (0, 52, 983, 678) #Monetization

img1 = Image.open("C:/Users/srobinson/Documents/TabCMD/view1.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region1 = img1.crop(box1)

region1.save("display1.png")

img2 = Image.open("C:/Users/srobinson/Documents/TabCMD/view2.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region2 = img2.crop(box2)

region2.save("display2.png")

img3 = Image.open("C:/Users/srobinson/Documents/TabCMD/view3.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region3 = img3.crop(box3)

region3.save("display3.png")

img4 = Image.open("C:/Users/srobinson/Documents/TabCMD/view4.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region4 = img4.crop(box4)

region4.save("display4.png")

img5 = Image.open("C:/Users/srobinson/Documents/TabCMD/view5.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region5 = img5.crop(box5)

region5.save("display5.png")

img6 = Image.open("C:/Users/srobinson/Documents/TabCMD/view6.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region6 = img6.crop(box6)

region6.save("display6.png")

img7 = Image.open("C:/Users/srobinson/Documents/TabCMD/view7.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region7 = img7.crop(box7)

region7.save("display7.png")

img8 = Image.open("C:/Users/srobinson/Documents/TabCMD/view8.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region8 = img8.crop(box8)

region8.save("display8.png")

img9 = Image.open("C:/Users/srobinson/Documents/TabCMD/view9.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region9 = img9.crop(box9)

region9.save("display9.png")

img10 = Image.open("C:/Users/srobinson/Documents/TabCMD/view10.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region10 = img10.crop(box10)

region10.save("display10.png")

img11 = Image.open("C:/Users/srobinson/Documents/TabCMD/view11.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region11 = img11.crop(box11)

region11.save("display11.png")

img12 = Image.open("C:/Users/srobinson/Documents/TabCMD/view12.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region12 = img12.crop(box12)

region12.save("display12.png")

img13 = Image.open("C:/Users/srobinson/Documents/TabCMD/view13.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region13 = img13.crop(box13)

region13.save("display13.png")

img14 = Image.open("C:/Users/srobinson/Documents/TabCMD/view14.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region14 = img14.crop(box14)

region14.save("display14.png")

img15 = Image.open("C:/Users/srobinson/Documents/TabCMD/view15.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region15 = img15.crop(box15)

region15.save("display15.png")

img16 = Image.open("C:/Users/srobinson/Documents/TabCMD/view16.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region16 = img16.crop(box16)

region16.save("display16.png")

img17 = Image.open("C:/Users/srobinson/Documents/TabCMD/view17.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region17 = img17.crop(box17)

region17.save("display17.png")

img18 = Image.open("C:/Users/srobinson/Documents/TabCMD/view18.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region18 = img18.crop(box18)

region18.save("display18.png")

img19 = Image.open("C:/Users/srobinson/Documents/TabCMD/view19.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region19 = img19.crop(box19)

region19.save("display19.png")

img20 = Image.open("C:/Users/srobinson/Documents/TabCMD/view20.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region20 = img20.crop(box20)

region20.save("display20.png")

img21 = Image.open("C:/Users/srobinson/Documents/TabCMD/view21.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region21 = img21.crop(box21)

region21.save("display21.png")

img22 = Image.open("C:/Users/srobinson/Documents/TabCMD/view22.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region22 = img22.crop(box22)

region22.save("display22.png")

img23 = Image.open("C:/Users/srobinson/Documents/TabCMD/view23.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region23 = img23.crop(box23)

region23.save("display23.png")

img24 = Image.open("C:/Users/srobinson/Documents/TabCMD/view24.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region24 = img24.crop(box24)

region24.save("display24.png")

img25 = Image.open("C:/Users/srobinson/Documents/TabCMD/view25.png")#Image.open("C:\Users\srobinson\Documents\TabCMD\view1.png")

region25 = img25.crop(box25)

region25.save("display25.png")