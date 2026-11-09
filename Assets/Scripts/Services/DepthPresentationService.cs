using System;
using System.Threading.Tasks;
using UnityEngine;
using VContainer;


public interface IDepthPresentationService {
    void StartPresentation();
}

public class DepthPresentationService : IDepthPresentationService {
    private readonly Material _polyDepthMat;
    private readonly Material _terrainCloudsMarch;
    private readonly IShaderpassService _shaderpassService;

    private const int INIT_ANIM_DELAY = 3000;
    private const float POLYDEPTH_PROG_SPEED = .2f;
    private const float RAYMARCH_DEPTH_PROG_SPEED = .3f;
    private const float RAYMARCH_FIN_PROG_SPEED = .5f;

    static readonly int POLYDEPTH_PROGRESS = Shader.PropertyToID("_Progress");
    static readonly int RAYMARCH_DEPTHMARCH = Shader.PropertyToID("_DebugRaymarchDepth");
    static readonly int RAYMARCH_FINAL = Shader.PropertyToID("_DebugCombined");


    [Inject]
    public DepthPresentationService(Material polyDepthMat, Material terrainCloudsMarch, IShaderpassService shaderpassService) {
        _polyDepthMat = polyDepthMat;
        _terrainCloudsMarch = terrainCloudsMarch;
        _shaderpassService = shaderpassService;
    }

    public void StartPresentation() =>
        _ = DepthShadersAnimations();

    async Task DepthShadersAnimations() {
        try {
            await Task.Delay(INIT_ANIM_DELAY);

            float polyProg = 0f;
            float terrainMarchProg = 1f;
            float terrainFinProg = 1f;
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, polyProg);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTHMARCH, terrainMarchProg);
            _terrainCloudsMarch.SetFloat(RAYMARCH_FINAL, terrainFinProg);
            _shaderpassService.ActivateShader(ShaderType.PolyDepth);

            while (polyProg < 1f) {
                polyProg += Time.deltaTime * POLYDEPTH_PROG_SPEED;
                _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, polyProg);
                await Task.Yield();
            }
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, 1f);
            _shaderpassService.ActivateShader(ShaderType.Terrain);

            while (terrainMarchProg > 0f) {
                terrainMarchProg -= Time.deltaTime * RAYMARCH_DEPTH_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTHMARCH, terrainMarchProg);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTHMARCH, 0f);

            while (terrainFinProg > 0f) {
                terrainFinProg -= Time.deltaTime * RAYMARCH_FIN_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_FINAL, terrainFinProg);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_FINAL, 0f);
        }
        catch (OperationCanceledException op) { 
            Debug.LogError(op.Message);
        }
        finally {
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, 1f);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTHMARCH, 0f);
            _terrainCloudsMarch.SetFloat(RAYMARCH_FINAL, 0f);
        }
    }
}