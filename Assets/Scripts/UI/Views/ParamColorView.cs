using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ParamColorView : MonoBehaviour {
    [field: SerializeField] public RectTransform RectTransform { get; private set; }
    [field: SerializeField] public TextMeshProUGUI Title { get; private set; }
    [field: SerializeField] public Slider R { get; private set; }
    [field: SerializeField] public Slider G { get; private set; }
    [field: SerializeField] public Slider B { get; private set; }
    [field: SerializeField] public TextMeshProUGUI ValueR { get; private set; }
    [field: SerializeField] public TextMeshProUGUI ValueG { get; private set; }
    [field: SerializeField] public TextMeshProUGUI ValueB { get; private set; }
    [field: SerializeField] public Image ColorPreview { get; private set; }

    public Color SelectedColor { get; private set; }
    public event Action<Color> OnValueChanged;

    private enum ColorChannel { R, G, B };


    private void Awake() {
        R.onValueChanged.AddListener((value) => OnValue(ColorChannel.R, value));
        G.onValueChanged.AddListener((value) => OnValue(ColorChannel.G, value));
        B.onValueChanged.AddListener((value) => OnValue(ColorChannel.B, value));
    }

    public void Init(string title, Color color) {
        Title.text = title;
        R.value = color.r;
        G.value = color.g;
        B.value = color.b;
        ValueR.text = color.r.ToString("F2");
        ValueG.text = color.g.ToString("F2");
        ValueB.text = color.b.ToString("F2");
        ColorPreview.color = color;
        SelectedColor = color;
    }

    void OnValue(ColorChannel channel, float value) {
        if (channel == ColorChannel.R) {
            SelectedColor = new Color(value, SelectedColor.g, SelectedColor.b);
            ValueR.text = value.ToString("F2");
        }
        else if (channel == ColorChannel.G) {
            SelectedColor = new Color(SelectedColor.r, value, SelectedColor.b);
            ValueG.text = value.ToString("F2");
        }
        else //if (channel == ColorChannel.B)
            {
            SelectedColor = new Color(SelectedColor.r, SelectedColor.g, value);
            ValueB.text = value.ToString("F2");
        }
        ColorPreview.color = SelectedColor;

        OnValueChanged?.Invoke(SelectedColor);
    }
}
