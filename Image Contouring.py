import cv2
import numpy as np

def getContours(img):
    contours, hierarchy = cv2.findContours(img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)  #RETR_EXTERNAL is the contour retrieval method
    for i in contours:
        area = cv2.contourArea(i)
        print(area)
        if area>100:
            cv2.drawContours(imgContour, i, -1, (255, 0, 0), 3)  # we use -1 because we want to draw all the contours

            perimeter = cv2.arcLength(i, True)
            print(perimeter)
            approx = cv2.approxPolyDP(i, 0.02*perimeter, True)     #creates a matrix for the points in each shapes

            objCorners = len(approx)
            print(objCorners)                                       #counts the number of sides

            x, y, w, h = cv2.boundingRect(approx)
            cv2.rectangle(imgContour, (x, y), (x + w, y + h), (0, 255, 0), 2)  # draws bounding boxes around shapes

            if objCorners == 3: ObjectType = "Triangle"
            else: ObjectType = "unknown"
            cv2.putText(imgContour, ObjectType, (x+(w//2)-10, y+(h//2)-10), cv2.FONT_HERSHEY_PLAIN, 1, (0,0,0), 1)    #Labels shapes


img = cv2.imread("Resources/shapes.png")
imgContour = img.copy()

imgGray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
imgBlur = cv2.GaussianBlur(imgGray, (7, 7), 1)
imgCanny = cv2.Canny(imgBlur, 50, 50)

getContours(imgCanny)

cv2.imshow("image", img)
cv2.imshow("Canny", imgCanny)
cv2.imshow("Contoured", imgContour)
cv2.waitKey(0)
