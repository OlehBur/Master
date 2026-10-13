using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ParamSliderView : MonoBehaviour {
    [field: SerializeField] public RectTransform RectTransform { get; private set; }
    [field: SerializeField] public TextMeshProUGUI Title { get; private set; }
    [field: SerializeField] public TextMeshProUGUI Value { get; private set; }
    [field: SerializeField] public Slider Slider { get; private set; }

    public event Action<float> OnValueChanged;


    private void Awake() {
        Slider.onValueChanged.AddListener(OnValue);
    }

    public void Init(string title, float initialValue, float maxValue) {
        Title.text = title;
        Value.text = initialValue.ToString(Core.GetDecimalFormat(initialValue));
        Slider.value = initialValue;
        Slider.maxValue = maxValue;
    }

    void OnValue(float value) {
        Value.text = value.ToString(Core.GetDecimalFormat(value));
        OnValueChanged?.Invoke(value);
    }
}
