import cv2
import numpy as np

img = cv2.imread("Resources/cards.jpg")

width,height = 400,500

pts1 = np.float32([[85,20],[230,21],[67, 173],[222,169]])   #takes points on image
pts2 = np.float32([[0,0],[width,0],[0,height],[width, height]]) #defines boundaries for output
matrix = cv2.getPerspectiveTransform(pts1, pts2)    #creates a matrix of these points sets
imgOutput = cv2.warpPerspective(img,matrix,(width,height))  #outputs the first points sets warped to the second

cv2.imshow("image",img)
cv2.imshow("Output", imgOutput)

cv2.waitKey(0)
