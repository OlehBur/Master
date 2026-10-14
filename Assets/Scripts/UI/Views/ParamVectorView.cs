using System;
using TMPro;
using UnityEngine;


public class ParamVectorView : MonoBehaviour {
    [field: SerializeField] public RectTransform RectTransform { get; private set; }
    [field: SerializeField] public TextMeshProUGUI Title { get; private set; }
    [field: SerializeField] public TMP_InputField InputX { get; private set; }
    [field: SerializeField] public TMP_InputField InputY { get; private set; }
    [field: SerializeField] public TMP_InputField InputZ { get; private set; }

    public event Action<Vector3> OnValueChanged;
    public Vector3 Vector { get; private set; }

    private enum VectorAxis { X, Y, Z };


    private void Awake() {
        InputX.onValueChanged.AddListener((value) => OnValue(VectorAxis.X, value));
        InputY.onValueChanged.AddListener((value) => OnValue(VectorAxis.Y, value));
        InputZ.onValueChanged.AddListener((value) => OnValue(VectorAxis.Z, value));
    }

    public void Init(string title, Vector3 vector) {
        Title.text = title;

        InputX.text = vector.x.ToString(Core.GetDecimalFormat(vector.x));
        InputY.text = vector.y.ToString(Core.GetDecimalFormat(vector.y));
        InputZ.text = vector.z.ToString(Core.GetDecimalFormat(vector.z));
        Vector = vector;
    }

    void OnValue(VectorAxis axis, string value) {
        if (float.TryParse(value, out float number)) {
            if (axis == VectorAxis.X) {
                //InputX.text = number.ToString(Core.GetDecimalFormat(number));
                Vector = new Vector3(number, Vector.y, Vector.z);
            }
            else if (axis == VectorAxis.Y) {
                //InputY.text = value.ToString(Core.GetDecimalFormat(number));
                Vector = new Vector3(Vector.x, number, Vector.z);
            }
            else {
                //InputZ.text = value.ToString(Core.GetDecimalFormat(number));
                Vector = new Vector3(Vector.x, Vector.y, number);
            }

            OnValueChanged?.Invoke(Vector);
        }
    }
}
