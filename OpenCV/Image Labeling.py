import cv2
import numpy as np

img = np.zeros((512,512, 3),np.uint8)
print(img.shape)

cv2.circle(img, (50,50), 20, (0,200, 32), 5)    #image name, origin point, radius, color, thickness
img[100:300, 200:300]= 230, 225, 255
cv2.line(img,(0,0),(img.shape[1],400), (0, 255, 255), 5)    #The shape function can be used to find the border value
cv2.rectangle(img, (0,100), (200,400), (255, 0, 0),cv2.FILLED) #The order determines which item is on top
cv2.putText(img, "Hello World", (330,200), cv2.FONT_HERSHEY_PLAIN, 1.7,(255,255,255))   #font defined after origin

cv2.imshow("image", img)

cv2.waitKey(0)
