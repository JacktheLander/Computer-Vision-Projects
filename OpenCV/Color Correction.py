import cv2
import numpy as np
def empty(a):
    pass

img = cv2.imread("Resources/greencar.jpg")

cv2.namedWindow("Trackbar")
cv2.resizeWindow("Trackbar",640,240)
cv2.createTrackbar("Hue min", "Trackbar",0,179,empty)   #creates a trackbar with 180 values
cv2.createTrackbar("Hue max", "Trackbar",179,179,empty) #defines max

cv2.createTrackbar("Sat min", "Trackbar",0,255,empty)   #saturation has 256 values
cv2.createTrackbar("Sat max", "Trackbar",255,255,empty)

cv2.createTrackbar("Val min", "Trackbar",0,255,empty)
cv2.createTrackbar("Val max", "Trackbar",255,255,empty)

while True:
    imgHSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    #imgHLS = cv2.cvtColor(img, cv2.COLOR_BGR2HLS)

    h_min = cv2.getTrackbarPos("Hue min", "Trackbar")
    h_max = cv2.getTrackbarPos("Hue max", "Trackbar")
    s_min = cv2.getTrackbarPos("Sat min", "Trackbar")
    s_max = cv2.getTrackbarPos("Sat max", "Trackbar")
    v_min = cv2.getTrackbarPos("Val min", "Trackbar")
    v_max = cv2.getTrackbarPos("Val max", "Trackbar")

    lower = np.array([h_min,s_min,v_min])
    upper = np.array([h_max,s_max,v_max])
    mask = cv2.inRange(imgHSV,lower,upper)     #the mask can be used to find the color range we want to use
    imgResult = cv2.bitwise_and(img,img,mask=mask)

    cv2.imshow("original", img)
    cv2.imshow("imgHSV", imgHSV)
    #cv2.imshow("imgHLS", imgHLS)    #these distort the colors making target colors more detectable

    cv2.imshow("imgmask", mask)
    cv2.imshow("Result", imgResult)

    cv2.waitKey(1)
