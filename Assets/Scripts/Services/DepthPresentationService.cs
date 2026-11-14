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

    private const int INIT_ANIM_SHORT_DELAY = 1000;
    private const int INIT_ANIM_DELAY = 3000;
    private const float POLYDEPTH_PROG_SPEED = 1f;
    private const float RAYMARCH_DEPTH_PROG_SPEED = .3f;
    private const float RAYMARCH_FIN_PROG_SPEED = .5f;

    static readonly int POLYDEPTH_PROGRESS = Shader.PropertyToID("_Progress");
    static readonly int RAYMARCH_DEPTH_APPER = Shader.PropertyToID("_DepthAllAppear");
    static readonly int RAYMARCH_DEPTH_POLY_COLORING = Shader.PropertyToID("_DepthPolyColoring");
    static readonly int RAYMARCH_DEPHT_ALL_COLORING = Shader.PropertyToID("_DepthRaymarchColoring");
    static readonly int RAYMARCH_SHADOWS = Shader.PropertyToID("_TerrainShadows");


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
            float raymarchDepthAppear = 0f;
            float raymarchDepthPolyColoring = 0f;
            float terrainDepthAllColoring = 0f;
            float terrainShading = 0f;
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, polyProg);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_APPER, raymarchDepthAppear);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_POLY_COLORING , raymarchDepthPolyColoring);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPHT_ALL_COLORING, terrainDepthAllColoring);
            _terrainCloudsMarch.SetFloat(RAYMARCH_SHADOWS, terrainShading);
            _shaderpassService.ActivateShader(ShaderType.PolyDepth);

            //poly depth appear
            while (polyProg < 1f) {
                polyProg += Time.deltaTime * POLYDEPTH_PROG_SPEED;
                _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, polyProg);
                await Task.Yield();
            }
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, 1f);      
            await Task.Delay(INIT_ANIM_DELAY);

            //poly depth disappear
            while (polyProg > 0f) {
                polyProg -= Time.deltaTime * POLYDEPTH_PROG_SPEED;
                _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, polyProg);
                await Task.Yield();
            }
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, 0f);
            await Task.Delay(INIT_ANIM_SHORT_DELAY);

            //rayrmarch + poly depth appear
            _shaderpassService.ActivateShader(ShaderType.Terrain);
            while (raymarchDepthAppear < 1f) {
                raymarchDepthAppear += Time.deltaTime * RAYMARCH_DEPTH_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_APPER, raymarchDepthAppear);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_APPER, 1f);
            await Task.Delay(INIT_ANIM_DELAY);

            //poly coloring appear
            while (raymarchDepthPolyColoring < 1f) {
                raymarchDepthPolyColoring += Time.deltaTime * RAYMARCH_FIN_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_POLY_COLORING, raymarchDepthPolyColoring);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_POLY_COLORING, 1f);
            await Task.Delay(INIT_ANIM_DELAY);

            //raymarch poly coloring appear
            while (terrainDepthAllColoring < 1f) {
                terrainDepthAllColoring += Time.deltaTime * RAYMARCH_FIN_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_DEPHT_ALL_COLORING, terrainDepthAllColoring);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPHT_ALL_COLORING, 1f);
            await Task.Delay(INIT_ANIM_DELAY);

            //raymarch poly coloring appear
            while (terrainShading < 1f) {
                terrainShading += Time.deltaTime * RAYMARCH_FIN_PROG_SPEED;
                _terrainCloudsMarch.SetFloat(RAYMARCH_SHADOWS, terrainShading);
                await Task.Yield();
            }
            _terrainCloudsMarch.SetFloat(RAYMARCH_SHADOWS, 1f);

        }
        catch (OperationCanceledException op) { 
            Debug.LogError(op.Message);
        }
        finally {
            _polyDepthMat.SetFloat(POLYDEPTH_PROGRESS, 1f);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_APPER, 1f);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPTH_POLY_COLORING, 1f);
            _terrainCloudsMarch.SetFloat(RAYMARCH_DEPHT_ALL_COLORING, 1f);
        }
    }
}