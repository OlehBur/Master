using UnityEngine;
using TMPro;
using System;


public class ParamFloatView : MonoBehaviour {
    [field: SerializeField] public RectTransform RectTransform { get; private set; }
    [field: SerializeField] public TextMeshProUGUI Title { get; private set; }
    [field: SerializeField] public TMP_InputField Input { get; private set; }

    public event Action<float> OnValueChanged;


    private void Awake() {
        Input.onValueChanged.AddListener(OnValue);
    }

    public void Init(string title, float initialValue) {
        Title.text = title;
        Input.text = initialValue.ToString(Core.GetDecimalFormat(initialValue));
    }

    void OnValue(string value) {
        if (float.TryParse(value, out float r))
            OnValueChanged?.Invoke(r);
    }
}
