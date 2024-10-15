import cv2
import numpy as np
import math

# Define the 8 vertices of a cube (3D coordinates)
cube_points = np.array([
    [-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1],  # Back face
    [-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1]  # Front face
])

# Define the 12 edges of the cube (connected vertices)
cube_edges = [
    (0, 1), (1, 2), (2, 3), (3, 0),  # Back face edges
    (4, 5), (5, 6), (6, 7), (7, 4),  # Front face edges
    (0, 4), (1, 5), (2, 6), (3, 7)  # Connecting edges between front and back faces
]

# Initialize rotation angles
angle_x = 0
angle_y = 0
last_mouse_x = None
last_mouse_y = None


# Mouse callback function to track movement
def mouse_callback(event, x, y, flags, param):
    global angle_x, angle_y, last_mouse_x, last_mouse_y
    if event == cv2.EVENT_MOUSEMOVE:
        if last_mouse_x is not None and last_mouse_y is not None:
            # Calculate change in mouse position
            dx = x - last_mouse_x
            dy = y - last_mouse_y
            # Update rotation angles based on mouse movement
            angle_x += dy * 0.01  # Vertical mouse movement rotates around X-axis
            angle_y += dx * 0.01  # Horizontal mouse movement rotates around Y-axis
        last_mouse_x = x
        last_mouse_y = y


# Function to create rotation matrices
def get_rotation_matrix(angle_x, angle_y):
    # Rotation matrix around X-axis
    Rx = np.array([
        [1, 0, 0],
        [0, math.cos(angle_x), -math.sin(angle_x)],
        [0, math.sin(angle_x), math.cos(angle_x)]
    ])

    # Rotation matrix around Y-axis
    Ry = np.array([
        [math.cos(angle_y), 0, math.sin(angle_y)],
        [0, 1, 0],
        [-math.sin(angle_y), 0, math.cos(angle_y)]
    ])

    return np.dot(Ry, Rx)  # Combine X and Y rotations


# Function to project 3D points to 2D using an orthogonal projection
def project(points, scale, center):
    projection_matrix = np.array([
        [1, 0, 0],
        [0, 1, 0]
    ])
    projected_points = []
    for point in points:
        projected_point = np.dot(projection_matrix, point)
        projected_points.append([int(projected_point[0] * scale + center[0]),
                                 int(projected_point[1] * scale + center[1])])
    return np.array(projected_points)


# Create OpenCV window
window_name = "Mouse-Controlled 3D Rotating Cube"
cv2.namedWindow(window_name)
cv2.setMouseCallback(window_name, mouse_callback)

while True:
    # Create a blank 500x500 image
    img = np.zeros((500, 500, 3), dtype=np.uint8)

    # Get the rotation matrix for the current angles
    rotation_matrix = get_rotation_matrix(angle_x, angle_y)

    # Rotate cube points
    rotated_points = np.dot(cube_points, rotation_matrix.T)

    # Project 3D points to 2D
    projected_points = project(rotated_points, scale=100, center=[250, 250])

    # Draw each edge of the cube
    for edge in cube_edges:
        pt1 = tuple(projected_points[edge[0]])
        pt2 = tuple(projected_points[edge[1]])
        cv2.line(img, pt1, pt2, (255, 255, 255), 2)

    # Show the image in the OpenCV window
    cv2.imshow(window_name, img)

    # Break the loop if 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Clean up and close windows
cv2.destroyAllWindows()
