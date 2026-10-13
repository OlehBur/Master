using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;



public class ShaderReadPropertiesService {
    private readonly Material _terrainMaterial;
    private readonly Material _oceanMaterial;
    private readonly Material _spaceMaterial;

    public ShaderReadPropertiesService(Material spaceMaterial, Material oceanMaterial, Material terrainMaterial) {
        _terrainMaterial = terrainMaterial;
        _oceanMaterial = oceanMaterial;
        _spaceMaterial = spaceMaterial;
    }

    public bool IsMaterialsNoAssigned() =>
          _spaceMaterial == null || _terrainMaterial == null || _oceanMaterial == null
        || _oceanMaterial.shader == null || _spaceMaterial.shader == null || _terrainMaterial.shader == null;

    public void InspectShaderProperties(ShaderType type) {
        if (type == ShaderType.None || IsMaterialsNoAssigned()) {
            Debug.LogError("No material or shader assigned!");
            return;
        }

        Shader shader = GetMaterialByType(type).shader;
        int propertyCount = shader.GetPropertyCount();

        for (int i = 0; i < propertyCount; i++) {
            string propName = shader.GetPropertyName(i);
            string propDesc = shader.GetPropertyDescription(i);
            ShaderPropertyType propType = shader.GetPropertyType(i);

            //check & skip private fields 
            ShaderPropertyFlags flags = shader.GetPropertyFlags(i);
            if ((flags & ShaderPropertyFlags.HideInInspector) != 0)
                continue;

            Debug.Log($"{propDesc} | {propName} | {propType}");

            switch (propType) {
                case ShaderPropertyType.Float:
                float floatVal = _spaceMaterial.GetFloat(propName);
                Debug.Log($"   -> Float: {floatVal}");
                break;

                case ShaderPropertyType.Range:
                float rangeVal = _spaceMaterial.GetFloat(propName);
                Vector2 limits = shader.GetPropertyRangeLimits(i);
                Debug.Log($"   -> Range: {rangeVal} | Available Range: [{limits.x} ... {limits.y}]");
                break;

                case ShaderPropertyType.Color:
                Color colorVal = _spaceMaterial.GetColor(propName);
                Debug.Log($"   -> Color: {colorVal}");
                break;

                case ShaderPropertyType.Vector:
                Vector4 vecVal = _spaceMaterial.GetVector(propName);
                Debug.Log($"   -> Vector: {vecVal}");
                break;

                case ShaderPropertyType.Texture:
                Texture texVal = _spaceMaterial.GetTexture(propName);
                Debug.Log($"   -> Texture: {(texVal != null ? texVal.name : "None")}");
                break;
            }
        }
    }

    public Material GetMaterialByType(ShaderType type) =>
        type switch {
            ShaderType.Terrain => _terrainMaterial,
            ShaderType.Ocean => _oceanMaterial,
            ShaderType.Space => _spaceMaterial,
            _ => null
        };

    public List<ShaderPropertyData> GetProperties(ShaderType type) {
        List<ShaderPropertyData> propertiesList = new List<ShaderPropertyData>();

        if (type == ShaderType.None || IsMaterialsNoAssigned()) {
            Debug.LogError("No material or shader assigned!");
            return propertiesList;
        }

        Material material = GetMaterialByType(type);
        Shader shader = material.shader;
        int propertyCount = shader.GetPropertyCount();

        for (int i = 0; i < propertyCount; i++) {
            ShaderPropertyFlags flags = shader.GetPropertyFlags(i);
            if ((flags & ShaderPropertyFlags.HideInInspector) != 0)
                continue;

            ShaderPropertyData propData = new ShaderPropertyData {
                Name = shader.GetPropertyName(i),
                Description = shader.GetPropertyDescription(i),
                Type = shader.GetPropertyType(i)
            };

            switch (propData.Type) {
                case ShaderPropertyType.Float:
                propData.FloatValue = material.GetFloat(propData.Name);
                break;
                case ShaderPropertyType.Int:
                propData.IntValue = material.GetInteger(propData.Name);
                break;
                case ShaderPropertyType.Range:
                propData.FloatValue = material.GetFloat(propData.Name);
                propData.RangeLimits = shader.GetPropertyRangeLimits(i);
                break;
                case ShaderPropertyType.Color:
                propData.ColorValue = material.GetColor(propData.Name);
                break;
                case ShaderPropertyType.Vector:
                propData.VectorValue = material.GetVector(propData.Name);
                break;
                //case ShaderPropertyType.Texture:
                //propData.TextureValue = targetMaterial.GetTexture(propData.Name);
                //break;
            }

            propertiesList.Add(propData);
        }

        return propertiesList;
    }
}