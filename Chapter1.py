import cv2
import numpy as np
print("package imported")

img = cv2.imread("Resources/#IMG_E1724.JPG")
kernel = np.ones((5,5),np.uint8)

imgGray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
imgBlur = cv2.GaussianBlur(imgGray,(5,5), 0)
imgCanny = cv2.Canny(img, 300,300)
imgdilation = cv2.dilate(imgCanny,kernel,iterations=1)
imgEroded = cv2.erode(imgdilation, kernel, iterations=1)

cv2.imshow("Gray image", imgGray)
cv2.imshow("Blurred image", imgBlur)
cv2.imshow("Canny image", imgCanny)
cv2.imshow("dilated image", imgdilation)
cv2.imshow("eroded image", imgEroded)

cv2.waitKey(0)