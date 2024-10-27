//#if WINDOWS_UWP
using Unity.Barracuda;
using UnityEngine;
using System;
using System.Collections.Generic;

public class ObjectDetection : MonoBehaviour
{
    [SerializeField]
    public NNModel onnxModel;  // Drag and drop your ONNX model into this field in the Inspector
    public float test = 2;
    private IWorker worker;

    private const int InputWidth = 640;
    private const int InputHeight = 640;
    private Texture2D inputTexture;

    // List to keep track of drawn bounding boxes
    private List<LineRenderer> boundingBoxes = new List<LineRenderer>();

    void Start()
    {
        // Load the ONNX model and create a Barracuda worker
        Model model = ModelLoader.Load(onnxModel);
        worker = WorkerFactory.CreateWorker(WorkerFactory.Type.ComputePrecompiled, model);

        // Initialize the input texture (640x640) for resizing camera input
        inputTexture = new Texture2D(InputWidth, InputHeight, TextureFormat.RGBA32, false);
    }

    void Update()
    {
        // Simulate a camera feed by getting pixels from the webcam or other input source
        CaptureCameraInput();

        // Prepare the input tensor by converting the texture to a float array
        float[] inputTensorData = PreprocessImage(inputTexture);

        // Create a Tensor from the preprocessed input data (fix applied here)
        int[] intInputTensorData = Array.ConvertAll(inputTensorData, x => (int)x);
        Tensor inputTensor = new Tensor(1, InputHeight, InputWidth, 3, intInputTensorData);


        // Run the ONNX model using Barracuda
        worker.Execute(inputTensor);

        // Retrieve the outputs from the model
        Tensor outputBoxes = worker.PeekOutput("detection_boxes");  // Bounding boxes
        Tensor outputClasses = worker.PeekOutput("detection_classes");  // Classes
        Tensor outputScores = worker.PeekOutput("detection_scores");  // Confidence scores
        Tensor outputNumDetections = worker.PeekOutput("num_detections");  // Number of detections

        // Process the model's outputs (e.g., draw bounding boxes)
        ProcessOutputs(outputBoxes, outputClasses, outputScores, outputNumDetections);

        // Dispose of the tensor to avoid memory leaks
        inputTensor.Dispose();
        outputBoxes.Dispose();
        outputClasses.Dispose();
        outputScores.Dispose();
        outputNumDetections.Dispose();
    }

    void CaptureCameraInput()
    {
        // Assume the HoloLensCameraCapture component is attached to the same GameObject
        HoloLensCameraCapture cameraCapture = GetComponent<HoloLensCameraCapture>();

        // Retrieve the current camera texture
        Texture2D cameraTexture = cameraCapture.GetCameraTexture();

        // Resize the camera texture to match the model input dimensions (640x640)
        if (cameraTexture != null)
        {
            Graphics.ConvertTexture(cameraTexture, inputTexture);
            inputTexture.Apply();  // Apply the updated pixels to the input texture
        }
    }

    float[] PreprocessImage(Texture2D texture)
    {
        // Get the pixel colors from the texture
        Color[] pixels = texture.GetPixels();
        float[] tensorData = new float[InputWidth * InputHeight * 3];  // 3 channels (RGB)

        for (int i = 0; i < pixels.Length; i++)
        {
            tensorData[i * 3 + 0] = pixels[i].r;  // Red channel
            tensorData[i * 3 + 1] = pixels[i].g;  // Green channel
            tensorData[i * 3 + 2] = pixels[i].b;  // Blue channel
        }

        // Check if tensorData is actually float[] and log an error if it's not
        if (tensorData is float[])
        {
            return tensorData;
        }
        else
        {
            // Log an error if the array is not of type float[]
            Debug.LogError("Error: The tensor data is not of type float[].");
            throw new InvalidOperationException("PreprocessImage did not return a float array.");
        }
    }

    void ProcessOutputs(Tensor boxes, Tensor classes, Tensor scores, Tensor numDetections)
    {
        // Clear any previous bounding boxes
        ClearBoundingBoxes();

        // Get the number of detections (first element of numDetections tensor)
        int detectedCount = (int)numDetections[0];

        for (int i = 0; i < detectedCount; i++)
        {
            float confidence = scores[i];  // Confidence score for each detection

            // Only process detections with high confidence (e.g., > 0.5)
            if (confidence > 0.5f)
            {
                // Extract the bounding box coordinates (in normalized form: values between 0 and 1)
                // Boxes are flattened in a 1D array: ymin, xmin, ymax, xmax in normalized form
                float ymin = boxes[i * 4 + 0];  // Top left y
                float xmin = boxes[i * 4 + 1];  // Top left x
                float ymax = boxes[i * 4 + 2];  // Bottom right y
                float xmax = boxes[i * 4 + 3];  // Bottom right x

                // Convert normalized coordinates to screen coordinates
                DrawBoundingBox(xmin, ymin, xmax, ymax);
            }
        }
    }

    void DrawBoundingBox(float xmin, float ymin, float xmax, float ymax)
    {
        // Create a new GameObject to hold the LineRenderer
        GameObject boxObject = new GameObject("BoundingBox");
        LineRenderer lineRenderer = boxObject.AddComponent<LineRenderer>();

        // Set LineRenderer properties
        lineRenderer.startWidth = 0.01f;
        lineRenderer.endWidth = 0.01f;
        lineRenderer.material = new Material(Shader.Find("Sprites/Default"));
        lineRenderer.startColor = Color.red;
        lineRenderer.endColor = Color.red;

        // Set positions for the bounding box corners
        lineRenderer.positionCount = 5;
        Vector3[] corners = new Vector3[5];
        corners[0] = new Vector3(xmin * Screen.width, (1 - ymin) * Screen.height, 0);  // Top-left
        corners[1] = new Vector3(xmax * Screen.width, (1 - ymin) * Screen.height, 0);  // Top-right
        corners[2] = new Vector3(xmax * Screen.width, (1 - ymax) * Screen.height, 0);  // Bottom-right
        corners[3] = new Vector3(xmin * Screen.width, (1 - ymax) * Screen.height, 0);  // Bottom-left
        corners[4] = new Vector3(xmin * Screen.width, (1 - ymin) * Screen.height, 0);  // Close the box

        lineRenderer.SetPositions(corners);

        // Add the LineRenderer to the list of bounding boxes
        boundingBoxes.Add(lineRenderer);
    }

    void ClearBoundingBoxes()
    {
        // Destroy previous bounding box objects
        foreach (LineRenderer line in boundingBoxes)
        {
            Destroy(line.gameObject);
        }
        boundingBoxes.Clear();
    }

    void OnDestroy()
    {
        // Dispose of the worker when the script is destroyed
        worker.Dispose();
    }
}
//#endif