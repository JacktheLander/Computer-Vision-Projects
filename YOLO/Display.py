# An AR system for smart image overlap reduction in augmented displays - making a display window that won't cover people when you look at them.

import cv2
import numpy as np
from ultralytics import YOLO

# Load the YOLOv8 model (YOLOv8n is the nano version for speed)
model = YOLO("yolov8n.pt")

cap = cv2.VideoCapture("video.mp4")

# Parameters
movement_speed = 0.05  # How quickly the box moves and resizes (smoothing factor)
min_box_scale = 0.2  # Minimum scale (relative to frame size) for the box

# Function to check if two boxes overlap
def boxes_overlap(box1, box2):
    x1, y1, w1, h1 = box1
    x2, y2, w2, h2 = box2
    # Check if one box is completely to the left, right, above, or below the other
    if x1 + w1 < x2:  # Box1 is completely to the left of Box2
        return False
    if x1 > x2 + w2:  # Box1 is completely to the right of Box2
        return False
    if y1 + h1 < y2:  # Box1 is completely above Box2
        return False
    if y1 > y2 + h2:  # Box1 is completely below Box2
        return False
    return True

# Start with the box centered and the largest possible size
target_box_width = 0  # To be determined based on frame size
target_box_height = 0
target_box_x = 0
target_box_y = 0

# Initialize current box size and position (this will change frame by frame)
current_box_x = 0
current_box_y = 0
current_box_width = 0
current_box_height = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    height, width, _ = frame.shape  # Frame dimensions

    # Calculate the largest 16:9 box that fits in the frame centered
    aspect_ratio = 16 / 9
    max_box_width = width * 0.9  # 90% of the frame width
    max_box_height = max_box_width / aspect_ratio

    if max_box_height > height * 0.9:  # Ensure the box height fits within the frame
        max_box_height = height * 0.9
        max_box_width = max_box_height * aspect_ratio

    # Set target box at the center and the largest possible size
    target_box_x = int((width - max_box_width) / 2)
    target_box_y = int((height - max_box_height) / 2)
    target_box_width = int(max_box_width)
    target_box_height = int(max_box_height)

    # Run YOLOv8 inference on the frame
    results = model(frame)

    # Extract detection data (bounding boxes, confidences, class labels)
    people_boxes = []
    for result in results:
        boxes = result.boxes.xyxy  # Bounding box coordinates (x1, y1, x2, y2)
        class_ids = result.boxes.cls  # Class IDs

        # Store the bounding boxes for detected people
        for i in range(len(boxes)):
            if int(class_ids[i]) == 0:  # Class ID '0' is for 'person'
                x1, y1, x2, y2 = map(int, boxes[i])
                w, h = x2 - x1, y2 - y1
                people_boxes.append([x1, y1, w, h])

    # Check if the **current box** overlaps with any detected person
    for person_box in people_boxes:
        if boxes_overlap([current_box_x, current_box_y, current_box_width, current_box_height], person_box):
            # Calculate how to move the **target** box to move away from the overlap smoothly
            person_center_x = person_box[0] + person_box[2] // 2
            person_center_y = person_box[1] + person_box[3] // 2
            box_center_x = current_box_x + current_box_width // 2
            box_center_y = current_box_y + current_box_height // 2

            # Move the box horizontally away from the person
            if person_center_x < box_center_x:  # Person is to the left of the box
                target_box_x += int(movement_speed * (box_center_x - person_center_x) * 20)
            else:  # Person is to the right of the box
                target_box_x -= int(movement_speed * (person_center_x - box_center_x) * 20)

            # Move the box vertically away from the person
            if person_center_y < box_center_y:  # Person is above the box
                target_box_y += int(movement_speed * (box_center_y - person_center_y) * 20)
            else:  # Person is below the box
                target_box_y -= int(movement_speed * (person_center_y - box_center_y) * 20)

            # Shrink the **target** box size
            target_box_width *= (1 - movement_speed)
            target_box_height = target_box_width / aspect_ratio

            # Ensure the box doesn't get too small
            min_width = width * min_box_scale
            if target_box_width < min_width:
                target_box_width = min_width
                target_box_height = target_box_width / aspect_ratio

            # Ensure the **target** box stays within the screen boundaries
            target_box_x = max(0, min(target_box_x, width - target_box_width))
            target_box_y = max(0, min(target_box_y, height - target_box_height))

    # Smooth transition for the **current** box position and size
    current_box_x = int(current_box_x + movement_speed * (target_box_x - current_box_x))
    current_box_y = int(current_box_y + movement_speed * (target_box_y - current_box_y))
    current_box_width = int(current_box_width + movement_speed * (target_box_width - current_box_width))
    current_box_height = int(current_box_height + movement_speed * (target_box_height - current_box_height))

    # Draw bounding boxes for detected people
    for person_box in people_boxes:
        x, y, w, h = person_box
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        cv2.putText(frame, "Person", (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    # Draw the 16:9 box (centered or moved away from overlap)
    cv2.rectangle(frame, (current_box_x, current_box_y),
                  (current_box_x + current_box_width, current_box_y + current_box_height),
                  (255, 0, 0), 2)

    # Resize the frame to half the size for display
    frame_resized = cv2.resize(frame, (frame.shape[1] // 2, frame.shape[0] // 2))

    # Display the resized frame
    cv2.imshow("YOLOv8 Person Detection with Moving Box", frame_resized)

    # Break loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release video capture and close windows
cap.release()
cv2.destroyAllWindows()
