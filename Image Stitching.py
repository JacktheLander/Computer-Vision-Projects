import cv2
import numpy as np

img = cv2.imread("Resources/cards.jpg")

vert = np.vstack((img,img)) #vertically copies and stacks image
quad = np.hstack((vert,vert))   #horizontally copies and stacks

cv2.imshow("vertical", quad)

cv2.waitKey(0)
