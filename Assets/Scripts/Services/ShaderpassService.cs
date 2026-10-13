using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;


public interface IShaderpassService {
    ShaderType CurrentShader { get; }
    event Action<ShaderType> OnShaderChanged;
    void ActivateShader(ShaderType type);
    void DisableAllPasses();
    float GetOceanLevel();
}

public class ShaderpassService : IShaderpassService {
    private readonly UniversalRendererData _rendererData;
    private readonly Material _oceanMaterial;

    public ShaderType CurrentShader { get; private set; } = ShaderType.None;
    public bool IsMainMenuActive = false;
    public event Action<ShaderType> OnShaderChanged;

    private const string TERRAIN_FEATURE_NAME = "Terrain";
    private const string OCEAN_FEATURE_NAME = "Ocean";
    private const string SPACE_FEATURE_NAME = "Space";

    private static readonly int OCEAN_LEVEL_ID = Shader.PropertyToID("_SeaLevel");


    public ShaderpassService(UniversalRendererData rendererData, Material oceanMaterial) {
        _rendererData = rendererData;
        _oceanMaterial = oceanMaterial;
    }

    public void ActivateShader(ShaderType type) {
        CurrentShader = type;
        DisableAllPasses();

        string featureName = GetFeatureName(type);
        ToggleFeatureByName(featureName, true);

        OnShaderChanged?.Invoke(CurrentShader);
    }

    public float GetOceanLevel() {
        if (_oceanMaterial != null && _oceanMaterial.HasProperty(OCEAN_LEVEL_ID))
            return _oceanMaterial.GetFloat(OCEAN_LEVEL_ID);

        return 0f;
    }

    string GetFeatureName(ShaderType type) =>
        type switch {
            ShaderType.Terrain => TERRAIN_FEATURE_NAME,
            ShaderType.Ocean => OCEAN_FEATURE_NAME,
            ShaderType.Space => SPACE_FEATURE_NAME,
            _ => TERRAIN_FEATURE_NAME
        };

    public void ToggleFeatureByName(string featureName, bool enable) {
        if (_rendererData == null)
            return;

        foreach (var feature in _rendererData.rendererFeatures) {
            if (feature != null && feature.name == featureName)
                feature.SetActive(enable);
        }
    }

    public void DisableAllPasses() {
        if (_rendererData == null)
            return;

        foreach (var feature in _rendererData.rendererFeatures) {
            if (feature is FullScreenPassRendererFeature fullScreenFeature)
                fullScreenFeature.SetActive(false);
        }
    }
}
