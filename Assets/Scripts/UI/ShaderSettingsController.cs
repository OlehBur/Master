using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using VContainer;

public class ShaderSettingsController : MonoBehaviour {
    [SerializeField] ShaderBlankView terrainSettingsWnd;
    [SerializeField] ShaderBlankView oceanSettingsWnd;
    [SerializeField] ShaderBlankView spaceSettingsWnd;

    [SerializeField] GameObject floatParamPrefab;
    [SerializeField] GameObject rangeParamPrefab;
    [SerializeField] GameObject colorParamPrefab;
    [SerializeField] GameObject vectorParamPrefab;
    [SerializeField] GameObject sliderParamPrefab;
    [SerializeField] GameObject integerParamPrefab;

    private ShaderReadPropertiesService _shaderReadPropService;
    private Dictionary<ShaderType, bool> isSettingsParamsInited = new();

    [Inject]
    public void Construct(ShaderReadPropertiesService shaderService) {
        _shaderReadPropService = shaderService;
    }

    private void OnEnable() {
        SelectAndOpenMaterialWindow(ShaderType.Terrain);
    }

    public void SelectAndOpenMaterialWindow(ShaderType shaderType) {
        ShaderBlankView settingsSubWnd = GetWindowByType(shaderType);

        if (isSettingsParamsInited.ContainsKey(shaderType) && isSettingsParamsInited[shaderType]) {
            settingsSubWnd.Window.SetActive(true);
            return;
        }

        List<ShaderPropertyData> properties = _shaderReadPropService.GetProperties(shaderType);
        Material material = _shaderReadPropService.GetMaterialByType(shaderType);
        //// clear old ui
        //foreach (Transform child in contentParentTerrain) {
        //    Destroy(child.gameObject);
        //}

        //new params
        float currentWndHeight = 60f;
        foreach (ShaderPropertyData prop in properties) {
            GameObject paramObj = CreateParamObj(shaderType, prop.Type, settingsSubWnd.Content, prop.RangeLimits);

            if (prop.Type == ShaderPropertyType.Float
                && paramObj.TryGetComponent(out ParamFloatView floatView)) {

                currentWndHeight += floatView.RectTransform.sizeDelta.y;
                floatView.Init(prop.Description, prop.FloatValue);
                floatView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Range && prop.RangeLimits.x == 0
                && paramObj.TryGetComponent(out ParamSliderView sliderView)) {

                currentWndHeight += sliderView.RectTransform.sizeDelta.y;
                sliderView.Init(prop.Description, prop.FloatValue, prop.RangeLimits.y);
                sliderView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Range
                && paramObj.TryGetComponent(out ParamRangeView rangeView)) {

                currentWndHeight += rangeView.RectTransform.sizeDelta.y;
                rangeView.Init(prop.Description, prop.FloatValue, prop.RangeLimits.x, prop.RangeLimits.y);
                rangeView.OnValueChanged += val => material.SetFloat(prop.Name, val);
            }
            else if (prop.Type == ShaderPropertyType.Color
                && paramObj.TryGetComponent(out ParamColorView colorView)) {

                currentWndHeight += colorView.RectTransform.sizeDelta.y;
                colorView.Init(prop.Description, prop.ColorValue);
                colorView.OnValueChanged += val => material.SetColor(prop.Name, val);
            }
            //int, texture
        }

        settingsSubWnd.SetContentHeight(currentWndHeight);
        isSettingsParamsInited.Add(shaderType, true);
        settingsSubWnd.Window.SetActive(true);
    }

    GameObject CreateParamObj(ShaderType shader, ShaderPropertyType property, Transform paramsParent, Vector2 rangeLimits = default) {
        //Transform paramsParent = GetWindowByType(shader).Content;//GetParentByType(shader);
        GameObject prefab = GetParamPrefab(property, rangeLimits);

        return Instantiate(prefab, paramsParent);
    }

    GameObject GetParamPrefab(ShaderPropertyType propType, Vector2 rangeLimits = default) =>
        propType switch {
            ShaderPropertyType.Range => rangeLimits.x == 0f ?
            sliderParamPrefab : rangeParamPrefab,
            ShaderPropertyType.Float => floatParamPrefab,
            ShaderPropertyType.Color => colorParamPrefab,
            ShaderPropertyType.Vector => vectorParamPrefab,
            ShaderPropertyType.Int => integerParamPrefab,
            _ => null
        };

    ShaderBlankView GetWindowByType(ShaderType type) =>
        type switch {
            ShaderType.Terrain => terrainSettingsWnd,
            ShaderType.Ocean => oceanSettingsWnd,
            ShaderType.Space => spaceSettingsWnd,
            _ => null
        };

    //GameObject GetWindowByType(ShaderType type) =>
    //    type switch {
    //        ShaderType.Terrain => terrainSettingsWnd.gameObject,
    //        ShaderType.Ocean => oceanSettingsWnd.gameObject,
    //        ShaderType.Space => spaceSettingsWnd.gameObject,
    //        _ => null
    //    };

    //Transform GetParentByType(ShaderType shaderType) =>
    //            shaderType switch {
    //                ShaderType.Terrain => terrainSettingsWnd.Content,
    //                ShaderType.Ocean => oceanSettingsWnd.Content,
    //                ShaderType.Space => spaceSettingsWnd.Content,
    //                _ => null
    //            };

}
