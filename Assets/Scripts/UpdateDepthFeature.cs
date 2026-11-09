using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Experimental.Rendering;

public class UpdateDepthFeature : ScriptableRendererFeature {
    class UpdateDepthPass : ScriptableRenderPass {
        private Material _copyDepthMaterial;

        public UpdateDepthPass(RenderPassEvent rpe) {
            renderPassEvent = rpe;
            Shader shader = Shader.Find("Hidden/Universal Render Pipeline/CopyDepth");
            if (shader != null) {
                _copyDepthMaterial = new Material(shader);
            }
            else {
                Debug.LogError("UpdateDepthFeature: Не знайдено шейдер копіювання глибини!");
            }
        }

        class PassTxtrData {
            public TextureHandle sourceDepth;
            public TextureHandle destDepth;
            public Material shaderMat;
            public TextureHandle colorTarget;
        }

        public override void RecordRenderGraph(RenderGraph rg, ContextContainer cc) {
            if (_copyDepthMaterial == null)
                return;

            UniversalResourceData resourceData = cc.Get<UniversalResourceData>();
            UniversalCameraData cameraData = cc.Get<UniversalCameraData>();

            TextureHandle sourceDepth = resourceData.activeDepthTexture;
            if (!sourceDepth.IsValid())
                return;

            RenderTextureDescriptor camDesc = cameraData.cameraTargetDescriptor;
            TextureDesc desc = new TextureDesc(camDesc.width, camDesc.height) {
                colorFormat = GraphicsFormat.None,
                depthBufferBits = DepthBits.Depth32,
                msaaSamples = MSAASamples.None,
                name = "_UpdatedCameraDepthTexture",
                clearBuffer = false
            };

            TextureHandle copiedDepth = rg.CreateTexture(desc);

            // прохід Запису глибини у кастомну текстуру 
            using (var builder = rg.AddRasterRenderPass<PassTxtrData>("Update Camera Depth - Write", out var passData)) {
                passData.sourceDepth = sourceDepth;
                passData.destDepth = copiedDepth;
                passData.shaderMat = _copyDepthMaterial;

                builder.UseTexture(sourceDepth, AccessFlags.Read);
                builder.SetRenderAttachmentDepth(copiedDepth, AccessFlags.Write);
                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassTxtrData data, RasterGraphContext context) => {
                    Blitter.BlitTexture(context.cmd, data.sourceDepth, new Vector4(1, 1, 0, 0), data.shaderMat, 0);
                });
            }

            // прохід Безпечного оновлення глобального стану текстури
            using (var builder = rg.AddRasterRenderPass<PassTxtrData>("Update Camera Depth - Set Global", out var passData)) {
                passData.destDepth = copiedDepth;
                passData.colorTarget = resourceData.activeColorTexture;

                builder.UseTexture(copiedDepth, AccessFlags.Read);// текстура вже записана, чит. її безпечно
                builder.SetRenderAttachment(resourceData.activeColorTexture, 0);//юз існуючого колір буферу

                builder.AllowPassCulling(false);
                builder.AllowGlobalStateModification(true);

                builder.SetRenderFunc((PassTxtrData data, RasterGraphContext context) => {
                    context.cmd.SetGlobalTexture("_CameraDepthTexture", data.destDepth);
                });
            }
        }

        public void Cleanup() {
            if (_copyDepthMaterial != null) {
                CoreUtils.Destroy(_copyDepthMaterial);
            }
        }
    }

    [System.Serializable]
    public class RenderPassSettings {
        public RenderPassEvent RPE { get; } = RenderPassEvent.AfterRenderingOpaques;
    }

    public RenderPassSettings RendPassSett { get; } = new RenderPassSettings();
    UpdateDepthPass depthPass;

    public override void Create() {
        depthPass = new UpdateDepthPass(RendPassSett.RPE);
    }

    public override void AddRenderPasses(ScriptableRenderer sr, ref RenderingData rd) {
        sr.EnqueuePass(depthPass);
    }

    protected override void Dispose(bool isDispos) {
        depthPass?.Cleanup();
    }
}