using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering;
using VContainer;


public interface ISettingsWndService : IWndService {
    //event Action<ShaderType> OnShaderChanged;
    void ToggleWnd(ShaderType type);
}

public class ShaderSettingsController : MonoBehaviour, ISettingsWndService {
    [SerializeField] ShaderSettingsView terrainSettings;
    [SerializeField] ShaderSettingsView oceanSettings;
    [SerializeField] ShaderSettingsView spaceSettings;
    [SerializeField] GameObject settingsParentWnd;

    [SerializeField] GameObject floatParamPrefab;
    [SerializeField] GameObject rangeParamPrefab;
    [SerializeField] GameObject colorParamPrefab;
    [SerializeField] GameObject vectorParamPrefab;
    [SerializeField] GameObject sliderParamPrefab;
    [SerializeField] GameObject integerParamPrefab;
    [SerializeField] GameObject headerPrefab;

    private ShaderPropertiesService _shaderPropService;
    private IShaderpassService _shaderPassService;
    private Dictionary<ShaderType, bool> _isSettingsParamsInited = new();
    private GameObject _currentOpenSettingsSubWindow = null;

    public bool IsOpen => _currentOpenSettingsSubWindow != null;
    public event Action<bool> OnStateChanged;
    //public event Action<ShaderType> OnShaderChanged;

    [Inject]
    public void Construct(ShaderPropertiesService shaderPropService, IShaderpassService shaderPassService) {
        _shaderPropService = shaderPropService;
        _shaderPassService = shaderPassService;
    }

    //public void OnOpenTerrainWnd() => OpenSubWndHandle(ShaderType.Terrain);
    //public void OnOpenOceanWnd() => OpenSubWndHandle(ShaderType.Ocean);
    //public void OnOpenSpaceWnd() => OpenSubWndHandle(ShaderType.Space);

    public void OnResetShader() =>
        _shaderPropService.ResetPropertiesToDefault(_shaderPassService.CurrentShader);

    void OpenSubWndHandle(ShaderType shaderType) {
        ShaderSettingsView settingsSubWnd = GetWindowByType(shaderType);

        settingsParentWnd.SetActive(true);
        if (!IsSettingsSubWindowCreated(shaderType)) {
            BuildWindow(shaderType, settingsSubWnd);
            _isSettingsParamsInited.Add(shaderType, true);
        }

        _currentOpenSettingsSubWindow = settingsSubWnd.Window;
        _currentOpenSettingsSubWindow.SetActive(true);
    }

    public void ToggleWnd(ShaderType type) {
        if (type == ShaderType.None)
            return;

        if (IsOpen) {
            settingsParentWnd.SetActive(false);
            _currentOpenSettingsSubWindow.SetActive(false);
            _currentOpenSettingsSubWindow = null;
            OnStateChanged?.Invoke(false);
        }
        else {
            if (type == ShaderType.Terrain)
                OpenSubWndHandle(ShaderType.Terrain);
            else if (type == ShaderType.Ocean)
                OpenSubWndHandle(ShaderType.Ocean);
            else
                OpenSubWndHandle(ShaderType.Space);

            OnStateChanged?.Invoke(true);
        }
    }

    bool IsSettingsSubWindowCreated(ShaderType shaderType)
       => _isSettingsParamsInited.ContainsKey(shaderType) && _isSettingsParamsInited[shaderType];

    void BuildWindow(ShaderType shaderType, ShaderSettingsView shaderSettingsView) {
        List<ShaderPropertyData> properties = _shaderPropService.GetProperties(shaderType);
        Material material = _shaderPropService.GetMaterialByType(shaderType);

        //new params
        float offset = shaderSettingsView.VerticalLayoutGroup.spacing;
        float currentWndHeight = shaderSettingsView.VerticalLayoutGroup.padding.top + shaderSettingsView.VerticalLayoutGroup.padding.bottom + offset * 2;
        foreach (ShaderPropertyData prop in properties) {
            GameObject paramObj = CreateParamObj(shaderType, prop.Type, shaderSettingsView.Content, prop.RangeLimits, prop.IsHeader);

            if (prop.IsHeader && paramObj.TryGetComponent(out TextMeshProUGUI textView)) {

                currentWndHeight += textView.rectTransform.sizeDelta.y + offset;
                textView.text = prop.Description;
            }
            else if (prop.Type == ShaderPropertyType.Float
                && paramObj.TryGetComponent(out ParamFloatView floatView)) {

                currentWndHeight += floatView.RectTransform.sizeDelta.y + offset;
                floatView.Init(prop.Description, prop.FloatValue);
                floatView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Range && prop.RangeLimits.x == 0
                && paramObj.TryGetComponent(out ParamSliderView sliderView)) {

                currentWndHeight += sliderView.RectTransform.sizeDelta.y + offset;
                sliderView.Init(prop.Description, prop.FloatValue, prop.RangeLimits.y);
                sliderView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Range
                && paramObj.TryGetComponent(out ParamRangeView rangeView)) {

                currentWndHeight += rangeView.RectTransform.sizeDelta.y + offset;
                rangeView.Init(prop.Description, prop.FloatValue, prop.RangeLimits.x, prop.RangeLimits.y);
                rangeView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Color
                && paramObj.TryGetComponent(out ParamColorView colorView)) {

                currentWndHeight += colorView.RectTransform.sizeDelta.y + offset;
                colorView.Init(prop.Description, prop.ColorValue);
                colorView.OnValueChanged += val => material.SetColor(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Vector
                && paramObj.TryGetComponent(out ParamVectorView vectorView)) {

                currentWndHeight += vectorView.RectTransform.sizeDelta.y + offset;
                vectorView.Init(prop.Description, prop.VectorValue);
                vectorView.OnValueChanged += val => material.SetVector(prop.Name, val);
                //int, texture
            }
        }

        shaderSettingsView.SetContentHeight(currentWndHeight);
    }

    GameObject CreateParamObj(ShaderType shader, ShaderPropertyType property, Transform paramsParent, Vector2 rangeLimits = default, bool isHeader = false) {
        GameObject prefab = GetParamPrefab(property, rangeLimits, isHeader);

        return Instantiate(prefab, paramsParent);
    }

    GameObject GetParamPrefab(ShaderPropertyType propType, Vector2 rangeLimits = default, bool isHeader = false) =>
        propType switch {
            ShaderPropertyType.Range => rangeLimits.x == 0f ?
            sliderParamPrefab : rangeParamPrefab,
            ShaderPropertyType.Float => isHeader ?
            headerPrefab : floatParamPrefab,
            ShaderPropertyType.Color => colorParamPrefab,
            ShaderPropertyType.Vector => vectorParamPrefab,
            ShaderPropertyType.Int => integerParamPrefab,
            _ => null
        };

    ShaderSettingsView GetWindowByType(ShaderType type) =>
        type switch {
            ShaderType.Terrain => terrainSettings,
            ShaderType.Ocean => oceanSettings,
            ShaderType.Space => spaceSettings,
            _ => null
        };
}
