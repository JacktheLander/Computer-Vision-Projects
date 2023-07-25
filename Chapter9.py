import cv2
import numpy as np

faceCascade = cv2.CascadeClassifier("Resources/haarcascades/haarcascade_frontalface_default.xml")
img = cv2.imread("Resources/faces2.JPG")
imgGray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

faces = faceCascade.detectMultiScale(imgGray, 1.1, 4)

for(x,y,w,h) in faces:
    cv2.rectangle(img,(x,y),(x+w, y+h), (255, 0, 0), 2)

imgCropped = cv2.resize(img, (700,400))

cv2.imshow("Result", imgCropped)
cv2.waitKey(0)