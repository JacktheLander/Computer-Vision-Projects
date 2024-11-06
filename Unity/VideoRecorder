using UnityEngine;
using UnityEngine.Windows.WebCam;
using System.Collections;

public class VideoRecorder : MonoBehaviour
{
    private VideoCapture videoCapture = null;
    private bool isRecording = false;
    private float recordingTime = 10f; // 10 seconds

    void Start()
    {
        StartVideoCapture();
    }

    private void StartVideoCapture()
    {
        // Initialize video capture
        VideoCapture.CreateAsync(false, OnVideoCaptureCreated);
    }

    private void OnVideoCaptureCreated(VideoCapture captureObject)
    {
        videoCapture = captureObject;

        // Define resolution and frame rate
        Resolution cameraResolution = VideoCapture.SupportedResolutions.GetEnumerator().Current;
        float frameRate = VideoCapture.GetSupportedFrameRatesForResolution(cameraResolution).GetEnumerator().Current;

        // Set video capture parameters
        CameraParameters cameraParameters = new CameraParameters
        {
            hologramOpacity = 0.0f,
            frameRate = frameRate,
            cameraResolutionWidth = cameraResolution.width,
            cameraResolutionHeight = cameraResolution.height,
            pixelFormat = CapturePixelFormat.BGRA32
        };

        // Start video mode
        videoCapture.StartVideoModeAsync(cameraParameters, VideoCapture.AudioState.ApplicationAndMicAudio, OnStartedVideoMode);
    }

    private void OnStartedVideoMode(VideoCapture.VideoCaptureResult result)
    {
        if (result.success)
        {
            string filePath = System.IO.Path.Combine(Application.persistentDataPath, "RecordedVideo.mp4");

            // Start recording video
            videoCapture.StartRecordingAsync(filePath, OnStartedRecording);
        }
        else
        {
            Debug.LogError("Failed to start video mode.");
        }
    }

    private void OnStartedRecording(VideoCapture.VideoCaptureResult result)
    {
        if (result.success)
        {
            Debug.Log("Started recording video...");
            isRecording = true;

            // Stop recording after a delay
            StartCoroutine(StopRecordingAfterDelay());
        }
        else
        {
            Debug.LogError("Failed to start recording video.");
        }
    }

    private IEnumerator StopRecordingAfterDelay()
    {
        yield return new WaitForSeconds(recordingTime);

        if (isRecording)
        {
            videoCapture.StopRecordingAsync(OnStoppedRecording);
        }
    }

    private void OnStoppedRecording(VideoCapture.VideoCaptureResult result)
    {
        if (result.success)
        {
            Debug.Log("Stopped recording video.");
            videoCapture.StopVideoModeAsync(OnStoppedVideoMode);
        }
        else
        {
            Debug.LogError("Failed to stop recording video.");
        }
    }

    private void OnStoppedVideoMode(VideoCapture.VideoCaptureResult result)
    {
        if (result.success)
        {
            videoCapture.Dispose();
            videoCapture = null;
            Debug.Log("Video capture mode stopped.");
        }
        else
        {
            Debug.LogError("Failed to stop video capture mode.");
        }
    }
}
