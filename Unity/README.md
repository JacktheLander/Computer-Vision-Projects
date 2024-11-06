# Configurations
MRTK - make sure MRTK is working properly
webcam - in playersettings/publishsettings/capabilities activate the webcam
Barracuda - install and import barracuda 3.0.0 package extension
Model - download a small object detection model like yolov2n-9 and add it to assets, it should be converted to ONNX model type if it is opset 9 or less and Barracuda is properly configured

# Scripts
Video record script will test camera input and save
Camera Capture and Object Detection will work together to capture camera input, convert tensors, and deploy the object detection model =-> currently stuck debugging compilation of tensor input lines
