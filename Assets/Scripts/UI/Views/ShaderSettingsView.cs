using UnityEngine;
using UnityEngine.UI;

public class ShaderSettingsView : MonoBehaviour {
    [field: SerializeField] public RectTransform Content { get; private set; }
    [field: SerializeField] public GameObject Window { get; private set; }
    [field: SerializeField] public VerticalLayoutGroup VerticalLayoutGroup { get; private set; }


    public void SetContentHeight(float height) {
        Vector2 size = Content.sizeDelta;
        size.y = height;
        Content.sizeDelta = size;
    }
}
