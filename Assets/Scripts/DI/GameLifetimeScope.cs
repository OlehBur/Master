using VContainer;
using VContainer.Unity;
using UnityEngine;
using UnityEngine.Rendering.Universal;



public class GameLifetimeScope : LifetimeScope {
    [SerializeField] UniversalRendererData rendererData;
    [SerializeField] Material oceanMaterial;
    [SerializeField] Transform shipParent;


    protected override void Configure(IContainerBuilder builder) {
        builder.Register<ShaderService>(Lifetime.Singleton)
               .WithParameter(rendererData)
               .WithParameter(oceanMaterial)
               .As<IShaderService>();
        builder.Register<MenuService>(Lifetime.Singleton);



        builder.RegisterComponentInHierarchy<MainMenuController>();
        builder.RegisterComponentInHierarchy<SpaceshipController>();
        builder.RegisterComponentInHierarchy<EngineController>();
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
