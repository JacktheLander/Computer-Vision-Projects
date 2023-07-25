import cv2
import numpy as np

faceCascade = cv2.CascadeClassifier("Resources/haarcascades/haarcascade_frontalface_default.xml")
Width, Height = 200, 300
cap = cv2.VideoCapture("Resources/Faces.MOV")
while True:
    success, img = cap.read()
    img = cv2.resize(img, (Width, Height))

    imgGray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    faces = faceCascade.detectMultiScale(imgGray, 1.1, 4)

    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 0), 2)

    imgCropped = cv2.resize(img, (800, 1000))

    cv2.imshow("Result", imgCropped)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
#We can recognize this fails because the frame analysis causes the picture quality to decrease beyond functionality