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
        builder.Register<ShaderpassService>(Lifetime.Singleton)
               .WithParameter(rendererData)
               .WithParameter(oceanMaterial)
               .As<IShaderpassService>();
        builder.Register<MenuService>(Lifetime.Singleton);
        builder.Register<ShaderReadPropertiesService>(Lifetime.Singleton)
            .WithParameter(terrainMaterial)
            .WithParameter(oceanMaterial)
            .WithParameter(spaceMaterial);


        builder.RegisterComponentInHierarchy<ShaderSettingsController>();
        builder.RegisterComponentInHierarchy<MainMenuController>();
        builder.RegisterComponentInHierarchy<SpaceshipController>();
        //builder.RegisterComponentInHierarchy<EngineController>();
        EngineController[] controllers = shipParent.GetComponentsInChildren<EngineController>(true);
        //foreach (EngineController controller in controllers) {
        //    //builder.RegisterComponent(controller);
        //    builder.RegisterComponent(controller).As<EngineController>();
        //}
        builder.RegisterBuildCallback(container => {
            foreach (EngineController controller in controllers)
                container.Inject(controller);
        });
    }
}
