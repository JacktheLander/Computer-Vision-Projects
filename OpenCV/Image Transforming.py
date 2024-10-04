import cv2
import numpy as np

img = cv2.imread("Resources/#IMG_E1724.JPG")
print(img.shape)

imgResize = cv2.resize(img,(600, 400))
print(imgResize.shape)

imgCropped = img[1000:1200, 2000:2400]

cv2.imshow("image", img)
cv2.imshow("image resized", imgResize)
cv2.imshow("image cropped", imgCropped)

cv2.waitKey(0)
