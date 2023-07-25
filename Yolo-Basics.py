from ultralytics import YOLO
import cv2

model = YOLO('../YOLO weights/yolov8l.pt')
results = model("Images/party.JPG", show=True)
cv2.waitKey(0)