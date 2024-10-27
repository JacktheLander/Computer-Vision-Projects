using UnityEngine;
#if ENABLE_WINMD_SUPPORT
using Windows.Media.Capture;
using Windows.Media.Core;
using Windows.Media.MediaProperties;
using Windows.Media.Capture.Frames;
using Windows.Graphics.Imaging;
#endif
using System;  // For Task extensions
using System.Threading.Tasks;
using System.Runtime.InteropServices.WindowsRuntime;


public class HoloLensCameraCapture : MonoBehaviour
{
    private MediaCapture mediaCapture;
    private MediaFrameReader frameReader;
    private bool isCapturing;
    private Texture2D cameraTexture;

    async void Start()
    {
        await InitializeCamera();
    }

    private async Task InitializeCamera()
    {
        // Create a MediaCapture object
        mediaCapture = new MediaCapture();
        var settings = new MediaCaptureInitializationSettings
        {
            StreamingCaptureMode = StreamingCaptureMode.Video,
            MemoryPreference = MediaCaptureMemoryPreference.Cpu
        };

        // Use AsTask() to properly handle await for IAsyncAction
        await mediaCapture.InitializeAsync(settings).AsTask();

        // Select the video source
        var frameSource = mediaCapture.FrameSources.Values.GetEnumerator();
        frameSource.MoveNext();  // Get the first available source (color camera)

        // Create a frame reader for the video source (use Current directly)
        frameReader = await mediaCapture.CreateFrameReaderAsync(frameSource.Current);

        // Use AsTask() for IAsyncOperation as well
        await frameReader.StartAsync().AsTask();
        isCapturing = true;
    }

    private void FrameReader_FrameArrived(MediaFrameReader sender, MediaFrameArrivedEventArgs args)
    {
        if (!isCapturing)
            return;

        // Get the most recent frame
        var frame = sender.TryAcquireLatestFrame();
        if (frame != null)
        {
            using (var videoFrame = frame.VideoMediaFrame?.GetVideoFrame())
            {
                if (videoFrame != null)
                {
                    // Get the SoftwareBitmap from the video frame
                    var bitmap = videoFrame.SoftwareBitmap;
                    if (bitmap != null && bitmap.BitmapPixelFormat == BitmapPixelFormat.Bgra8)
                    {
                        // Convert the SoftwareBitmap to Texture2D
                        cameraTexture = new Texture2D(bitmap.PixelWidth, bitmap.PixelHeight, TextureFormat.BGRA32, false);
                        ConvertSoftwareBitmapToTexture(bitmap, cameraTexture);
                    }
                }
            }
        }
    }

    private void ConvertSoftwareBitmapToTexture(SoftwareBitmap bitmap, Texture2D texture)
    {
        // Copy the SoftwareBitmap data into the Texture2D
        var buffer = new byte[4 * bitmap.PixelWidth * bitmap.PixelHeight];
        bitmap.CopyToBuffer(buffer.AsBuffer());
        texture.LoadRawTextureData(buffer);
        texture.Apply();
    }

    private void OnDestroy()
    {
        if (frameReader != null)
        {
            frameReader.FrameArrived -= FrameReader_FrameArrived;
            frameReader.Dispose();
        }

        if (mediaCapture != null)
        {
            mediaCapture.Dispose();
        }
    }

    public Texture2D GetCameraTexture()
    {
        return cameraTexture;
    }
}
//#endif
