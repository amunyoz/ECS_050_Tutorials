using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using TMPro;

public class Fps : MonoBehaviour
{
    public TextMeshPro fpsText;
    public float deltaTime;
    private int Num=0;
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A) ||      Input.GetKeyDown(KeyCode.S)) Num++;
            deltaTime += (Time.deltaTime - deltaTime) * 0.1f;
        float fps = 1.0f / deltaTime;
        fpsText.text =Num + "-- "+ Mathf.Ceil(fps).ToString();
    }
}