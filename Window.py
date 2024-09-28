from ultralytics import YOLO
import cv2
import cvzone
import math
import time

# cap = cv2.VideoCapture(0)  # For Webcam

cap = cv2.VideoCapture("motorbikes.mp4")  # For Video
cap.set(3, 1280) #sets pixel width of display
cap.set(4, 720) #sets pixel width of display

model = YOLO("../Yolo-Weights/yolov8l.pt")

classNames = ["person", "bicycle", "car", "motorbike", "aeroplane", "bus", "train", "truck", "boat",
              "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
              "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella",
              "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat",
              "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle", "wine glass", "cup",
              "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli",
              "carrot", "hot dog", "pizza", "donut", "cake", "chair", "sofa", "pottedplant", "bed",
              "diningtable", "toilet", "tvmonitor", "laptop", "mouse", "remote", "keyboard", "cell phone",
              "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors",
              "teddy bear", "hair drier", "toothbrush"
              ]

prev_frame_time = 0
new_frame_time = 0
center = [640, 360]
p = [center[0], center[1]]  # coordinate position of window center
width = 320 #window size
height = 240
dx = 0  # overlap on window
dy = 0

while True:
    new_frame_time = time.time()
    success, img = cap.read()
    results = model(img, stream=True)

    p[0] = max(p[0], width/2)   #Stop window from going out of bounds
    p[1] = max(p[1], height / 2)
    p[0] = min(p[0], 1280 - width / 2)
    p[1] = min(p[1], 720 - height / 2)

    a1 = int(p[0] - width/2)
    b1 = int(p[1] - height/2)
    a2 = int(p[0] + width/2)
    b2 = int(p[1] + height/2)  # window corner positions
    window = (a1, b1, a2, b2)
    cv2.rectangle(img, (a1, b1), (a2, b2), (255, 0, 255), 3)  # draws window

    for r in results:
        overlap = False
        boxes = r.boxes
        for box in boxes:
            # Bounding Box
            x1, y1, x2, y2 = box.xyxy[0]
            x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
            # cv2.rectangle(img,(x1,y1),(x2,y2),(255,0,255),3)
            w, h = x2 - x1, y2 - y1
            cvzone.cornerRect(img, (x1, y1, w, h))
            # Confidence
            conf = math.ceil((box.conf[0] * 100)) / 100
            # Class Name
            cls = int(box.cls[0])

            if(((x1 < a2) and (x2 > a1)) and ((y1 < b2) and (y2 > b1))): #Check if there is overlap
                   overlap = True
            else:
                overlap = False

            if(overlap == True):

                if (p[0] <= center[0]):
                    dx = dx + max(0, min(x2, a2) - max(x1, a1))  # Calculate overlap magnitude
                elif (p[0] > center[0]):
                    dx = dx - max(0, min(x2, a2) - max(x1, a1))

                if(p[1] <= center[1]):
                    dy = dy + max(0, min(y2, b2) - max(y1, b1))
                elif (p[1] > center[1]):
                    dy = dy - max(0, min(y2, b2) - max(y1, b1))
                #print(dx, dy)

            cvzone.putTextRect(img, f'{classNames[cls]} {conf}', (max(0, x1), max(35, y1)), scale=1, thickness=1)
    p[0] = int(p[0] + (0.01 * dx))
    p[1] = int(p[0] + (0.01 * dy))


    fps = 1 / (new_frame_time - prev_frame_time)
    prev_frame_time = new_frame_time
    #print(fps)



    cv2.imshow("Image", img)
    cv2.waitKey(100)
