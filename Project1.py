import cv2
import numpy as np

#Project 1: Virtual Paint


Width, Height = 200, 300
cap = cv2.VideoCapture("Resources/IMG_1957.MOV")
while True:
    success, img = cap.read()
    img = cv2.resize(img, (Width, Height))
    cv2.imshow("Result", img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

def findColor(img):
    imgHSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    lower = np.array([h_min,s_min,v_min])
    upper = np.array([h_max,s_max,v_max])
    mask = cv2.inRange(imgHSV,lower,upper)     #the mask can be used to find the color range we want to use
    imgResult = cv2.bitwise_and(img,img,mask=mask)