using VContainer;
using VContainer.Unity;
using UnityEngine;
using UnityEngine.Rendering.Universal;



public class GameLifetimeScope : LifetimeScope {
    [SerializeField] UniversalRendererData rendererData;
    [SerializeField] Material terrainMaterial;
    [SerializeField] Material oceanMaterial;
    [SerializeField] Material spaceMaterial;
    [SerializeField] Material polyDepthMaterial;
    [SerializeField] Transform shipParent;


    protected override void Configure(IContainerBuilder builder) {
        //init def params
        builder.RegisterInstance(rendererData);
        //builder.RegisterInstance(terrainMaterial);
        //builder.RegisterInstance(oceanMaterial);
        //builder.RegisterInstance(spaceMaterial);
        //builder.RegisterInstance(polyDepthMaterial);

        //entry points
        builder.RegisterEntryPoint<AppManager>();

        //services
        builder.Register<IDepthPresentationService, DepthPresentationService>(Lifetime.Singleton)
               .WithParameter("polyDepthMat", polyDepthMaterial)
               .WithParameter("terrainCloudsMarch", terrainMaterial);
        builder.Register<IShaderpassService, ShaderpassService>(Lifetime.Singleton)
               //.WithParameter(rendererData)
               .WithParameter(oceanMaterial);
        builder.Register<IShaderPropertiesService, ShaderPropertiesService>(Lifetime.Singleton)
                .WithParameter("terrainMaterial", terrainMaterial)
                .WithParameter("oceanMaterial", oceanMaterial)
                .WithParameter("spaceMaterial", spaceMaterial);

        //monobeh`s
        builder.RegisterComponentInHierarchy<ShaderSettingsController>()
            .As<ISettingsWndService>();
        builder.RegisterComponentInHierarchy<MainMenuController>()
            .As<IMenuWndService>();
        builder.RegisterComponentInHierarchy<SpaceshipController>();

        //mult monobeh`s
        EngineController[] controllers = shipParent.GetComponentsInChildren<EngineController>(true);
        builder.RegisterBuildCallback(container => {
            foreach (EngineController controller in controllers)
                container.Inject(controller);
        });
    }
}
