using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FPSCounter : MonoBehaviour
{
    public Text fpsDisplay;
    public Text averageFPSDisplay;
    int framesPassed = 0;
    float fpsTotal = 0f;
    public Text minFPSDisplay, maxFPSDisplay;
    float minFPS = Mathf.Infinity;
    float maxFPS = 0f;

    void Start() {
        Application.targetFrameRate = 180;
    }

    void Update() {
        float fps = 1 / Time.unscaledDeltaTime;
        fpsDisplay.text = "" + fps;

        fpsTotal += fps;
        framesPassed++;
        averageFPSDisplay.text = "" + (fpsTotal / framesPassed);

        if (fps > maxFPS && framesPassed > 10) {
            maxFPS = fps;
            maxFPSDisplay.text = "Max: " + maxFPS;
        }
        if (fps < minFPS && framesPassed > 10) {
            minFPS = fps;
            minFPSDisplay.text = "Min: " + minFPS;
        }
    }

}
