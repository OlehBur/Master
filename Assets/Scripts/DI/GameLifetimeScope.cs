using VContainer;
using VContainer.Unity;
using UnityEngine;
using UnityEngine.Rendering.Universal;



public class GameLifetimeScope : LifetimeScope {
    [SerializeField] UniversalRendererData rendererData;
    [SerializeField] Material terrainMaterial;
    [SerializeField] Material oceanMaterial;
    [SerializeField] Material spaceMaterial;
    [SerializeField] Transform shipParent;


    protected override void Configure(IContainerBuilder builder) {
        //def scripts
        builder.Register<ShaderpassService>(Lifetime.Singleton)
               .WithParameter(rendererData)
               .WithParameter(oceanMaterial)
               .As<IShaderpassService>();
        builder.Register<ShaderPropertiesService>(Lifetime.Singleton)
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
