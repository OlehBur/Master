using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Experimental.Rendering;

public class UpdateDepthFeature : ScriptableRendererFeature {
    class UpdateDepthPass : ScriptableRenderPass {
        private Material copyDepthMaterial;

        public UpdateDepthPass(RenderPassEvent evt) {
            renderPassEvent = evt;
            Shader shader = Shader.Find("Hidden/Universal Render Pipeline/CopyDepth");
            if (shader != null) {
                copyDepthMaterial = new Material(shader);
            }
            else {
                Debug.LogError("UpdateDepthFeature: Не знайдено шейдер копіювання глибини!");
            }
        }

        class PassData {
            public TextureHandle sourceDepth;
            public TextureHandle destDepth;
            public Material material;
            public TextureHandle colorTarget;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData) {
            if (copyDepthMaterial == null)
                return;

            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

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

            TextureHandle copiedDepth = renderGraph.CreateTexture(desc);

            // --- ПРОХІД 1: Запис глибини у кастомну текстуру ---
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Update Camera Depth - Write", out var passData)) {
                passData.sourceDepth = sourceDepth;
                passData.destDepth = copiedDepth;
                passData.material = copyDepthMaterial;

                builder.UseTexture(sourceDepth, AccessFlags.Read);
                builder.SetRenderAttachmentDepth(copiedDepth, AccessFlags.Write);
                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) => {
                    Blitter.BlitTexture(context.cmd, data.sourceDepth, new Vector4(1, 1, 0, 0), data.material, 0);
                });
            }

            // --- ПРОХІД 2: Безпечне оновлення глобального стану (SetGlobalTexture) ---
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Update Camera Depth - Set Global", out var passData)) {
                passData.destDepth = copiedDepth;
                passData.colorTarget = resourceData.activeColorTexture;

                // Оскільки текстура вже записана, тепер ми читаємо її безпечно
                builder.UseTexture(copiedDepth, AccessFlags.Read);

                // Використовуємо існуючий колірний буфер як легкий аттачмент, щоб прохід був валідним для raster-контексту
                builder.SetRenderAttachment(resourceData.activeColorTexture, 0);

                builder.AllowPassCulling(false);
                builder.AllowGlobalStateModification(true);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) => {
                    context.cmd.SetGlobalTexture("_CameraDepthTexture", data.destDepth);
                });
            }
        }

        public void Cleanup() {
            if (copyDepthMaterial != null) {
                CoreUtils.Destroy(copyDepthMaterial);
            }
        }
    }

    [System.Serializable]
    public class Settings {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public Settings settings = new Settings();
    UpdateDepthPass depthPass;

    public override void Create() {
        depthPass = new UpdateDepthPass(settings.renderPassEvent);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
        renderer.EnqueuePass(depthPass);
    }

    protected override void Dispose(bool disposing) {
        depthPass?.Cleanup();
    }
}